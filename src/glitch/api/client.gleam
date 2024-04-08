import gleam/result
import gleam/http.{type Header, Get, Post}
import glitch/api/api
import glitch/api/api_request.{type TwitchApiRequest}
import glitch/api/api_response.{type TwitchApiResponse}
import glitch/auth/auth_provider.{type AuthProvider}
import glitch/types/access_token.{type AccessToken}
import glitch/error.{type TwitchError}

pub opaque type Client {
  Client(auth_provider: AuthProvider)
}

pub fn new(auth_provider: AuthProvider) -> Client {
  Client(auth_provider)
}

pub fn client_id(client: Client) -> String {
  auth_provider.client_id(client.auth_provider)
}

pub fn access_token(client: Client) -> Result(AccessToken, TwitchError) {
  auth_provider.access_token(client.auth_provider)
}

fn headers(client: Client) -> Result(List(Header), TwitchError) {
  let client_id = auth_provider.client_id(client.auth_provider)

  use access_token <- result.try(access_token(client))

  let authorization = "Bearer " <> access_token.token(access_token)

  Ok([
    #("Authorization", authorization),
    #("Client-Id", client_id),
    #("Content-Type", "application/json"),
  ])
}

pub fn get(
  client: Client,
  request: TwitchApiRequest,
) -> Result(TwitchApiResponse(String), TwitchError) {
  use headers <- result.try(headers(client))

  request
  |> api_request.merge_headers(headers, api_request.headers(request))
  |> api_request.set_method(Get)
  |> api.send
}

pub fn post(
  client: Client,
  request: TwitchApiRequest,
) -> Result(TwitchApiResponse(String), TwitchError) {
  use headers <- result.try(headers(client))

  request
  |> api_request.merge_headers(headers, api_request.headers(request))
  |> api_request.set_method(Post)
  |> api.send
}
