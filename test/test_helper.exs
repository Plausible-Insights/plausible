{:ok, _} = Application.ensure_all_started(:ex_machina)
Plausible.Test.ClickhouseSetup.run()
Mox.defmock(Plausible.HTTPClient.Mock, for: Plausible.HTTPClient.Interface)
<<<<<<< HEAD
=======
FunWithFlags.enable(:visits_metric)
>>>>>>> 867dad6da7bb361f584d5bd35582687f90afb7e1
ExUnit.start(exclude: :slow)
Application.ensure_all_started(:double)
Ecto.Adapters.SQL.Sandbox.mode(Plausible.Repo, :manual)
