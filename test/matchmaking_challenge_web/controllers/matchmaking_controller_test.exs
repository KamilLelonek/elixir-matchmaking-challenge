defmodule MatchmakingChallengeWeb.MatchmakingControllerTest do
  use MatchmakingChallengeWeb.ConnCase

  test "returns empty buckets when there is no data", %{conn: conn} do
    response =
      conn
      |> post("/matchmaking", %{bucket_size: 2, clubs: []})
      |> json_response(200)

    assert %{"buckets" => []} == response
  end

  test "returns clubs organized into buckets with correct structure", %{conn: conn} do
    data = %{
      bucket_size: 2,
      clubs: [
        %{id: 1, member_count: 13, previous_score: 40},
        %{id: 2, member_count: 10, previous_score: 10},
        %{id: 3, member_count: 10, previous_score: 20},
        %{id: 4, member_count: 10, previous_score: 10},
        %{id: 5, member_count: 10, previous_score: 10}
      ]
    }

    response =
      conn
      |> post("/matchmaking", data)
      |> json_response(200)

    %{"buckets" => buckets} = response

    # Test that we get the expected number of buckets (5 clubs ÷ 2 max size = 3 buckets)
    assert length(buckets) == 3

    # Test that all clubs are included (order may vary due to shuffle)
    all_club_ids =
      buckets
      |> Enum.flat_map(& &1["clubs"])
      |> Enum.map(& &1["id"])
      |> Enum.sort()

    assert all_club_ids == [1, 2, 3, 4, 5]

    # Test bucket structure and sizes
    bucket_sizes = Enum.map(buckets, & &1["metadata"]["size"])
    # Should be sorted by size due to even distribution
    assert bucket_sizes == [2, 2, 1]

    # Test that each bucket has the correct structure
    Enum.each(buckets, fn bucket ->
      assert Map.has_key?(bucket, "metadata")
      assert Map.has_key?(bucket, "clubs")
      assert Map.has_key?(bucket["metadata"], "size")

      assert is_list(bucket["clubs"])

      assert length(bucket["clubs"]) == bucket["metadata"]["size"]
    end)
  end

  test "returns clubs from generated file organized into buckets", %{conn: conn} do
    {:ok, body} = File.read("#{:code.priv_dir(:matchmaking_challenge)}/clubs_100.json")
    {:ok, clubs} = Jason.decode(body)

    data = %{bucket_size: 5, clubs: clubs}

    response =
      conn
      |> post("/matchmaking", data)
      |> json_response(200)

    %{"buckets" => buckets} = response

    # Test that we get the expected number of buckets (100 clubs ÷ 5 max size = 20 buckets)
    assert length(buckets) == 20

    # Test that all clubs are included
    all_club_ids =
      buckets
      |> Enum.flat_map(& &1["clubs"])
      |> Enum.map(& &1["id"])
      |> Enum.sort()

    expected_club_ids =
      clubs
      |> Enum.map(& &1["club_id"])
      |> Enum.sort()

    assert all_club_ids == expected_club_ids

    # Test bucket structure
    Enum.each(buckets, fn bucket ->
      assert Map.has_key?(bucket, "metadata")
      assert Map.has_key?(bucket, "clubs")
      assert Map.has_key?(bucket["metadata"], "size")

      assert is_list(bucket["clubs"])
      assert length(bucket["clubs"]) == bucket["metadata"]["size"]

      # Max bucket size
      assert bucket["metadata"]["size"] <= 5
    end)
  end

  test "handles single club correctly", %{conn: conn} do
    data = %{
      bucket_size: 3,
      clubs: [%{id: 1, member_count: 10, previous_score: 50}]
    }

    response =
      conn
      |> post("/matchmaking", data)
      |> json_response(200)

    %{"buckets" => buckets} = response

    assert length(buckets) == 1

    assert hd(buckets)["metadata"]["size"] == 1
    assert hd(buckets)["clubs"] == [%{"id" => 1}]
  end

  test "distributes clubs evenly across buckets", %{conn: conn} do
    # Test with 7 clubs and bucket size 3 to get uneven distribution
    data = %{
      bucket_size: 3,
      clubs: [
        %{id: 1},
        %{id: 2},
        %{id: 3},
        %{id: 4},
        %{id: 5},
        %{id: 6},
        %{id: 7}
      ]
    }

    response =
      conn
      |> post("/matchmaking", data)
      |> json_response(200)

    %{"buckets" => buckets} = response

    # Should have 3 buckets (7 ÷ 3 = 2.33, ceil = 3)
    assert length(buckets) == 3

    bucket_sizes = Enum.map(buckets, & &1["metadata"]["size"]) |> Enum.sort()
    # Should be distributed as [3, 2, 2] or similar even distribution
    assert bucket_sizes in [[2, 2, 3], [3, 2, 2], [2, 3, 2]]

    # All clubs should be included
    all_club_ids =
      buckets
      |> Enum.flat_map(& &1["clubs"])
      |> Enum.map(& &1["id"])
      |> Enum.sort()

    assert all_club_ids == [1, 2, 3, 4, 5, 6, 7]
  end

  test "produces different results on multiple calls due to randomness", %{conn: conn} do
    data = %{
      bucket_size: 2,
      clubs: [
        %{id: 1},
        %{id: 2},
        %{id: 3},
        %{id: 4}
      ]
    }

    # Make multiple requests and collect the first club in each bucket
    results =
      for _ <- 1..10 do
        response =
          conn
          |> post("/matchmaking", data)
          |> json_response(200)

        %{"buckets" => buckets} = response
        # Get the first club from the first bucket
        hd(buckets)["clubs"] |> hd() |> Map.get("id")
      end

    # With randomness, we should see different first clubs across calls
    # (though it's theoretically possible to get the same result, it's very unlikely)
    unique_results = Enum.uniq(results)
    assert length(unique_results) > 1
  end
end
