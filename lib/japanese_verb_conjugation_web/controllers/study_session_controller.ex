defmodule JapaneseVerbConjugationWeb.StudySessionControllerController do
  use JapaneseVerbConjugationWeb, :controller

  require IEx

  alias JapaneseVerbConjugation.{Verbs, VerbTenses}

  def get(conn, %{"session_id" => session_id}) do
    case Services.StudySession.next_card(session_id) do
      {:ok, {next_card, session_details}} ->
        json(conn, %{"card" => next_card, "sessionDetails" => session_details})

      {:error, reason} ->
        json(conn, %{"error" => "Session has expired."})
    end
  end

  def create(conn, %{
        "type" => "deck",
        "tenses" => selected_tenses,
        "deckId" => deckId,
        "filters" => %{"politness" => politness, "sentenceType" => sentence_type}
      }) do
    verbs = JapaneseVerbConjugation.Decks.list_cards(deckId)

    politness =
      case politness do
        "politnessPolite" -> "Polite"
        "politnessInformal" -> "Plain"
        _ -> nil
      end

    form =
      case sentence_type do
        "positive" -> "Positive"
        "negative" -> "Negative"
        _ -> nil
      end

    with tense_params when tense_params != [] <-
           get_tenses_from_params(selected_tenses),
         filtered_verbs_tenses when filtered_verbs_tenses != [] <-
           filter_tensese_by(tense_params, verbs, politness, form),
         session_id <- Ecto.UUID.generate(),
         {:ok, _} <-
           Services.StudySession.start_link(session_id, tense_params, filtered_verbs_tenses) do
      {:ok, {next_card, session_details}} = Services.StudySession.next_card(session_id)
      json(conn, %{"ready" => true, "card" => next_card, "sessionDetails" => session_details})
    else
      [] -> json(conn, %{"ready" => false, "error" => "Please provide a list of verbs."})
      {:error, _} -> json(conn, %{"ready" => false, "error" => "Unable to start session."})
    end
  end

  def create(conn, %{
        "type" => "custom",
        "tenses" => selected_tenses,
        "verbs" => selected_verbs,
        "filters" => %{"politness" => politness, "sentenceType" => sentence_type}
      }) do
    politness =
      case politness do
        "politnessPolite" -> "Polite"
        "politnessInformal" -> "Plain"
        _ -> nil
      end

    form =
      case sentence_type do
        "positive" -> "Positive"
        "negative" -> "Negative"
        _ -> nil
      end

    with tense_params when tense_params != [] <-
           get_tenses_from_params(selected_tenses),
         verbs when verbs != [] <- get_verbs_by_tenses(selected_verbs),
         filtered_verbs_tenses when filtered_verbs_tenses != [] <-
           filter_tensese_by(tense_params, verbs, politness, form),
         session_id <- Ecto.UUID.generate(),
         {:ok, _} <-
           Services.StudySession.start_link(session_id, tense_params, filtered_verbs_tenses) do
      {:ok, {next_card, session_details}} = Services.StudySession.next_card(session_id)
      json(conn, %{"ready" => true, "card" => next_card, "sessionDetails" => session_details})
    else
      [] -> json(conn, %{"ready" => false, "error" => "Please provide a list of verbs."})
      {:error, _} -> json(conn, %{"ready" => false, "error" => "Unable to start session."})
    end
  end

  def update(conn, %{"cardId" => card_id, "ease" => ease, "session_id" => session_id}) do
    params = %{card_id: card_id, ease: ease}

    :ok = Services.StudySession.update(session_id, params)
    {:ok, {next_card, session_details}} = Services.StudySession.next_card(session_id)
    json(conn, %{"card" => next_card, "sessionDetails" => session_details})
  end

  # HELPER FUNCTIONS.....

  defp get_tenses_from_params(selected_tenses) do
    Enum.reduce(selected_tenses, [], fn {key, _}, acc ->
      new_tense =
        case key do
          "allTenses" -> "All"
          "presentSimple" -> "Present Indicative"
          "pastSimple" -> "Past Indicative Past Presumptive"
          "presentContinuous" -> "Present Progressive"
          "pastContinuous" -> "Past Progressive"
          _ -> []
        end

      [new_tense | acc]
    end)
  end

  defp get_verbs_by_tenses(selected_verbs) do
    Enum.reduce(selected_verbs, [], fn {selected_verb, _}, acc ->
      [_, kanji] = String.split(selected_verb, "-")

      case JapaneseVerbConjugation.Verbs.get_by_base(kanji) do
        %Verbs.Verb{} = v ->
          acc ++ VerbTenses.get_tenses_for_verb(v.id)

        _ ->
          acc
      end
    end)
  end

  # @spec filter_tensese_by(
  #   list(String.t(),
  #   String.t(),
  #   String.t()
  #   ) :: list(VerbTenses.VerbTense.t())
  defp filter_tensese_by(tenses, all_verb_tenses, politness, form) do
    if "All" in tenses do
      all_verb_tenses
    else
      filter_func =
        case {politness, form} do
          {nil, nil} ->
            &(&1.tense in tenses)

          {p, nil} ->
            &(&1.politness == p and &1.tense in tenses)

          {nil, f} ->
            &(&1.form == f and &1.tense in tenses)

          {p, f} ->
            &(&1.form == f and &1.politness == p and &1.tense in tenses)
        end

      Enum.filter(all_verb_tenses, &(&1.tense in tenses))
    end
  end
end
