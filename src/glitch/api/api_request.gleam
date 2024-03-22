import gleam/result
import gleam/http.{type Header, Https}
import gleam/http/request.{type Request, Request}
import gleam/http/response.{type Response}
import gleam/httpc
import glitch/api/error.{type TwitchApiError, RequestError}
import glitch/extended/request_ext

pub opaque type TwitchApiRequest {
  ApiRequest(Request(String))
  IdApiRequest(Request(String))
}

const api_host = "api.twitch.tv"

const id_api_host = "id.twitch.tv"

fn api_request_from_request(request: Request(String)) -> TwitchApiRequest {
  ApiRequest(request)
}

fn id_api_request_from_request(request: Request(String)) -> TwitchApiRequest {
  IdApiRequest(request)
}

pub fn new_api_request() -> TwitchApiRequest {
  request.new()
  |> request.set_scheme(Https)
  |> request.set_host(api_host)
  |> api_request_from_request
}

pub fn new_id_api_request() {
  request.new()
  |> request.set_scheme(Https)
  |> request.set_host(id_api_host)
  |> id_api_request_from_request
}

pub fn to_http_request(request: TwitchApiRequest) -> Request(String) {
  case request {
    ApiRequest(http_request) -> http_request
    IdApiRequest(http_request) -> http_request
  }
}

pub fn send(
  request: TwitchApiRequest,
) -> Result(Response(String), TwitchApiError(error)) {
  request
  |> to_http_request
  |> httpc.send
  |> result.map_error(RequestError)
}

pub fn set_headers(
  request: TwitchApiRequest,
  headers: List(Header),
) -> TwitchApiRequest {
  let set_headers_internal = fn(request, headers) {
    request
    |> to_http_request
    |> request_ext.set_headers(headers)
  }

  case request {
    ApiRequest(_) as http_request ->
      http_request
      |> set_headers_internal(headers)
      |> ApiRequest
    IdApiRequest(_) as http_request ->
      http_request
      |> set_headers_internal(headers)
      |> ApiRequest
  }
}

pub fn set_header(request, header) {
  let set_header_internal = fn(request, header) {
    request
    |> to_http_request
    |> request_ext.set_header(header)
  }

  case request {
    ApiRequest(_) as http_request ->
      http_request
      |> set_header_internal(header)
      |> ApiRequest
    IdApiRequest(_) as http_request ->
      http_request
      |> set_header_internal(header)
      |> ApiRequest
  }
}

pub fn set_method(request, method) {
  case request {
    ApiRequest(http_request) ->
      ApiRequest(Request(..http_request, method: method))
    IdApiRequest(http_request) ->
      IdApiRequest(Request(..http_request, method: method))
  }
}

pub fn set_query(request, query_params) {
  case request {
    ApiRequest(http_request) ->
      http_request
      |> request.set_query(query_params)
      |> ApiRequest
    IdApiRequest(http_request) ->
      http_request
      |> request.set_query(query_params)
      |> IdApiRequest
  }
}

pub fn set_body(request, body) {
  case request {
    ApiRequest(http_request) -> ApiRequest(Request(..http_request, body: body))
    IdApiRequest(http_request) ->
      IdApiRequest(Request(..http_request, body: body))
  }
}

pub fn set_path(request, path) {
  case request {
    ApiRequest(http_request) -> ApiRequest(Request(..http_request, path: path))
    IdApiRequest(http_request) ->
      IdApiRequest(Request(..http_request, path: path))
  }
}
