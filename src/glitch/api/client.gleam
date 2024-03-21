import gleam/list
import gleam/pair
import gleam/result
import gleam/http.{type Header, Get, Post}
import gleam/http/request.{type Request, Request}
import gleam/http/response.{type Response}
import gleam/httpc
import glitch/api/api_request
import glitch/api/error.{type TwitchApiError, RequestError}
import glitch/extended/request_ext

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

fn merge_headers(
  base_headers: List(Header),
  new_headers: List(Header),
) -> List(Header) {
  list.fold(new_headers, base_headers, fn(acc, header) {
    let key = pair.first(header)
    let value = pair.second(header)
    list.key_set(acc, key, value)
  })
}

pub fn get(
  client: Client,
  request: Request(String),
) -> Result(Response(String), TwitchApiError(error)) {
  let headers =
    client
    |> headers
    |> merge_headers(request.headers)

  request
  |> request.set_method(Get)
  |> request_ext.set_headers(headers)
  |> api_request.from_request
  |> httpc.send
  |> result.map_error(RequestError)
}

pub fn post(
  client: Client,
  request: Request(String),
) -> Result(Response(String), TwitchApiError(error)) {
  let headers =
    client
    |> headers
    |> merge_headers(request.headers)

  request
  |> request.set_method(Post)
  |> request_ext.set_headers(headers)
  |> api_request.from_request
  |> httpc.send
  |> result.map_error(RequestError)
}
