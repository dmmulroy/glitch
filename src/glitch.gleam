import gleam/function
import gleam/io
import gleam/option.{None}
import gleam/erlang/process
import dot_env/env
import glitch/api/client
import glitch/api/chat.{SendMessageRequest}
import glitch/auth/auth_provider
import glitch/auth/token_fetcher
import glitch/types/access_token
import glitch/types/scope

pub fn get_access_token() {
  let assert Ok(client_id) = env.get("CLIENT_ID")
  let assert Ok(client_secret) = env.get("CLIENT_SECRET")
  let scopes = [scope.UserWriteChat, scope.UserBot, scope.ChannelBot]

  let mailbox = process.new_subject()

  let assert Ok(token_fetcher) =
    token_fetcher.new(client_id, client_secret, scopes, None)

  token_fetcher.fetch(token_fetcher, mailbox)

  let assert Ok(access_token) =
    process.new_selector()
    |> process.selecting(mailbox, function.identity)
    |> process.select_forever

  io.debug(access_token)

  Ok(Nil)
}

pub fn test_chat() {
  let assert Ok(access_token_str) = env.get("ACCESS_TOKEN")
  let assert Ok(refresh_token_str) = env.get("REFRESH_TOKEN")
  let assert Ok(client_id) = env.get("CLIENT_ID")
  let assert Ok(client_secret) = env.get("CLIENT_SECRET")
  let scopes = [scope.UserWriteChat, scope.UserBot, scope.ChannelBot]

  let access_token =
    access_token.new_user_access_token(
      0,
      0,
      refresh_token_str,
      scopes,
      access_token_str,
      None,
    )

  let auth_provider =
    auth_provider.new_refreshing_provider(
      access_token,
      client_id,
      client_secret,
      None,
    )

  let client = client.new(auth_provider)

  let send_msg_request =
    SendMessageRequest("209286766", "209286766", "Hello, chat!", None)

  let assert Ok(_) = chat.send_message(client, send_msg_request)
}

pub fn main() {
  test_chat()
}
