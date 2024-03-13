import gleam/io
import gleam/option.{None, Some}
import gleam/result
import dot_env/env
import glitch/api/client.{Options}
import glitch/api/user.{GetUsersRequest}

pub fn main() {
  use client_id <- result.try(env.get("CLIENT_ID"))
  use access_token <- result.try(env.get("ACCESS_TOKEN"))
  let client_options = Options(client_id: client_id, access_token: access_token)
  let client = client.new(client_options)

  let get_users_request =
    GetUsersRequest(user_ids: None, user_logins: Some(["dmmulroy"]))

  let result = user.get_users(client, get_users_request)

  io.debug(result)
  Ok(Nil)
}
