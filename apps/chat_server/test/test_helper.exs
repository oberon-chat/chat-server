ExUnit.configure(exclude: [pending: true])

ExUnit.start()

{:ok, _} = Application.ensure_all_started(:ex_machina)
Ecto.Adapters.SQL.Sandbox.mode(ChatServer.Repo, :manual)
