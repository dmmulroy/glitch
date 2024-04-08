import gleam/option.{type Option, Some}
import gleam/result
import gleam/http.{type Header, Get, Post}
import glitch/api/api
import glitch/api/api_request.{type TwitchApiRequest}
import glitch/api/api_response.{type TwitchApiResponse}
import glitch/error.{
  type ClientError, type TwitchError, ClientError, NoAccessToken,
  NoClientSecret, NoRefreshToken,
}

pub opaque type Client {
  Client(
    client_id: String,
    client_secret: Option(String),
    access_token: Option(String),
    refresh_token: Option(String),
  )
}

pub fn new(
  client_id client_id: String,
  client_secret client_secret: Option(String),
  access_token access_token: Option(String),
  refresh_token refresh_token: Option(String),
) -> Client {
  Client(client_id, client_secret, access_token, refresh_token)
}

pub fn client_id(client: Client) -> String {
  client.client_id
}

pub fn set_client_id(client, client_id: String) -> Client {
  Client(..client, client_id: client_id)
}

pub fn client_secret(client: Client) -> Result(String, TwitchError) {
  option.to_result(client.client_secret, ClientError(NoClientSecret))
}

pub fn set_client_secret(client, client_secret: String) -> Client {
  Client(..client, client_secret: Some(client_secret))
}

pub fn client_credentials(
  client: Client,
) -> Result(#(String, String), TwitchError) {
  use client_secret <- result.try(option.to_result(
    client.client_secret,
    ClientError(NoClientSecret),
  ))

  Ok(#(client.client_id, client_secret))
}

pub fn access_token(client: Client) -> Result(String, TwitchError) {
  option.to_result(client.access_token, ClientError(NoAccessToken))
}

pub fn set_access_token(client, access_token: String) -> Client {
  Client(..client, access_token: Some(access_token))
}

pub fn refresh_token(client: Client) -> Result(String, TwitchError) {
  option.to_result(client.refresh_token, ClientError(NoRefreshToken))
}

pub fn set_refresh_token(client, refresh_token: String) -> Client {
  Client(..client, refresh_token: Some(refresh_token))
}

fn headers(client: Client) -> Result(List(Header), TwitchError) {
  let client_id = client.client_id

  use access_token <- result.try(option.to_result(
    client.access_token,
    ClientError(NoAccessToken),
  ))

  let authorization = "Bearer " <> access_token

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
