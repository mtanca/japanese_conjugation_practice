defmodule JapaneseVerbConjugationWeb.StudySessionControllerController do
  use JapaneseVerbConjugationWeb, :controller

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
        "tenses" => selected_tenses,
        "verbs" => selected_verbs,
        "filters" => %{"politness" => politness, "sentenceType" => sentence_type}
      }) do
    tenses = get_tenses_from_params(selected_tenses)

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

    with verbs_tenses when verbs_tenses != [] <-
           get_verb_tenses_from_params(tenses, selected_verbs, politness, form),
         session_id <- Ecto.UUID.generate(),
         {:ok, _} <- Services.StudySession.start_link(session_id, tenses, verbs_tenses) do
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
    Enum.reduce(selected_tenses, [], fn tense, acc ->
      [key] = Map.keys(tense)

      new_tense =
        case key do
          "presentSimple" -> "Present Indicative"
          "pastSimple" -> "Past Indicative Past Presumptive"
          "presentContinuous" -> "Present Progressive"
          "pastContinuous" -> "Past Progressive"
        end

      [new_tense | acc]
    end)
  end

  defp get_verb_tenses_from_params(tenses, selected_verbs, politness, form) do
    Enum.reduce(selected_verbs, [], fn {selected_verb, _}, acc ->
      [_, kanji] = String.split(selected_verb, "-")

      case JapaneseVerbConjugation.Verbs.get_by_base(kanji) do
        %Verbs.Verb{} = v ->
          all_verb_tenses = VerbTenses.get_tenses_for_verb(v.id)

          filtered_tenses =
            case {politness, form} do
              {nil, nil} ->
                Enum.filter(all_verb_tenses, fn vt -> vt.tense in tenses end)

              {p, nil} ->
                Enum.filter(all_verb_tenses, fn vt -> vt.politness == p and vt.tense in tenses end)

              {nil, f} ->
                Enum.filter(all_verb_tenses, fn vt -> vt.form == f and vt.tense in tenses end)

              {p, f} ->
                Enum.filter(all_verb_tenses, fn vt ->
                  vt.form == f and vt.politness == p and vt.tense in tenses
                end)
            end

          acc ++ filtered_tenses

        _ ->
          acc
      end
    end)
  end
end
