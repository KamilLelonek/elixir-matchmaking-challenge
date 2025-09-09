defmodule MatchmakingChallengeWeb.MatchmakingController do
  use MatchmakingChallengeWeb, :controller

  alias MatchmakingChallenge.Balancer

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"clubs" => clubs, "bucket_size" => bucket_size})
      when is_list(clubs) do
    render(conn, buckets: Balancer.split_into_buckets(clubs, bucket_size))
  end
end
