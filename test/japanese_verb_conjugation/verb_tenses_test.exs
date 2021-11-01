defmodule JapaneseVerbConjugation.VerbTensesTest do
  use JapaneseVerbConjugation.DataCase

  alias JapaneseVerbConjugation.VerbTenses

  describe "verb_tenses" do
    alias JapaneseVerbConjugation.VerbTenses.VerbTense

    @valid_attrs %{
      base_verb_id: 42,
      form: "some form",
      meaning: "some meaning",
      politness: "some politness",
      tense: "some tense"
    }
    @update_attrs %{
      base_verb_id: 43,
      form: "some updated form",
      meaning: "some updated meaning",
      politness: "some updated politness",
      tense: "some updated tense"
    }
    @invalid_attrs %{base_verb_id: nil, form: nil, meaning: nil, politness: nil, tense: nil}

    def verb_tense_fixture(attrs \\ %{}) do
      {:ok, verb_tense} =
        attrs
        |> Enum.into(@valid_attrs)
        |> VerbTenses.create_verb_tense()

      verb_tense
    end

    test "list_verb_tenses/0 returns all verb_tenses" do
      verb_tense = verb_tense_fixture()
      assert VerbTenses.list_verb_tenses() == [verb_tense]
    end

    test "get_verb_tense!/1 returns the verb_tense with given id" do
      verb_tense = verb_tense_fixture()
      assert VerbTenses.get_verb_tense!(verb_tense.id) == verb_tense
    end

    test "create_verb_tense/1 with valid data creates a verb_tense" do
      assert {:ok, %VerbTense{} = verb_tense} = VerbTenses.create_verb_tense(@valid_attrs)
      assert verb_tense.base_verb_id == 42
      assert verb_tense.form == "some form"
      assert verb_tense.meaning == "some meaning"
      assert verb_tense.politness == "some politness"
      assert verb_tense.tense == "some tense"
    end

    test "create_verb_tense/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = VerbTenses.create_verb_tense(@invalid_attrs)
    end

    test "update_verb_tense/2 with valid data updates the verb_tense" do
      verb_tense = verb_tense_fixture()

      assert {:ok, %VerbTense{} = verb_tense} =
               VerbTenses.update_verb_tense(verb_tense, @update_attrs)

      assert verb_tense.base_verb_id == 43
      assert verb_tense.form == "some updated form"
      assert verb_tense.meaning == "some updated meaning"
      assert verb_tense.politness == "some updated politness"
      assert verb_tense.tense == "some updated tense"
    end

    test "update_verb_tense/2 with invalid data returns error changeset" do
      verb_tense = verb_tense_fixture()

      assert {:error, %Ecto.Changeset{}} =
               VerbTenses.update_verb_tense(verb_tense, @invalid_attrs)

      assert verb_tense == VerbTenses.get_verb_tense!(verb_tense.id)
    end

    test "delete_verb_tense/1 deletes the verb_tense" do
      verb_tense = verb_tense_fixture()
      assert {:ok, %VerbTense{}} = VerbTenses.delete_verb_tense(verb_tense)
      assert_raise Ecto.NoResultsError, fn -> VerbTenses.get_verb_tense!(verb_tense.id) end
    end

    test "change_verb_tense/1 returns a verb_tense changeset" do
      verb_tense = verb_tense_fixture()
      assert %Ecto.Changeset{} = VerbTenses.change_verb_tense(verb_tense)
    end
  end
end
