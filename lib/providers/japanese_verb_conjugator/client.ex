defmodule Services.JapaneseVerbConjugator.Client do
  @moduledoc """
  A simple client to get verb data from www.japaneseverbconjugator.com
  """

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
    |> build_url()
    |> HTTPoison.get()
    |> handle_response()
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
    # Tenese should be in chunks of 3 <tr>
    tenses = Enum.chunk_every(rest, 3)

    response_data =
      Enum.reduce([headers, tenses], %{metadata: %{}, data: []}, fn content_type, acc ->
        data =
          Enum.reduce(content_type, %{metadata: %{}, data: []}, fn table_row, acc2 ->
            handle_parse(table_row, acc2)
          end)

        %{
          acc
          | metadata: Map.merge(acc.metadata, data.metadata),
            data: acc.data ++ data.data
        }
      end)

    {:ok, response_data}
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

  @doc """
  Contains the business logic to determine if the 'row_elements' should be
  processed / added to the metadata or the data/body field of the accumulator
  """
  @spec handle_parse(any(), map()) :: map()
  def handle_parse(row_elements, %{metadata: metadata, data: acc_data} = acc) do
    is_metadata? = Floki.find(row_elements, "th.VerbInfoLabel") != []

    if is_metadata? do
      updated_metadata = Map.merge(metadata, process_metadata_elements(row_elements))
      %{acc | metadata: updated_metadata}
    else
      updated_data = proccess_tense_data(row_elements)

      if is_nil(updated_data) do
        acc
      else
        %{acc | data: acc_data ++ [updated_data]}
      end
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

    romaji = Floki.find(row_elements, "span.romaji") |> Enum.map(&clean_text_in_element(&1))
    hirigana = Floki.find(row_elements, "a") |> Enum.map(&Floki.text(&1))

    mappings = Enum.zip(romaji, hirigana)

    # Presumptive tenses have 2 different options for positive types...
    grouped_by =
      if String.contains?(current_tense, "Presumptive") do
        {plain_positive, rest} = Enum.split(mappings, 2)
        {polite_positive, rest} = Enum.split(rest, 2)
        plain_neg = List.first(rest)
        polite_neg = List.last(rest)

        [plain_positive, polite_positive, plain_neg, polite_neg]
      else
        Enum.chunk_every(mappings, 1)
      end

    if current_tense != "" do
      %{
        tense: current_tense,
        meanings: get_meanings.(row_elements),
        plain_positive: Enum.at(grouped_by, 0),
        polite_positive: Enum.at(grouped_by, 1),
        plain_negative: Enum.at(grouped_by, 2),
        polite_negative: Enum.at(grouped_by, 3)
      }
    end
  end

  defp process_metadata_elements(html_element) do
    verb_class = fn text_value ->
      cond do
        String.contains?(text_value, "Godan") -> "Godan"
        String.contains?(text_value, "Ichidan") -> "Ichidan"
        true -> "Irregular"
      end
    end

    format = fn text_value ->
      String.split(text_value) |> Enum.join(" ")
    end

    header = Floki.find(html_element, "th") |> Floki.text()

    text_value = Floki.find(html_element, "td") |> Floki.text()

    text =
      case header do
        "Verb Class" -> verb_class.(text_value)
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
    |> String.replace(["?", "\r", "\n", "   "], "")
    |> String.trim()
    |> String.split(" ", trim: true)
    |> Enum.join(" ")
  end

  @doc """
  Builds the request url given the verb being searched
  """
  @spec build_url(hirigana_verb()) :: String.t()
  def build_url(verb) do
    @base_url <> "VerbDetails.asp?txtVerb=" <> verb <> "&Go=Conjugate"
  end
end
