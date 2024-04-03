import gleam/function
import gleam/option.{None, Some}
import gleam/erlang/process
import dot_env/env
import glitch/api/client
import glitch/auth/token_fetcher

pub fn main() {
  let assert Ok(client_id) = env.get("CLIENT_ID")
  let assert Ok(client_secret) = env.get("CLIENT_SECRET")

  let mailbox = process.new_subject()

  let client = client.new(client_id, Some(client_secret), None, None)

  let assert Ok(token_fetcher) = token_fetcher.new(client, None)

  token_fetcher.fetch(token_fetcher, mailbox)

  let assert Ok(_access_token) =
    process.new_selector()
    |> process.selecting(mailbox, function.identity)
    |> process.select_forever

  Ok(Nil)
}
