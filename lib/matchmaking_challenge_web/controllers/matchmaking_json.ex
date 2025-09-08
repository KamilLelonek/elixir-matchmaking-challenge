defmodule MatchmakingChallengeWeb.MatchmakingJSON do
  @doc """
  Renders JSON output for matchmaking
  """
  def create(%{buckets: buckets}) do
    %{buckets: buckets}
  end
end
