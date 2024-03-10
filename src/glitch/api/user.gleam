import gleam/dynamic.{type Decoder, type Dynamic}
import gleam/function
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/uri.{type Uri}
import gleam/http/request
import glitch/api/json.{type DecodeError, type Json}
import glitch/api/client.{type Client}

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

fn decoder() {
  fn(dyn: Dynamic) {
    fn() {
      use id <- result.try(json.decode_string_field(dyn, "id"))
      use login <- result.try(json.decode_string_field(dyn, "login"))
      use display_name <- result.try(json.decode_string_field(
        dyn,
        "display_name",
      ))
      use user_type <- result.try(json.decode_string_field(dyn, "type"))
      use broadcaster_type <- result.try(json.decode_string_field(
        dyn,
        "broadcaster_type",
      ))
      use description <- result.try(json.decode_string_field(dyn, "description"))
      use profile_image_url <- result.try(json.decode_uri_field(
        dyn,
        "profile_image_url",
      ))
      use offline_image_url <- result.try(json.decode_uri_field(
        dyn,
        "offline_image_url",
      ))
      use view_count <- result.try(json.decode_int_field(dyn, "view_count"))
      let email =
        json.decode_string_field(dyn, "email")
        |> option.from_result
      use created_at <- result.try(json.decode_string_field(dyn, "created_at"))

      Ok(User(
        id,
        login,
        display_name,
        user_type,
        broadcaster_type,
        description,
        profile_image_url,
        offline_image_url,
        view_count,
        email,
        created_at,
      ))
    }()
    |> result.map_error(fn(_error) { [] })
  }
}

pub fn of_json(str: String) {
  json.decode(str, decoder())
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

// Nil -> Result(List(Users), idk_lol)
pub fn get_users(client: Client, request: GetUsersRequest) {
  request.to("https://foobar.com")
}
