import gleam/dynamic.{type Decoder}
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/uri.{type Uri}
import gleam/json.{type DecodeError, type Json}
import glitch/api/client.{type Client}
import glitch/api/api_request
import glitch/api/api_response
import glitch/extended/dynamic_ext
import glitch/extended/json_ext
import glitch/error/error.{type TwitchError}

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

fn decoder() -> Decoder(User) {
  dynamic_ext.decode11(
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
    dynamic.optional_field("email", dynamic.string),
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
    #("profile_image_url", json_ext.uri(user.profile_image_url)),
    #("offline_image_url", json_ext.uri(user.offline_image_url)),
    #("view_count", json.int(user.view_count)),
    #("email", json_ext.option(user.email, json.string)),
    #("created_at", json.string(user.created_at)),
  ])
}

pub fn from_json(json_string: String) -> Result(User, DecodeError) {
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
) -> List(#(String, String)) {
  let to_query_param_list = fn(input: #(String, Option(List(String)))) -> List(
    #(String, String),
  ) {
    input.1
    |> option.map(fn(values) {
      values
      |> list.map(fn(value) { #(input.0, value) })
    })
    |> option.unwrap([])
  }

  [#("id", req.user_ids), #("login", req.user_logins)]
  |> list.map(to_query_param_list)
  |> list.flatten
}

pub fn get_users(
  client: Client,
  request: GetUsersRequest,
) -> Result(List(User), TwitchError) {
  let request =
    api_request.new_helix_request()
    |> api_request.set_body("")
    |> api_request.set_query(query_params_from_get_users_request(request))
    |> api_request.set_path("helix/users")

  use response <- result.try(client.get(client, request))

  response
  |> api_response.get_list_data(decoder())
}
