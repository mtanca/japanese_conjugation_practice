defmodule JapaneseVerbConjugationWeb.Router do
  use JapaneseVerbConjugationWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/decks", JapaneseVerbConjugationWeb do
    pipe_through :api

    get "/", DeckController, :index
  end

  scope "/search", JapaneseVerbConjugationWeb do
    pipe_through :api

    post "/", SearchController, :search
    get "/all", SearchController, :index
  end

  scope "/study-sessions", JapaneseVerbConjugationWeb do
    pipe_through :api

    put "/:session_id", StudySessionControllerController, :update
    get "/:session_id/details", StudySessionControllerController, :get

    post "/", StudySessionControllerController, :create
  end

  scope "/", JapaneseVerbConjugationWeb do
    pipe_through :browser

    get "/*path", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", JapaneseVerbConjugationWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: JapaneseVerbConjugationWeb.Telemetry
    end
  end
end
