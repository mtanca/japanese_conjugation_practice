defmodule JapaneseVerbConjugation.VerbTenses.VerbTense do
  @moduledoc """
  Represents a verb-tense in the database
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :base_verb_id,
             :form,
             :meaning,
             :politness,
             :tense,
             :romaji,
             :hirigana
           ]}
  schema "verb_tenses" do
    field :base_verb_id, :integer
    field :form, :string
    field :meaning, :string
    field :politness, :string
    field :tense, :string
    field :romaji, :string
    field :hirigana, :string

    timestamps()
  end

  @type t() :: %__MODULE__{
          base_verb_id: non_neg_integer(),
          form: String.t(),
          meaning: String.t(),
          politness: String.t(),
          tense: String.t(),
          romaji: String.t(),
          hirigana: String.t()
        }

  @doc false
  def changeset(verb_tense, attrs) do
    verb_tense
    |> cast(attrs, [:base_verb_id, :tense, :form, :politness, :meaning, :romaji, :hirigana])
    |> validate_required([:base_verb_id, :tense, :form, :politness])
  end
end
