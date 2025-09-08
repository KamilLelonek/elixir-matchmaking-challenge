defmodule Mix.Tasks.GenerateClubs do
  use Mix.Task

  @shortdoc "Generates test data for the matchmaking challenge"
  def run(args \\ []) do
    opts = parse_args(args)

    generate_clubs(opts)
    |> write(opts)
  end

  defp parse_args(args) do
    {opts, _rest} =
      OptionParser.parse!(args,
        strict: [
          filename: :string,
          number_of_clubs: :integer
        ]
      )

    Keyword.merge(
      [
        filename: "clubs.json",
        number_of_clubs: 10
      ],
      opts
    )
  end

  defp generate_clubs(opts) do
    number_of_clubs = Keyword.fetch!(opts, :number_of_clubs)

    1..number_of_clubs
    |> Enum.map(fn _i ->
      member_count = member_count()

      %{
        club_id: rand_string(12),
        member_count: member_count,
        previous_score: score(member_count)
      }
    end)
  end

  defp member_count() do
    r = :rand.uniform()

    cond do
      # 40% clubs have 15 members (full)
      r < 0.4 -> 15
      # 10% clubs have 13 or 14 members
      r < 0.5 -> Enum.random(13..14)
      # 30% clubs have between 3 and 12 members
      r < 0.8 -> Enum.random(3..12)
      # 20% clubs have 1
      true -> Enum.random(1..2)
    end
  end

  defp score(member_count) do
    min_points_per_member = 40
    max_points_per_member = 100
    min_points = min_points_per_member * member_count
    max_points = max_points_per_member * member_count
    Enum.random(min_points..max_points)
  end

  defp write(data, opts) do
    filename = Keyword.fetch!(opts, :filename)
    File.write!(filename, Jason.encode!(data))
  end

  @base32_hex "0123456789abcdefghijklmnopqrstuv"
  defp rand_string(len, chars \\ @base32_hex) do
    char_count = chars |> String.length()

    for(_ <- 1..len, do: :rand.uniform(char_count) - 1)
    |> Enum.map(&(chars |> String.at(&1)))
    |> List.to_string()
  end
end
