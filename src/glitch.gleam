import gleam/function
import gleam/option.{None}
import gleam/erlang/process
import dot_env/env
import glitch/auth/token_fetcher
import glitch/types/scope

pub fn main() {
  let assert Ok(client_id) = env.get("CLIENT_ID")
  let assert Ok(client_secret) = env.get("CLIENT_SECRET")
  let scopes = [scope.UserWriteChat, scope.UserBot, scope.ChannelBot]

  let mailbox = process.new_subject()

  let assert Ok(token_fetcher) =
    token_fetcher.new(client_id, client_secret, scopes, None)

  token_fetcher.fetch(token_fetcher, mailbox)

  let assert Ok(_access_token) =
    process.new_selector()
    |> process.selecting(mailbox, function.identity)
    |> process.select_forever

  Ok(Nil)
}
