alias Services.JapaneseVerbConjugator.Client
alias JapaneseVerbConjugation.VerbTenses

# Creates verbs w/ all datafield found on this website:
# http://www.japaneseverbconjugator.com/JVerbList.asp
Client.all()

verbs = JapaneseVerbConjugation.Verbs.list_verbs()

Enum.each(verbs, fn verb ->
  with {:ok, response_data} <- Client.get(verb.plain_base) do
    Enum.map(response_data.data, fn data ->
      politness_keys = Map.drop(data, [:tense, :meanings])

      Enum.map(politness_keys, fn {key, value} ->
        {romaji, hirigana} =
          case value do
            {romaji, hirigana} -> {romaji, hirigana}
            [{romaji, hirigana}] -> {romaji, hirigana}
            [{_, _}, {romaji, hirigana}] -> {romaji, hirigana}
            nil -> {nil, nil}
            [] -> {nil, nil}
          end

        {form, politness} =
          case key do
            :plain_negative -> {"Negative", "Plain"}
            :plain_positive -> {"Positive", "Plain"}
            :polite_negative -> {"Negative", "Polite"}
            :polite_positive -> {"Positive", "Polite"}
          end

        {:ok, tense} =
          VerbTenses.create_verb_tense(%{
            "base_verb_id" => verb.id,
            "form" => form,
            "meaning" => data.meanings[form],
            "romaji" => romaji,
            "hirigana" => hirigana,
            "politness" => politness,
            "tense" => data.tense
          })

        tense
      end)
    end)
  end
end)
