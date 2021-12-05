defmodule Services.JapaneseVerbConjugator.Client do
  @moduledoc """
  A simple client to get verb data from www.japaneseverbconjugator.com
  """

  alias JapaneseVerbConjugation.Verbs

  @base_url "http://www.japaneseverbconjugator.com/"

  @type hirigana_verb :: String.t()

  @type verb_type :: {romaji :: String.t(), hirigana :: String.t()}

  @type verb_detail :: %{
          required(:meanings) => map(),
          required(:plain_negative) => list(verb_type),
          required(:plain_positive) => list(verb_type),
          required(:polite_negative) => list(verb_type),
          required(:polite_positive) => list(verb_type),
          required(:tense) => String.t()
        }

  @type verb_details :: %{
          required(:data) => list(verb_detail()),
          required(:metadata) => map()
        }

  @type client_error :: %{
          required(:reason) => String.t(),
          optional(:additional_details) => map()
        }

  @spec get(hirigana_verb()) :: {:ok, verb_details()} | {:error, client_error()}
  def get(verb) do
    verb
    |> build_url(:get)
    |> HTTPoison.get()
    |> handle_response()
  end

  def all() do
    endpoint = "JVerbList.asp"

    with url <- build_url(endpoint, :all),
         {:ok, response_data} <- HTTPoison.get(url) do
      {:ok, document} = Floki.parse_document(response_data.body)

      document
      |> Floki.find("td")
      |> Enum.split(7)
      |> elem(1)
      |> Enum.chunk_every(6)
      |> Enum.map(fn data ->
        plain_base = fn ->
          first_check = Floki.find(data, "div.JScript") |> Floki.text()
          if first_check == "", do: Floki.find(data, "span") |> Floki.text(), else: first_check
        end

        Verbs.create_verb(%{
          "romaji" => Enum.at(data, 0) |> Floki.text(),
          "plain_base" => plain_base.(),
          "class" => Enum.at(data, 3) |> Floki.text() |> verb_class(),
          "meaning" => Enum.at(data, 2) |> Floki.text()
        })
      end)
    end
  end

  @spec handle_response({:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}) ::
          {:ok, verb_details()} | {:error, client_error()}
  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: html}}) do
    {:ok, document} = Floki.parse_document(html)

    content = Floki.find(document, "table tr")

    # Header/Metadata are the first 4 rows of the table...
    {headers, rest} = Enum.split(content, 4)
    # Next 1 rows are for the Positive/Negative meanings
    {_meanings, rest} = Enum.split(rest, 1)

    {:ok, processed_data} = process_body(rest)

    processed_meta =
      Enum.reduce(headers, %{}, fn header, acc ->
        procesed_header = process_metadata_header(header)
        Map.merge(acc, procesed_header)
      end)

    {:ok, %{metadata: processed_meta, data: processed_data}}
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: code, body: body}})
      when code != 200 do
    additional_details = %{"body" => inspect(body), "status_code" => inspect(code)}

    error = %{
      reason: "http was success but did not return 200",
      additional_details: additional_details
    }

    {:error, error}
  end

  def handle_response({:error, %HTTPoison.Error{} = http_error}) do
    error = %{
      reason: "http error",
      additional_details: %{"message" => HTTPoison.Error.message(http_error)}
    }

    {:error, error}
  end

  def process_body(unprocessed_html, acc \\ [])

  def process_body([], acc) do
    {:ok, Enum.map(acc, &%{data: List.first(&1.data)})}
  end

  def process_body(unprocessed_html, acc) do
    next_chunk = Enum.take(unprocessed_html, 3)

    cond do
      # this chunk of html contains the meaning class,
      # meaning it should processed indiviually
      Floki.find(next_chunk, ".Meaning") != [] ->
        processed_chunk = handle_parse(next_chunk, %{data: []})
        {_next_chunk, rest} = Enum.split(unprocessed_html, 3)
        process_body(rest, [processed_chunk | acc])

      true ->
        # chunk by 2 for this...
        next_chunk = Enum.take(unprocessed_html, 2)
        processed_chunk = handle_parse(next_chunk, %{data: []})
        current_chunk_data = List.first(processed_chunk.data)

        # there is no more data to process!!!!
        if is_nil(current_chunk_data) do
          process_body([], acc)
        else
          # get the previous meaings and add it to this new chunk
          last_processed_meanings =
            acc
            |> List.first()
            |> Map.get(:data)
            |> List.first()
            |> Map.get(:meanings)

          updated_current_chunk_data =
            put_in(current_chunk_data.meanings, last_processed_meanings)

          updated_processed_chunk = %{processed_chunk | data: [updated_current_chunk_data]}

          {_next_chunk, rest} = Enum.split(unprocessed_html, 2)
          process_body(rest, [updated_processed_chunk | acc])
        end
    end
  end

  @doc """
  Contains the business logic to determine if the 'row_elements' should be
  processed / added to the metadata or the data/body field of the accumulator
  """
  @spec handle_parse(any(), map()) :: map()
  def handle_parse(row_elements, %{data: acc_data} = acc) do
    updated_data = proccess_tense_data(row_elements)

    if is_nil(updated_data) do
      acc
    else
      %{acc | data: acc_data ++ [updated_data]}
    end
  end

  @spec proccess_tense_data(any()) :: map() | nil
  defp proccess_tense_data(row_elements) do
    current_tense =
      row_elements
      |> Floki.find("td.OuterCell")
      |> clean_text_in_element()

    get_meanings = fn row_elements ->
      elements = Floki.find(row_elements, "td.Meaning")
      meanings = Enum.map(elements, &parse_meaning_element(&1))
      Enum.zip(["Positive", "Negative"], meanings) |> Enum.into(%{})
    end

    forms =
      Enum.reduce(row_elements, %{}, fn row_element, acc ->
        politness = Floki.find(row_element, ".MiddleCell") |> Floki.text() |> String.trim()
        contains_middlecell_element? = politness == ""

        with false <- contains_middlecell_element?,
             {_, _, data} <- row_element do
          forms_mapping =
            row_element
            |> Floki.find("td")
            |> Enum.with_index()
            |> Enum.filter(fn {d, _} -> d == {"td", [], []} end)
            |> process_td_element(data, politness)

          Map.put(acc, politness, forms_mapping)
        else
          _ -> acc
        end
      end)

    if forms != %{} do
      %{
        tense: current_tense,
        meanings: get_meanings.(row_elements),
        plain_positive: forms["Plain"].positive,
        plain_negative: forms["Plain"].negative,
        polite_positive: forms["Polite"].positive,
        polite_negative: forms["Polite"].negative
      }
    end
  end

  def process_td_element([{{"td", [], []}, 1}, {{"td", [], []}, 2}], _, _) do
    %{positive: nil, negative: nil}
  end

  def process_td_element([{{"td", [], []}, 3}], data, _) do
    positive_value = format_td_element(Enum.at(data, 2))
    %{positive: positive_value, negative: nil}
  end

  def process_td_element([], data, politness) do
    [pos_position, neg_position] =
      case politness do
        "Plain" -> [2, 3]
        "Polite" -> [1, 2]
      end

    %{
      positive: format_td_element(Enum.at(data, pos_position)),
      negative: format_td_element(Enum.at(data, neg_position))
    }
  end

  def format_td_element(value) do
    value
    |> clean_text_in_element()
    |> String.split()
  end

  defp process_metadata_header(html_element) do
    format = fn text_value ->
      String.split(text_value) |> Enum.join(" ")
    end

    header = Floki.find(html_element, "th") |> Floki.text()

    text_value = Floki.find(html_element, "td") |> Floki.text()

    text =
      case header do
        "Verb Class" -> verb_class(text_value)
        "Stem" -> format.(text_value)
        "Infinitive" -> format.(text_value)
        "Te form" -> format.(text_value)
        _ -> raise "unhandled header: #{header}"
      end

    %{"#{header}" => "#{text}"}
  end

  defp parse_meaning_element(html_element) do
    html_element
    |> Floki.find("td")
    |> Floki.text()
    |> String.trim()
  end

  defp clean_text_in_element(element) do
    element
    |> Floki.text()
    |> String.trim()
    |> String.replace(["?", "\r", "\n"], "")
    |> String.split(" ", trim: true)
    |> Enum.join(" ")
  end

  @doc """
  Builds the request url given the verb being searched
  """
  @spec build_url(hirigana_verb(), :get | :all) :: String.t()
  def build_url(verb, :get) do
    @base_url <> "VerbDetails.asp?txtVerb=" <> verb <> "&Go=Conjugate"
  end

  def build_url(endpoint, :all) do
    @base_url <> endpoint
  end

  def verb_class(text_value) do
    cond do
      String.contains?(text_value, "Godan") -> "Godan"
      String.contains?(text_value, "1") -> "Godan"
      String.contains?(text_value, "Ichidan") -> "Ichidan"
      String.contains?(text_value, "2") -> "Ichidan"
      true -> "Irregular"
    end
  end
end
