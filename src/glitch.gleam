import gleam/option.{None, Some}
import gleam/result
import dot_env/env
import pprint
import glitch/api/client.{Options}
import glitch/api/user.{GetUsersRequest}
import glitch/api/chat.{SendMessageRequest}

const user_id = "209286766"

pub fn main() {
  use client_id <- result.try(env.get("CLIENT_ID"))
  use access_token <- result.try(env.get("ACCESS_TOKEN"))
  let client_options = Options(client_id: client_id, access_token: access_token)
  let client = client.new(client_options)

  let get_users_request =
    GetUsersRequest(user_ids: None, user_logins: Some(["dmmulroy"]))

  let result = user.get_users(client, get_users_request)

  pprint.debug(result)

  let send_message_request =
    SendMessageRequest(
      broadcaster_id: user_id,
      sender_id: user_id,
      message: "Hello from Glitch and Gleam!",
      reply_parent_message_id: None,
    )

  let result = chat.send_message(client, send_message_request)

  pprint.debug(result)
  Ok(Nil)
}
