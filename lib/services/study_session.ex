defmodule Services.StudySession do
  @moduledoc """
  An actor responsible for managing a specific study session
  """

  use GenServer
  use TypedStruct

  alias JapaneseVerbConjugation.{Verbs, VerbTenses}

  require Logger

  @type verb_data :: %{
          (verb_id :: non_neg_integer()) => %{
            required(:easy_count) => non_neg_integer(),
            required(:medium_count) => non_neg_integer(),
            required(:hard_count) => non_neg_integer()
          }
        }

  typedstruct do
    field :session_id, String.t()
    field :tenses, String.t()
    field :verbs, list(Verbs.t())
    field :card_scores, map() | verb_data()
    field :card_count, non_neg_integer()
  end

  @spec start_link(
          session_id :: String.t(),
          selected_tenses :: list(String.t()),
          selected_verbs :: list(VerbTenses.VerbTense.t())
        ) :: {:ok, pid()} | {:error, term()}
  def start_link(session_id, selected_tenses, selected_verbs) do
    params = [session_id, selected_tenses, selected_verbs] |> IO.inspect(label: "======")
    GenServer.start_link(__MODULE__, params, name: :"#{session_id}")
  end

  def next_card(session_id) do
    with session when not is_nil(session) <- Process.whereis(:"#{session_id}") do
      GenServer.call(session, :next_card)
    else
      _ ->
        {:error, "Unable to find actor for session"}
    end
  end

  def update(session_id, %{card_id: _card_id, ease: _ease} = update_params) do
    with session when not is_nil(session) <- Process.whereis(:"#{session_id}") do
      GenServer.call(session, {:update, update_params})
    else
      _ ->
        {:error, "Unable to find actor for session"}
    end
  end

  @impl GenServer
  def init([session_id, selected_tenses, selected_verbs]) do
    Logger.info("Starting session #{session_id}")

    {:ok,
     %__MODULE__{
       session_id: session_id,
       tenses: selected_tenses,
       verbs: selected_verbs,
       card_scores: %{},
       card_count: Enum.count(selected_verbs)
     }}
  end

  @impl GenServer
  def handle_call(:next_card, _from, state) do
    next_card = Enum.random(state.verbs)

    details = %{
      session_id: state.session_id,
      card_scores: state.card_scores
    }

    {:reply, {:ok, {next_card, details}}, state}
  end

  @impl GenServer
  def handle_call({:update, %{card_id: card_id, ease: ease}}, _from, state) do
    # %{39 => %{easy_count: 0, hard_count: 0, medium_count: 0}}
    card_score_counts =
      if Map.has_key?(state.card_scores, card_id) do
        state.card_scores
      else
        Map.put(state.card_scores, card_id, %{
          easy_count: 0,
          medium_count: 0,
          hard_count: 0
        })
      end

    data = card_score_counts[card_id]

    updated_card_ease_count =
      case ease do
        "easy" -> %{data | easy_count: data.easy_count + 1}
        "medium" -> %{data | medium_count: data.medium_count + 1}
        "hard" -> %{data | hard_count: data.hard_count + 1}
        _ -> data
      end

    updated_card_scores = Map.put(state.card_scores, card_id, updated_card_ease_count)

    {:reply, :ok, %{state | card_scores: updated_card_scores}}
  end
end
