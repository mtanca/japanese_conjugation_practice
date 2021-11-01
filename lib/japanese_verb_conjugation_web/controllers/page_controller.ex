defmodule JapaneseVerbConjugationWeb.PageController do
  use JapaneseVerbConjugationWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
