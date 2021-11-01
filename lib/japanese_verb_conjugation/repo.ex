defmodule JapaneseVerbConjugation.Repo do
  use Ecto.Repo,
    otp_app: :japanese_verb_conjugation,
    adapter: Ecto.Adapters.Postgres
end
