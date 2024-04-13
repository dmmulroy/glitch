import dot_env/env
import gleam/erlang/process
import gleam/function
import gleam/io
import gleam/option.{None}
import glitch/api/chat.{SendMessageRequest}
import glitch/api/client
import glitch/auth/auth_provider
import glitch/auth/token_fetcher
import glitch/eventsub/eventsub
import glitch/types/access_token
import glitch/types/scope

pub fn get_access_token() {
  let assert Ok(client_id) = env.get("CLIENT_ID")
  let assert Ok(client_secret) = env.get("CLIENT_SECRET")
  let scopes = [
    scope.ChannelBot,
    scope.ChannelReadSubscriptions,
    scope.ChatRead,
    scope.UserBot,
    scope.UserReadChat,
    scope.UserWriteChat,
  ]

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

fn new_client() {
  let assert Ok(access_token_str) = env.get("ACCESS_TOKEN")
  let assert Ok(refresh_token_str) = env.get("REFRESH_TOKEN")
  let assert Ok(client_id) = env.get("CLIENT_ID")
  let assert Ok(client_secret) = env.get("CLIENT_SECRET")
  let scopes = [
    scope.ChannelBot,
    scope.ChannelReadSubscriptions,
    scope.ChatRead,
    scope.UserBot,
    scope.UserReadChat,
    scope.UserWriteChat,
  ]

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

  client.new(auth_provider)
}

pub fn test_chat() {
  let client = new_client()

  let send_msg_request =
    SendMessageRequest("209286766", "209286766", "Hello, chat!", None)

  let assert Ok(_) = chat.send_message(client, send_msg_request)
}

pub fn test_eventsub() {
  let eventsub = eventsub.new(new_client())
  let _ = eventsub.start(eventsub)

  process.sleep_forever()
}

pub fn main() {
  // get_access_token()
  // let _ = test_chat()
  test_eventsub()
}
