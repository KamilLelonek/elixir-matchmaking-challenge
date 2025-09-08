defmodule MatchmakingChallengeWeb.Router do
  use MatchmakingChallengeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MatchmakingChallengeWeb do
    pipe_through :api

    post "/matchmaking", MatchmakingController, :create
  end
end
