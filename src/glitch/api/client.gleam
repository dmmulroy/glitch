import gleam/list
import gleam/io
import gleam/function
import gleam/pair
import gleam/result
import gleam/uri
import gleam/http.{type Header, Get, Post}
import gleam/http/request.{type Request, Request}
import gleam/http/response.{type Response}
import gleam/httpc
import glitch/api/api_request.{type TwitchApiRequest}
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

pub fn get(
  client: Client,
  request: TwitchApiRequest,
) -> Result(Response(String), TwitchApiError(error)) {
  todo
  // let headers =
  //   client
  //   |> headers
  //   |> merge_headers(request.headers)
  //
  // request
  // |> request.set_method(Get)
  // |> request_ext.set_headers(headers)
  // |> api_request.from_request
  // |> httpc.send
  // |> result.map_error(RequestError)
}

pub fn post(
  client: Client,
  request: Request(String),
) -> Result(Response(String), TwitchApiError(error)) {
  // let headers =
  //   client
  //   |> headers
  //   |> merge_headers(request.headers)
  //
  // request
  // |> request.set_method(Post)
  // |> request_ext.set_headers(headers)
  // |> api_request.from_request
  // |> function.tap(fn(req) {
  //   io.debug(
  //     request.to_uri(req)
  //     |> uri.to_string,
  //   )
  // })
  // |> httpc.send
  // |> result.map_error(RequestError)
  todo
}
