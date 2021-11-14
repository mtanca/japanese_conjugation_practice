defmodule JapaneseVerbConjugationWeb.SearchController do
  use JapaneseVerbConjugationWeb, :controller

  alias Services.JapaneseVerbConjugator.Client
  alias Services.VerbManager

  alias JapaneseVerbConjugation.Verbs
  alias JapaneseVerbConjugation.VerbTenses

  require Logger

  def index(conn, params) do
    json(conn, %{"data" => Verbs.list_verbs()})
  end

  def search(conn, %{"hirigana_verb" => hirigana_verb}) do
    render_response = fn info ->
      case info do
        {:ok, data} ->
          json(conn, %{"success" => "true", "data" => data})

        {:error, reason} ->
          msg = "Unable to find verb #{hirigana_verb}. Please try again later"
          Logger.error(inspect(reason))
          json(conn, %{"error" => msg})
      end
    end

    case VerbManager.get_all_tenses(hirigana_verb) do
      {:ok, data} ->
        Logger.info("Pulling cached data from VerbManager for #{hirigana_verb}")
        render_response.({:ok, data})

      {:error, reason} ->
        Logger.info(reason)
        info = find_verb_locally(hirigana_verb)
        render_response.(info)
    end
  end

  defp find_verb_locally(hirigana_verb) do
    with verb when not is_nil(verb) <- Verbs.get_by_base(hirigana_verb),
         verb_tenses when verb_tenses != [] <- VerbTenses.get_tenses_for_verb(verb.id) do
      Services.VerbManager.start_link(hirigana_verb)
      {:ok, verb_tenses}
    else
      _error ->
        case create_verb(hirigana_verb) do
          {:ok, _data} ->
            Services.VerbManager.start_link(hirigana_verb)
            find_verb_locally(hirigana_verb)

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp create_verb(hirigana_verb) do
    with {:ok, response_data} <- Client.get(hirigana_verb),
         {:ok, new_verb} <-
           Verbs.create_verb(%{
             "class" => response_data.metadata["Verb Class"],
             "plain_base" => hirigana_verb
           }) do
      data =
        Enum.map(response_data.data, fn data ->
          create_verb_tenses(new_verb, data)
        end)

      {:ok, data}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp create_verb_tenses(verb, data) do
    politness_keys = Map.drop(data, [:tense, :meanings])

    Enum.map(politness_keys, fn {key, value} ->
      {romaji, hirigana} =
        case value do
          {romaji, hirigana} -> {romaji, hirigana}
          [{romaji, hirigana}] -> {romaji, hirigana}
          [{_, _}, {romaji, hirigana}] -> {romaji, hirigana}
          nil -> {nil, nil}
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
  end
end
