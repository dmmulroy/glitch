import gleam/list
import gleam/pair
import gleam/option.{type Option, None, Some}
import gleam/uri
import gleam/http.{type Header, type Method, Get}
import gleam/http/request.{type Request as HttpRequest, Request as HttpRequest}
import gleam/httpc
import glitch/api/json.{type Json}
import glitch/extended/request_ext

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
    body: Option(Json),
    headers: Option(List(Header)),
    path: String,
    query: Option(List(#(String, String))),
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
  req: Request,
) -> HttpRequest(String) {
  let headers =
    client
    |> headers
    |> merge_headers(req.headers)

  let body =
    req.body
    |> option.map(json.to_string)
    |> option.unwrap("")

  let query =
    option.map(req.query, fn(params) {
      list.map(params, fn(param) {
        let key = pair.first(param)
        let value = pair.second(param)

        #(uri.percent_encode(key), uri.percent_encode(value))
      })
    })
    |> option.unwrap([])

  request.new()
  |> request.set_method(method)
  |> request_ext.set_headers(headers)
  |> request.set_body(body)
  |> request.set_host(base_url)
  |> request.set_path(req.path)
  |> request.set_query(query)
}

pub fn get(client: Client, request: Request) {
  client
  |> to_http_request(Get, request)
  |> httpc.send
}
