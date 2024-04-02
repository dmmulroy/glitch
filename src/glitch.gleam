import gleam/function
import gleam/io
import gleam/option.{None, Some}
import gleam/erlang/process.{type Subject}
import dot_env/env
import glitch/api/client
import glitch/auth/token_fetcher
import glitch/types/access_token.{type AccessToken}

pub fn main() {
  let assert Ok(client_id) = env.get("CLIENT_ID")
  let assert Ok(client_secret) = env.get("CLIENT_SECRET")

  let mailbox: Subject(Result(AccessToken, Nil)) = process.new_subject()

  let client = client.new(client_id, Some(client_secret), None, None)

  let assert Ok(token_fetcher) = token_fetcher.new(client)

  token_fetcher.fetch(token_fetcher, mailbox)

  let assert Ok(access_token) =
    process.new_selector()
    |> process.selecting(mailbox, function.identity)
    |> process.select_forever

  io.debug(access_token)

  Ok(Nil)
}
