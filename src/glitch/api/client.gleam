import gleam/dynamic.{type Dynamic}
import gleam/list
import gleam/pair
import gleam/http.{type Header, type Method, Get, Https}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/httpc
import gleam/json.{type Json}
import glitch/extended/request_ext

const host = "api.twitch.tv/helix"

pub opaque type Client {
  Client(options: Options)
}

pub type Options {
  Options(client_id: String, access_token: String)
}

pub type ApiError {
  RequestError
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

  [#("Client-Id", client_id), #("Authorization", access_token)]
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

fn prepare_request(
  client: Client,
  method: Method,
  request: Request(Json),
) -> Request(String) {
  let headers =
    client
    |> headers
    |> merge_headers(request.headers)

  let body =
    request.body
    |> json.to_string

  request.new()
  |> request.set_method(method)
  |> request_ext.set_headers(headers)
  |> request.set_scheme(Https)
  |> request.set_host(host)
  |> request.set_body(body)
  |> request.set_path(request.path)
  |> request_ext.set_query_string(request.query)
}

pub fn get(
  client: Client,
  request: Request(Json),
) -> Result(Response(String), Dynamic) {
  client
  |> prepare_request(Get, request)
  |> httpc.send
}
