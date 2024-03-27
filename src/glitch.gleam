import gleam/io
import gleam/option.{None, Some}
import gleam/uri
import dot_env/env
import glitch/api/client
import glitch/api/chat.{SendMessageRequest}
import glitch/api/auth

const user_id = "209286766"

pub fn main() {
  let assert Ok(client_id) = env.get("CLIENT_ID")
  let assert Ok(client_secret) = env.get("CLIENT_SECRET")
  let assert Ok(access_token) = env.get("ACCESS_TOKEN")
  let assert Ok(code) = env.get("CODE")
  let assert Ok(redirect_uri) = uri.parse("http://localhost:3030/twitch/oauth")

  let client =
    client.new(
      client_id: client_id,
      client_secret: Some(client_secret),
      access_token: Some(access_token),
      refresh_token: None,
    )

  let send_message_request =
    SendMessageRequest(
      broadcaster_id: user_id,
      sender_id: user_id,
      message: "Hello Twitch Chat from Glitch and Gleam!",
      reply_parent_message_id: None,
    )

  let assert Ok(_) = chat.send_message(client, send_message_request)

  let get_token_request =
    auth.new_authorization_code_grant_request(
      client_id,
      client_secret,
      code,
      redirect_uri,
    )

  let assert Ok(response_result) = auth.get_token(client, get_token_request)

  io.debug(response_result)

  Ok(Nil)
}
