alias Services.JapaneseVerbConjugator.Client
alias JapaneseVerbConjugation.VerbTenses

# Creates verbs w/ all datafield found on this website:
# http://www.japaneseverbconjugator.com/JVerbList.asp
Client.all()

verbs = JapaneseVerbConjugation.Verbs.list_verbs()

Enum.each(verbs, fn verb ->
  with {:ok, %{metadata: processed_meta, data: processed_data}} <- Client.get(verb.plain_base) do
    Enum.map(processed_data, fn data ->
      politness_keys = Map.drop(data[:data], [:tense, :meanings])

      Enum.map(politness_keys, fn {key, value} ->
        {romaji, hirigana} =
          case value do
            [romaji, hirigana] ->
              {romaji, hirigana}

            [first_romaji, second_romaji, hirigana] ->
              {first_romaji <> " " <> second_romaji, hirigana}

            [first_romaji, second_romaji, first_kanji, second_kanji] ->
              {first_romaji <> " " <> second_romaji, first_kanji <> " " <> second_kanji}

            [{romaji, hirigana}] ->
              {romaji, hirigana}

            [{_, _}, {romaji, hirigana}] ->
              {romaji, hirigana}

            nil ->
              {nil, nil}

            [] ->
              {nil, nil}

            _ ->
              IO.inspect({nil, nil}, label: to_string(value))
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
            "meaning" => data[:data].meanings[form],
            "romaji" => romaji,
            "hirigana" => hirigana,
            "politness" => politness,
            "tense" => data[:data].tense
          })

        tense
      end)
    end)
  end
end)
