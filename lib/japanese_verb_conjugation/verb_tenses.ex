defmodule JapaneseVerbConjugation.VerbTenses do
  @moduledoc """
  The VerbTenses context.
  """

  import Ecto.Query, warn: false
  alias JapaneseVerbConjugation.Repo

  alias JapaneseVerbConjugation.VerbTenses.VerbTense

  @doc """
  Returns the list of verb_tenses.

  ## Examples

      iex> list_verb_tenses()
      [%VerbTense{}, ...]

  """
  def list_verb_tenses do
    Repo.all(VerbTense)
  end

  @doc """
  Gets a single verb_tense.

  Raises `Ecto.NoResultsError` if the Verb tense does not exist.

  ## Examples

      iex> get_verb_tense!(123)
      %VerbTense{}

      iex> get_verb_tense!(456)
      ** (Ecto.NoResultsError)

  """
  def get_verb_tense!(id), do: Repo.get!(VerbTense, id)

  def get_tenses_for_verb(verb_id) do
    Repo.all(from vt in VerbTense, where: vt.base_verb_id == ^verb_id)
  end

  @doc """
  Creates a verb_tense.

  ## Examples

      iex> create_verb_tense(%{field: value})
      {:ok, %VerbTense{}}

      iex> create_verb_tense(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_verb_tense(attrs \\ %{}) do
    %VerbTense{}
    |> VerbTense.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a verb_tense.

  ## Examples

      iex> update_verb_tense(verb_tense, %{field: new_value})
      {:ok, %VerbTense{}}

      iex> update_verb_tense(verb_tense, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_verb_tense(%VerbTense{} = verb_tense, attrs) do
    verb_tense
    |> VerbTense.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a verb_tense.

  ## Examples

      iex> delete_verb_tense(verb_tense)
      {:ok, %VerbTense{}}

      iex> delete_verb_tense(verb_tense)
      {:error, %Ecto.Changeset{}}

  """
  def delete_verb_tense(%VerbTense{} = verb_tense) do
    Repo.delete(verb_tense)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking verb_tense changes.

  ## Examples

      iex> change_verb_tense(verb_tense)
      %Ecto.Changeset{data: %VerbTense{}}

  """
  def change_verb_tense(%VerbTense{} = verb_tense, attrs \\ %{}) do
    VerbTense.changeset(verb_tense, attrs)
  end
end
