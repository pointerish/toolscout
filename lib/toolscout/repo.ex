defmodule Toolscout.Repo do
  use Ecto.Repo,
    otp_app: :toolscout,
    adapter: Ecto.Adapters.Postgres
end
