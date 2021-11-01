defmodule Services.VerbManager do
  @moduledoc """
  An actor responsible for managing a specific vern &
  verb tenses.

  This actor is mainly a cache to import search query performance.
  """

  use GenServer
  use TypedStruct

  alias JapaneseVerbConjugation.Verbs
  alias JapaneseVerbConjugation.VerbTenses
  alias JapaneseVerbConjugation.VerbTenses.VerbTense

  typedstruct do
    field :hirigana_verb, String.t()
    field :tenses, list(VerbTense.t())
  end

  @spec start_link(any) :: {:ok, pid()} | {:error, term()}
  def start_link(name) do
    GenServer.start_link(__MODULE__, [name], name: :"#{name}")
  end

  def get_all_tenses(verb) do
    pid = Process.whereis(:"#{verb}")

    if is_nil(pid) do
      {:error, "PID not found for: #{verb}"}
    else
      GenServer.call(pid, :get_all_tenses)
    end
  end

  def get_tense(verb, tense, form \\ "Positive") do
    GenServer.call(verb, {:get_tense, {tense, form}})
  end

  @impl GenServer
  def init([name]) do
    verb = Verbs.get_by_base(name)
    tenses = if !is_nil(verb), do: VerbTenses.get_tenses_for_verb(verb.id)

    {:ok, %__MODULE__{hirigana_verb: name, tenses: tenses}}
  end

  @impl GenServer
  def handle_call(:get_all_tenses, _from, state) do
    {:reply, {:ok, state.tenses}, state}
  end

  @impl GenServer
  def handle_call({:get_tense, {tense, form}}, _from, state) do
    is_found =
      Enum.find(state.tenses, fn t ->
        t.tense == tense and t.form == form
      end)

    {:reply, {:ok, is_found}, state}
  end
end
