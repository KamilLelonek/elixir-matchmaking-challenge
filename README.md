# Matchmaking Challenge

## Premise

In this challenge we want to create a matchmaking service for clubs.
Clubs is a concept which allows a group of people to play together and to reach some shared goals.
One of these shared goals is to compete against other clubs in "Club Competitions" and win in-game prizes.
We want to group clubs together into buckets, so that they can compete against each other in smaller divisions instead of globally against all other clubs.
The purpose of this matchmaking service is to group clubs together into buckets.

Let's look at an example. Given a list of clubs
`[club1, club2, club3, club4, club5]`
and a bucket size `bucket_size = 2`
one result could be `[[club1, club2], [club3, club4], [club5]]`.

Or, if we introduce some randomness, it might be this: `[[club4, club1], [club3, club5], [club2]]`.

## Description

This project already defines an HTTP endpoint `POST /matchmaking` which performs the simple matchmaking logic outlined above. The endpoint works like this:

The `POST /matchmaking` endpoint expects a request body in JSON format following this structure:
```json
{
  "bucket_size": 2,
  "clubs": [
    {"id": 1, "member_count": 13, "previous_score": 40},
    {"id": 2, "member_count": 10, "previous_score": 10},
    {"id": 3, "member_count": 13, "previous_score": 40},
    {"id": 4, "member_count": 10, "previous_score": 10}
  ]
}
```
* Every entity in the `clubs` array should contain a unique `id` and can optionally contain extra metadata for a club like the member count and scores from a previous competition.

As `bucket_size` is 2, the resulting list of buckets in the response would look like this:

```json
{
  "buckets": [
    {
      "metadata": {"size": 2},
      "clubs": [{"id": 1}, {"id": 2}]
    },
    {
      "metadata": {"size": 2},
      "clubs": [{"id": 3}, {"id": 4}]
    }
  ]
}
```

- `metadata` contains information about the bucket
- `clubs` references the clubs that are grouped together

## Requirements

## Step 1
Get the project up and running ([see below](#how-to-run)):
* install dependencies
* run the tests
* run the server
* make an HTTP request to the server

## Step 2
Change the current algorithm to make things a bit more interesting during the matchmaking,
by grouping clubs randomly and keeping the buckets balanced.
"Balanced" means that the difference in size between buckets is 1 or 0, i.e. the bucket size is largely uniform.

- Unbalanced bucket example with max size of 4: `[[x,x,x,x], [x,x,x,x],[x,x]]`
- Balanced bucket example with max size of 4: `[[x,x,x,x], [x,x,x], [x,x,x]]`

In the example below, for the same data the order is random and bucket are still balanced
```
POST:
{
  "clubs": [
    {"id": 1, "member_count": 13, "previous_score": 40},
    {"id": 2, "member_count": 10, "previous_score": 10},
    {"id": 3, "member_count": 13, "previous_score": 40},
    {"id": 4, "member_count": 10, "previous_score": 10}
  ]
}

RESPONSE:
{
  "buckets": [
    {
      "clubs": [{"id": 1}, {"id": 4}],
      "metadata": {"size": 2}
    },
    {
      "clubs": [{"id": 2}, {"id": 3}],
      "metadata": {"size": 2}
    }
  ]
}
```

Let's suppose we have 10 clubs and we want to create buckets of 4. For simplicity let's name clubs `[C1, ... , C10]`
Once our api is called
 - a random balanced response would look like: `[[C3, C2, C10, C4], [C1, C9, C6], [C8, C5, C7]]`
 - a random NON balanced response looks like: `[C9, C4, C7, C1], [C3, C8, C10, C6], [C2, C5]` because between the first and last bucket
 there is a difference of 2 elements

## How to run
### Locally

Install Elixir 1.10.1 and Node 10. You can do this by installing [`asdf`](https://github.com/asdf-vm/asdf-elixir) and running `asdf install`.

Then, install Elixir's package manager and web-framework helpers with:
```shell
mix local.hex
mix local.rebar
mix archive.install hex phx_new 1.4.14
```

Then, install dependencies and run the project:

```shell
mix deps.get
mix test
mix phx.server
```
- Install dependencies `mix deps.get`
- Run tests `mix test`
- Run server `mix phx.server`

### Docker
Make sure to have `docker-compose` installed
```shell
make start
```
