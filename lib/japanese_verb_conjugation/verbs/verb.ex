defmodule JapaneseVerbConjugation.Verbs.Verb do
  @moduledoc """
  Represents a verb in the database
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :class,
             :plain_base
           ]}
  schema "verbs" do
    field :class, :string
    field :plain_base, :string

    timestamps()
  end

  @doc false
  def changeset(verb, attrs) do
    verb
    |> cast(attrs, [:plain_base, :class])
    |> validate_required([:plain_base, :class])
  end
end
