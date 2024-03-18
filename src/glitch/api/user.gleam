import gleam/dynamic.{type Decoder}
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/uri.{type Uri}
import gleam/json.{type DecodeError, type Json}
import gleam/http/request
import gleam/http/response.{type Response}
import glitch/api/client.{type Client}
import glitch/extended/dynamic_ext
import glitch/extended/function_ext
import glitch/extended/json_ext

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

pub type GetUsersError {
  DecodeError(DecodeError)
  RequestError
}

pub type TwitchApiResponse(data) {
  TwitchApiResponse(data: List(data))
}

fn twitch_api_response_decoder(
  of data_decoder: Decoder(data),
) -> Decoder(TwitchApiResponse(data)) {
  dynamic.decode1(
    TwitchApiResponse,
    dynamic.field("data", dynamic.list(of: data_decoder)),
  )
}

fn twitch_api_response_from_json(
  json_string: String,
  of data_decoder: Decoder(data),
) {
  json.decode(json_string, twitch_api_response_decoder(data_decoder))
}

fn twitch_api_response_data(api_response: TwitchApiResponse(data)) -> List(data) {
  api_response.data
}

fn twitch_api_response_from_response(
  response: Response(TwitchApiResponse(data)),
) -> Result(Response(List(data)), error) {
  response
  |> response.try_map(function_ext.compose(twitch_api_response_data, Ok))
}

pub fn get_users(
  client: Client,
  request: GetUsersRequest,
) -> Result(Response(List(User)), GetUsersError) {
  let request =
    request.new()
    |> request.set_body(json.string(""))
    |> request.set_query(query_params_from_get_users_request(request))
    |> request.set_path("users")

  use response <- result.try(
    client
    |> client.get(request)
    |> result.replace_error(RequestError),
  )

  response
  |> response.try_map(twitch_api_response_from_json(_, of: decoder()))
  |> result.try(twitch_api_response_from_response)
  |> result.map_error(DecodeError)
}
