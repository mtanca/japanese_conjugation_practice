defmodule JapaneseVerbConjugation.Verbs do
  @moduledoc """
  The Verbs context.
  """

  import Ecto.Query, warn: false
  alias JapaneseVerbConjugation.Repo

  alias JapaneseVerbConjugation.Verbs.Verb

  @doc """
  Returns the list of verbs.

  ## Examples

      iex> list_verbs()
      [%Verb{}, ...]

  """
  def list_verbs do
    Repo.all(Verb)
  end

  def get_by_base(base_verb), do: Repo.get_by(Verb, plain_base: base_verb)

  @doc """
  Creates a verb.

  ## Examples

      iex> create_verb(%{field: value})
      {:ok, %Verb{}}

      iex> create_verb(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_verb(attrs \\ %{}) do
    %Verb{}
    |> Verb.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a verb.

  ## Examples

      iex> update_verb(verb, %{field: new_value})
      {:ok, %Verb{}}

      iex> update_verb(verb, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_verb(%Verb{} = verb, attrs) do
    verb
    |> Verb.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a verb.

  ## Examples

      iex> delete_verb(verb)
      {:ok, %Verb{}}

      iex> delete_verb(verb)
      {:error, %Ecto.Changeset{}}

  """
  def delete_verb(%Verb{} = verb) do
    Repo.delete(verb)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking verb changes.

  ## Examples

      iex> change_verb(verb)
      %Ecto.Changeset{data: %Verb{}}

  """
  def change_verb(%Verb{} = verb, attrs \\ %{}) do
    Verb.changeset(verb, attrs)
  end
end
