defmodule Plausible.Shields do
  @moduledoc """
  Contextual interface for shields.
  """
  import Ecto.Query
  alias Plausible.Repo
  alias Plausible.Shield
  alias Plausible.Site

  @maximum_ip_rules 30
  def maximum_ip_rules(), do: @maximum_ip_rules

  @maximum_country_rules 30
  def maximum_country_rules(), do: @maximum_country_rules

  @maximum_page_rules 30
  def maximum_page_rules(), do: @maximum_page_rules

  @spec list_ip_rules(Site.t() | non_neg_integer()) :: [Shield.IPRule.t()]
  def list_ip_rules(site_or_id) do
    list(Shield.IPRule, site_or_id)
  end

  @spec ip_blocked?(Site.t() | String.t(), String.t()) :: boolean()
  def ip_blocked?(%Site{domain: domain}, address) do
    ip_blocked?(domain, address)
  end

  def ip_blocked?(domain, address) when is_binary(domain) and is_binary(address) do
    case Shield.IPRuleCache.get({domain, address}) do
      %Shield.IPRule{action: :deny} ->
        true

      _ ->
        false
    end
  end

  @spec page_blocked?(Site.t() | String.t(), String.t()) :: boolean()
  def page_blocked?(%Site{domain: domain}, address) do
    page_blocked?(domain, address)
  end

  def page_blocked?(domain, pathname) when is_binary(domain) and is_binary(pathname) do
    page_rules = Shield.PageRuleCache.get(domain)

    if page_rules do
      page_rules
      |> List.wrap()
      |> Enum.find_value(false, fn rule ->
        rule.action == :deny and Regex.match?(rule.page_path_pattern, pathname)
      end)
    else
      false
    end
  end

  @spec country_blocked?(Site.t() | String.t(), String.t()) :: boolean()
  def country_blocked?(%Site{domain: domain}, country_code) do
    country_blocked?(domain, country_code)
  end

  def country_blocked?(domain, country_code) when is_binary(domain) and is_binary(country_code) do
    case Shield.CountryRuleCache.get({domain, String.upcase(country_code)}) do
      %Shield.CountryRule{action: :deny} ->
        true

      _ ->
        false
    end
  end

  @spec add_ip_rule(Site.t() | non_neg_integer(), map(), Keyword.t()) ::
          {:ok, Shield.IPRule.t()} | {:error, Ecto.Changeset.t()}
  def add_ip_rule(site_or_id, params, opts \\ []) do
    opts =
      Keyword.put(opts, :limit, {:inet, @maximum_ip_rules})

    add(Shield.IPRule, site_or_id, params, opts)
  end

  @spec remove_ip_rule(Site.t() | non_neg_integer(), String.t()) :: :ok
  def remove_ip_rule(site_or_id, rule_id) do
    remove(Shield.IPRule, site_or_id, rule_id)
  end

  @spec count_ip_rules(Site.t() | non_neg_integer()) :: non_neg_integer()
  def count_ip_rules(site_or_id) do
    count(Shield.IPRule, site_or_id)
  end

  @spec list_country_rules(Site.t() | non_neg_integer()) :: [Shield.CountryRule.t()]
  def list_country_rules(site_or_id) do
    list(Shield.CountryRule, site_or_id)
  end

  @spec add_country_rule(Site.t() | non_neg_integer(), map(), Keyword.t()) ::
          {:ok, Shield.CountryRule.t()} | {:error, Ecto.Changeset.t()}
  def add_country_rule(site_or_id, params, opts \\ []) do
    opts = Keyword.put(opts, :limit, {:country_code, @maximum_country_rules})
    add(Shield.CountryRule, site_or_id, params, opts)
  end

  @spec remove_country_rule(Site.t() | non_neg_integer(), String.t()) :: :ok
  def remove_country_rule(site_or_id, rule_id) do
    remove(Shield.CountryRule, site_or_id, rule_id)
  end

  @spec count_country_rules(Site.t() | non_neg_integer()) :: non_neg_integer()
  def count_country_rules(site_or_id) do
    count(Shield.CountryRule, site_or_id)
  end

  @spec list_page_rules(Site.t() | non_neg_integer()) :: [Shield.PageRule.t()]
  def list_page_rules(site_or_id) do
    list(Shield.PageRule, site_or_id)
  end

  @spec add_page_rule(Site.t() | non_neg_integer(), map(), Keyword.t()) ::
          {:ok, Shield.PageRule.t()} | {:error, Ecto.Changeset.t()}
  def add_page_rule(site_or_id, params, opts \\ []) do
    opts = Keyword.put(opts, :limit, {:page_path, @maximum_page_rules})
    add(Shield.PageRule, site_or_id, params, opts)
  end

  @spec remove_page_rule(Site.t() | non_neg_integer(), String.t()) :: :ok
  def remove_page_rule(site_or_id, rule_id) do
    remove(Shield.PageRule, site_or_id, rule_id)
  end

  @spec count_page_rules(Site.t() | non_neg_integer()) :: non_neg_integer()
  def count_page_rules(site_or_id) do
    count(Shield.PageRule, site_or_id)
  end

  defp list(schema, %Site{id: id}) do
    list(schema, id)
  end

  defp list(schema, site_id) when is_integer(site_id) do
    Repo.all(
      from r in schema,
        where: r.site_id == ^site_id,
        order_by: [desc: r.inserted_at]
    )
  end

  defp add(schema, %Site{id: id}, params, opts) do
    add(schema, id, params, opts)
  end

  defp add(schema, site_id, params, opts) when is_integer(site_id) do
    {field, max} = Keyword.fetch!(opts, :limit)

    Repo.transaction(fn ->
      result =
        if count(schema, site_id) >= max do
          changeset =
            schema
            |> struct(site_id: site_id)
            |> schema.changeset(params)
            |> Ecto.Changeset.add_error(field, "maximum reached")

          {:error, changeset}
        else
          schema
          |> struct(site_id: site_id, added_by: format_added_by(opts[:added_by]))
          |> schema.changeset(params)
          |> Repo.insert()
        end

      case result do
        {:ok, rule} -> rule
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  defp remove(schema, %Site{id: id}, rule_id) do
    remove(schema, id, rule_id)
  end

  defp remove(schema, site_id, rule_id) when is_integer(site_id) do
    Repo.delete_all(from(r in schema, where: r.site_id == ^site_id and r.id == ^rule_id))
    :ok
  end

  defp count(schema, %Site{id: id}) do
    count(schema, id)
  end

  defp count(schema, site_id) when is_integer(site_id) do
    Repo.aggregate(from(r in schema, where: r.site_id == ^site_id), :count)
  end

  defp format_added_by(nil), do: ""
  defp format_added_by(%Plausible.Auth.User{} = user), do: "#{user.name} <#{user.email}>"
end
