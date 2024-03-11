import gleam/dynamic.{type Decoder, type Dynamic}
import gleam/option.{type Option, None, Some}
import gleam/uri.{type Uri}
import gleam/json.{type DecodeError} as _
import glitch/api/json.{type Json}
import glitch/api/client.{type Client, Request}
import glitch/extended/dynamic_ext

pub type User {
  User(
    id: String,
    login: String,
    display_name: String,
    user_type: Type,
    broadcaster_type: BroadcasterType,
    description: String,
    profile_image_url: Uri,
    offline_image_url: Uri,
    view_count: Int,
    email: Option(String),
    created_at: String,
  )
}

fn decoder() {
  json.decode11(
    User,
    dynamic.field("id", dynamic.string),
    dynamic.field("login", dynamic.string),
    dynamic.field("display_name", dynamic.string),
    dynamic.field("type", dynamic.string),
    dynamic.field("broadcaster_type", dynamic.string),
    dynamic.field("description", dynamic.string),
    dynamic.field("profile_image_url", dynamic_ext.uri),
    dynamic.field("offline_image_url", dynamic_ext.uri),
    dynamic.field("view_count", dynamic.int),
    dynamic.field("email", dynamic.optional(dynamic.string)),
    dynamic.field("created_at", dynamic.string),
  )
}

pub fn to_json(user: User) -> Json {
  json.object([
    #("id", json.string(user.id)),
    #("login", json.string(user.login)),
    #("display_name", json.string(user.display_name)),
    #("type", json.string(user.user_type)),
    #("broadcaster_type", json.string(user.broadcaster_type)),
    #("description", json.string(user.description)),
    #("profile_image_url", json.uri(user.profile_image_url)),
    #("offline_image_url", json.uri(user.offline_image_url)),
    #("view_count", json.int(user.view_count)),
    #("email", json.option(user.email, json.string)),
    #("created_at", json.string(user.created_at)),
  ])
}

pub fn of_json(json_string: String) -> Result(User, DecodeError) {
  json.decode(json_string, decoder())
}

pub type Type =
  String

pub type BroadcasterType =
  String

pub type GetUsersRequest {
  GetUsersRequest(
    user_ids: Option(List(String)),
    user_logins: Option(List(String)),
  )
}

pub fn query_params_from_get_users_request(
  req: GetUsersRequest,
) -> Option(List(#(String, String))) {
  todo
}

pub type GetUsersError {
  DecodeError(DecodeError)
  RequestError
}

pub fn get_users(client: Client, request: GetUsersRequest) {
  client
  |> client.get(Request(body: None, headers: None, path: "users", query: None))
}
