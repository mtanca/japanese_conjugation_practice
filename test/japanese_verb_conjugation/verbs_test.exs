defmodule JapaneseVerbConjugation.VerbsTest do
  use JapaneseVerbConjugation.DataCase

  alias JapaneseVerbConjugation.Verbs

  describe "verbs" do
    alias JapaneseVerbConjugation.Verbs.Verb

    @valid_attrs %{
      class: "some class",
      plain_base: "some plain_base",
      romaji: "some romaji",
      meaning: "some meaning"
    }

    @update_attrs %{
      class: "some updated class",
      plain_base: "some updated plain_base",
      romaji: "some updated romaji",
      meaning: "some updated meaning"
    }

    @invalid_attrs %{class: nil, plain_base: nil, meaning: nil, romaji: nil}

    def verb_fixture(attrs \\ %{}) do
      {:ok, verb} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Verbs.create_verb()

      verb
    end

    test "list_verbs/0 returns all verbs" do
      verb = verb_fixture()
      assert Verbs.list_verbs() == [verb]
    end

    test "get_by_base/1 returns the verb with given id" do
      verb = verb_fixture()
      assert Verbs.get_by_base(verb.plain_base) == verb
    end

    test "create_verb/1 with valid data creates a verb" do
      assert {:ok, %Verb{} = verb} = Verbs.create_verb(@valid_attrs)
      assert verb.class == "some class"
      assert verb.plain_base == "some plain_base"
    end

    test "create_verb/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Verbs.create_verb(@invalid_attrs)
    end

    test "update_verb/2 with valid data updates the verb" do
      verb = verb_fixture()
      assert {:ok, %Verb{} = verb} = Verbs.update_verb(verb, @update_attrs)
      assert verb.class == "some updated class"
      assert verb.plain_base == "some updated plain_base"
    end

    test "update_verb/2 with invalid data returns error changeset" do
      verb = verb_fixture()
      assert {:error, %Ecto.Changeset{}} = Verbs.update_verb(verb, @invalid_attrs)
      assert verb == Verbs.get_by_base(verb.plain_base)
    end

    test "delete_verb/1 deletes the verb" do
      verb = verb_fixture()
      assert {:ok, %Verb{}} = Verbs.delete_verb(verb)
      assert is_nil(Verbs.get_by_base(verb.plain_base))
    end

    test "change_verb/1 returns a verb changeset" do
      verb = verb_fixture()
      assert %Ecto.Changeset{} = Verbs.change_verb(verb)
    end
  end
end
