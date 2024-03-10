import gleam/option.{type Option}
import gleam/uri.{type Uri}
// import gleam/httpc
// import gleam/http.{Get}
import gleam/http/request
// import gleam/http/response
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

pub type Type

pub type BroadcasterType

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
