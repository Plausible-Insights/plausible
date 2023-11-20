defmodule Plausible.Auth.TOTP do
  @moduledoc """
  TOTP auth context

  Handles all the aspects of TOTP setup, management and validation for users.

  ## Setup

  TOTP setup is started with `initiate/1`. At this stage, a random secret
  binary is generated for user and stored under `User.totp_secret`. The secret
  is additionally encrypted while stored in the database using `Cloak`. The
  vault for safe storage is configured in `Plausible.Auth.TOTP.Vault` via
  a dedicated `Ecto` type defined in `Plausible.Auth.TOTP.EncryptedBinary`.
  The function returns updated user along with TOTP URI and a readable form
  of secret. Both - the URI and readable secret - are meant for exposure 
  in the user's setup screen. The URI should be encoded as a QR code.

  After initiation, user is expected to confirm valid setup with `enable/2`,
  providing TOTP code from their authenticator app. After code validation 
  passes successfully, the `User.totp_enabled` flag is set to `true`.

  Finally, the user must be immediately presented with a list of recovery codes
  generated with `generate_recovery_codes/1`. The codes should be presented
  in copy/paste friendly form, ideally also with a print-friendly view option.
  The function can be run more than once, giving the user ability to regenerate
  codes from the final stage of setup if needed.

  The `initiate/1` and `enable/1` functions can be safely called multiple
  times, allowing user to abort and restart setup up to these stages.

  ## Management

  State of TOTP for a particular user can be chcecked by calling `enabled?/1`.

  TOTP can be disabled with `disable/2`. User is expected to provide their
  current password for safety. Once disabled, all TOTP user settings are
  cleared and any remaining generated recovery codes are removed. The function
  can be safely run more than once.

  If the user needs to regenerate the recovery codes outside of setup procedure,
  they must do it via `generate_recovery_codes_protected/2`, providing
  their current password for safety. They must be warned that any existing
  recovery codes will be invalidated.

  ## Validation

  After logging in, user's TOTP state must be checked with `enabled?/1`.

  If enabled, user must be presented with TOTP code input form accepting
  6 digit characters. The code must be checked using `validate_code/2`.

  User must have an option to alternatively input one of their recovery
  codes. Those codes must be checked with `use_recovery_code/2`.

  ## Code validity

  In case of TOTP codes, a grace period of 30 seconds is applied, which
  allows user to use their current and previous TOTP code, assuming 30
  second validity window of each. This allows user to use code that was 
  about to expire before the submission. Regardless of that, each TOTP
  code can be used only once. Validation procedure rejects repeat use
  of the same code for safety. It's done by tracking last time a TOTP
  code was used successfully, stored under `User.totp_last_used_at`.

  In case of recovery codes, each code is deleted immediately after use.
  They are strictly one-time use only.

  """

  import Ecto.Changeset, only: [change: 2]
  import Ecto.Query, only: [from: 2]

  alias Plausible.Auth
  alias Plausible.Auth.TOTP
  alias Plausible.Repo

  @issuer_name "Plausible Analytics"
  @recovery_codes_count 10

  @spec enabled?(Auth.User.t()) :: boolean()
  def enabled?(user) do
    user.totp_enabled and not is_nil(user.totp_secret)
  end

  @spec initiate(Auth.User.t()) ::
          {:ok, Auth.User.t(), %{totp_uri: String.t(), secret: String.t()}}
          | {:error, :not_verified | :already_setup}
  def initiate(%{email_verified: false}) do
    {:error, :not_verified}
  end

  def initiate(%{totp_enabled: true}) do
    {:error, :already_setup}
  end

  def initiate(user) do
    secret = NimbleTOTP.secret()

    user =
      user
      |> change(
        totp_enabled: false,
        totp_secret: secret
      )
      |> Repo.update!()

    {:ok, user, %{totp_uri: totp_uri(user), secret: readable_secret(user)}}
  end

  @spec enable(Auth.User.t(), String.t(), Keyword.t()) ::
          {:ok, Auth.User.t()} | {:error, :invalid_code | :not_initiated}
  def enable(user, code, opts \\ [])

  def enable(%{totp_secret: nil}, _, _) do
    {:error, :not_initiated}
  end

  def enable(user, code, opts) do
    with {:ok, user} <- do_validate_code(user, code, opts) do
      user =
        user
        |> change(totp_enabled: true)
        |> Repo.update!()

      {:ok, user}
    end
  end

  @spec disable(Auth.User.t(), String.t()) :: {:ok, Auth.User.t()} | {:error, :invalid_password}
  def disable(user, password) do
    if Auth.Password.match?(password, user.password_hash) do
      Repo.transaction(fn ->
        {_, _} =
          user
          |> recovery_codes_query()
          |> Repo.delete_all()

        user
        |> change(
          totp_enabled: false,
          totp_secret: nil,
          totp_last_used_at: nil
        )
        |> Repo.update!()
      end)
    else
      {:error, :invalid_password}
    end
  end

  @spec generate_recovery_codes_protected(Auth.User.t(), String.t()) ::
          {:ok, [String.t()]} | {:error, :invalid_password | :not_enabled}
  def generate_recovery_codes_protected(%{totp_enabled: false}) do
    {:error, :not_enabled}
  end

  def generate_recovery_codes_protected(user, password) do
    if Auth.Password.match?(password, user.password_hash) do
      generate_recovery_codes(user)
    else
      {:error, :invalid_password}
    end
  end

  @spec generate_recovery_codes(Auth.User.t()) :: {:ok, [String.t()]} | {:error, :not_enabled}
  def generate_recovery_codes(%{totp_enabled: false}) do
    {:error, :not_enabled}
  end

  def generate_recovery_codes(user) do
    Repo.transaction(fn ->
      {_, _} =
        user
        |> recovery_codes_query()
        |> Repo.delete_all()

      plain_codes = TOTP.RecoveryCode.generate_codes(@recovery_codes_count)

      now =
        NaiveDateTime.utc_now()
        |> NaiveDateTime.truncate(:second)

      codes =
        plain_codes
        |> Enum.map(fn plain_code ->
          user
          |> TOTP.RecoveryCode.changeset(plain_code)
          |> TOTP.RecoveryCode.changeset_to_map(now)
        end)

      {_, _} = Repo.insert_all(TOTP.RecoveryCode, codes)

      plain_codes
    end)
  end

  @spec validate_code(Auth.User.t(), String.t()) ::
          {:ok, Auth.User.t(), Keyword.t()} | {:error, :invalid_code | :not_enabled}
  def validate_code(user, code, opts \\ [])

  def validate_code(%{totp_enabled: false}, _, _) do
    {:error, :not_enabled}
  end

  def validate_code(user, code, opts) do
    do_validate_code(user, code, opts)
  end

  @spec use_recovery_code(Auth.User.t(), String.t()) ::
          :ok | {:error, :invalid_code | :not_enabled}
  def user_recovery_code(%{totp_enabled: false}, _) do
    {:error, :not_enabled}
  end

  def use_recovery_code(user, code) do
    matching_code =
      user
      |> recovery_codes_query()
      |> Repo.all()
      |> Enum.find(&TOTP.RecoveryCode.match?(&1, code))

    if matching_code do
      Repo.delete!(matching_code)
      :ok
    else
      {:error, :invalid_code}
    end
  end

  defp totp_uri(user) do
    NimbleTOTP.otpauth_uri("#{@issuer_name}:#{user.email}", user.totp_secret,
      issuer: @issuer_name
    )
  end

  defp readable_secret(user) do
    Base.encode32(user.totp_secret, padding: false)
  end

  defp recovery_codes_query(user) do
    from(rc in TOTP.RecoveryCode, where: rc.user_id == ^user.id)
  end

  defp do_validate_code(user, code, opts) do
    # Necessary because we must be sure the timestamp is current.
    # User struct stored in liveview context on mount might be
    # pretty out of date, for instance.
    last_used =
      if Keyword.get(opts, :allow_reuse?) do
        nil
      else
        fetch_last_used(user)
      end

    time = System.os_time(:second)

    if NimbleTOTP.valid?(user.totp_secret, code, since: last_used, time: time) or
         NimbleTOTP.valid?(user.totp_secret, code, since: last_used, time: time - 30) do
      {:ok, bump_last_used!(user)}
    else
      {:error, :invalid_code}
    end
  end

  defp fetch_last_used(user) do
    datetime =
      from(u in Plausible.Auth.User, where: u.id == ^user.id, select: u.totp_last_used_at)
      |> Repo.one()

    if datetime do
      Timex.to_unix(datetime)
    end
  end

  defp bump_last_used!(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    user
    |> change(totp_last_used_at: now)
    |> Repo.update!()
  end
end
