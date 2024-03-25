import gleam/http.{type Header, Get, Post}
import glitch/api/api
import glitch/api/api_request.{type TwitchApiRequest}
import glitch/api/api_response_v2.{type TwitchApiResponse}
import glitch/api/error.{type TwitchApiError}

pub opaque type Client {
  Client(options: Options)
}

pub type Options {
  Options(client_id: String, access_token: String)
}

pub const new = Client

pub fn client_id(client: Client) -> String {
  client.options.client_id
}

pub fn access_token(client: Client) -> String {
  client.options.access_token
}

pub fn headers(client: Client) -> List(Header) {
  let client_id = client_id(client)
  let access_token = "Bearer " <> access_token(client)

  [
    #("Authorization", access_token),
    #("Client-Id", client_id),
    #("content-type", "application/json"),
  ]
}

pub fn get(
  client: Client,
  request: TwitchApiRequest,
) -> Result(TwitchApiResponse(String), TwitchApiError(error)) {
  request
  |> api_request.set_headers(headers(client))
  |> api_request.set_method(Get)
  |> api.send
}

pub fn post(
  client: Client,
  request: TwitchApiRequest,
) -> Result(TwitchApiResponse(String), TwitchApiError(error)) {
  request
  |> api_request.set_headers(headers(client))
  |> api_request.set_method(Post)
  |> api.send
}
