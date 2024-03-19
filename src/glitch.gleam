import gleam/option.{None}
import gleam/result
import dot_env/env
import glitch/api/client.{Options}
import glitch/api/chat.{SendMessageRequest}

const user_id = "209286766"

pub fn main() {
  use client_id <- result.try(env.get("CLIENT_ID"))
  use access_token <- result.try(env.get("ACCESS_TOKEN"))
  let client_options = Options(client_id: client_id, access_token: access_token)
  let client = client.new(client_options)

  let send_message_request =
    SendMessageRequest(
      broadcaster_id: user_id,
      sender_id: user_id,
      message: "Hello Twitter from Glitch and Gleam!",
      reply_parent_message_id: None,
    )

  let assert Ok(_) = chat.send_message(client, send_message_request)

  Ok(Nil)
}
