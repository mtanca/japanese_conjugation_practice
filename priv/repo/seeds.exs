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

            [first_romaji, second_romaji, third_romaji, first_kanji, second_kanji] ->
              {Enum.join([first_romaji, second_romaji, third_romaji], " "),
               first_kanji <> " " <> second_kanji}

            [{romaji, hirigana}] ->
              {romaji, hirigana}

            [{_, _}, {romaji, hirigana}] ->
              {romaji, hirigana}

            [_] ->
              {nil, nil}

            _other ->
              {nil, nil}
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

[
  %{
    name: "Japanese Verbs",
    tenses: ["Present Indicative"],
    form: ["Negative", "Positive"],
    politness: ["Plain", "Polite"],
    data: [
      "おくる",
      "すわる",
      "おく",
      "やくす",
      "とまる",
      "かえる",
      "ならう",
      "つづける",
      "うまれる",
      "ねがう",
      "かぶる",
      "はく",
      "なおす",
      "いる",
      "おりる",
      "かつ",
      "やく",
      "いきる",
      "はこぶ",
      "あらう",
      "はたらく",
      "できる",
      "ぬぐ",
      "あう",
      "こたえる",
      "しまる",
      "のむ",
      "やすぶ",
      "まがる",
      "つかう",
      "まける",
      "しんじる",
      "もらう",
      "よむ",
      "はいる",
      "かく",
      "およぐ",
      "たずねる",
      "おぼえる",
      "もつ",
      "あそぶ",
      "のる",
      "みつける",
      "あける",
      "つくる"
    ]
  }
]
|> Enum.each(fn deck ->
  {:ok, new_deck} = JapaneseVerbConjugation.Decks.create_deck(%{name: deck.name})

  Enum.each(deck.data, fn verb_plain_base ->
    # hirigana in data list may differ from whats in db- look up plain base in api
    with {:ok, api_data} <- Services.JapaneseVerbConjugator.Client.get(verb_plain_base),
         [_, plain_base] <-
           Enum.find(api_data.data, fn %{data: d} -> d.tense in ["Present Indicative"] end)
           |> get_in([:data, :plain_positive]),
         verb when not is_nil(verb) <- JapaneseVerbConjugation.Verbs.get_by_base(plain_base),
         tenses when tenses != [] <-
           JapaneseVerbConjugation.VerbTenses.get_tenses_for_verb(verb.id) do
      Enum.filter(tenses, fn tense ->
        tense.form in deck.form and tense.politness in deck.politness and
          tense.tense in deck.tenses
      end)
      |> Enum.each(fn card ->
        {:ok, _} =
          JapaneseVerbConjugation.CardDecks.create_card_deck(%{
            deck_id: new_deck.id,
            card_id: card.id
          })
      end)
    else
      reason -> IO.inspect(inspect(reason), label: "FAILED......")
    end
  end)
end)
