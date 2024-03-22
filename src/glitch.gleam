import gleam/io
import gleam/option.{None}
// import gleam/result
import gleam/uri
import dot_env/env
import glitch/api/client.{Options}
import glitch/api/chat.{SendMessageRequest}
import glitch/api/auth.{AuthorizationCode, GetTokenRequest}

const user_id = "209286766"

pub fn main() {
  let assert Ok(client_id) = env.get("CLIENT_ID")
  let assert Ok(access_token) = env.get("ACCESS_TOKEN")
  let assert Ok(code) = env.get("CODE")
  let assert Ok(redirect_uri) = uri.parse("http://localhost:3030/twitch/oauth")

  let client_options = Options(client_id: client_id, access_token: access_token)
  let client = client.new(client_options)

  let send_message_request =
    SendMessageRequest(
      broadcaster_id: user_id,
      sender_id: user_id,
      message: "Hello Twitch Chat from Glitch and Gleam!",
      reply_parent_message_id: None,
    )

  let assert Ok(_) = chat.send_message(client, send_message_request)

  let get_token_request = GetTokenRequest(code, AuthorizationCode, redirect_uri)

  let assert Ok(response_result) = auth.get_token(client, get_token_request)

  io.debug(response_result)

  Ok(Nil)
}
