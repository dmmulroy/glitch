import gleam/list
import gleam/pair
import gleam/option.{type Option, None, Some}
import gleam/http.{type Header, type Method, Get, Https}
import gleam/http/request.{type Request as HttpRequest, Request as HttpRequest}
// import gleam/http/response.{type Response}
import gleam/httpc

const base_url = "https://api.twitch.tv/helix"

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
  let access_token = access_token(client)

  [#("client_id", client_id), #("access_token", access_token)]
}

pub type Request {
  Request(
    body: Option(String),
    headers: Option(List(Header)),
    path: String,
    query: Option(String),
  )
}

fn merge_headers(
  base_headers: List(Header),
  new_headers: Option(List(Header)),
) -> List(Header) {
  case new_headers {
    None -> base_headers
    Some(provided_headers) ->
      list.fold(provided_headers, base_headers, fn(acc, header) {
        let key = pair.first(header)
        let value = pair.second(header)
        list.key_set(acc, key, value)
      })
  }
}

fn to_http_request(
  client: Client,
  method: Method,
  request: Request,
) -> HttpRequest(String) {
  let headers =
    client
    |> headers
    |> merge_headers(request.headers)

  HttpRequest(
    method,
    headers,
    option.unwrap(request.body, ""),
    Https,
    base_url,
    None,
    request.path,
    request.query,
  )
}

pub fn get(client: Client, request: Request) {
  client
  |> to_http_request(Get, request)
  |> httpc.send
}
