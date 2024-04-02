import gleam/http.{type Header, Https}
import gleam/http/request.{type Request, Request}
import glitch/extended/request_ext

pub opaque type TwitchApiRequest {
  HelixApiRequest(Request(String))
  AuthApiRequest(Request(String))
}

const api_host = "api.twitch.tv/helix"

const id_api_host = "id.twitch.tv"

fn api_request_from_request(request: Request(String)) -> TwitchApiRequest {
  HelixApiRequest(request)
}

fn auth_request_from_request(request: Request(String)) -> TwitchApiRequest {
  AuthApiRequest(request)
}

pub fn new_helix_request() -> TwitchApiRequest {
  request.new()
  |> request.set_scheme(Https)
  |> request.set_host(api_host)
  |> api_request_from_request
}

pub fn new_auth_request() -> TwitchApiRequest {
  request.new()
  |> request.set_scheme(Https)
  |> request.set_host(id_api_host)
  |> auth_request_from_request
}

pub fn to_http_request(request: TwitchApiRequest) -> Request(String) {
  case request {
    HelixApiRequest(http_request) -> http_request
    AuthApiRequest(http_request) -> http_request
  }
}

pub fn is_auth_request(request: TwitchApiRequest) -> Bool {
  case request {
    HelixApiRequest(_) -> False
    AuthApiRequest(_) -> True
  }
}

pub fn is_helix_request(request: TwitchApiRequest) -> Bool {
  case request {
    HelixApiRequest(_) -> True
    AuthApiRequest(_) -> False
  }
}

pub fn headers(request: TwitchApiRequest) -> List(Header) {
  to_http_request(request).headers
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
    HelixApiRequest(_) as http_request ->
      http_request
      |> set_headers_internal(headers)
      |> HelixApiRequest
    AuthApiRequest(_) as http_request ->
      http_request
      |> set_headers_internal(headers)
      |> AuthApiRequest
  }
}

pub fn set_header(request, header) -> TwitchApiRequest {
  let set_header_internal = fn(request, header) {
    request
    |> to_http_request
    |> request_ext.set_header(header)
  }

  case request {
    HelixApiRequest(_) as http_request ->
      http_request
      |> set_header_internal(header)
      |> HelixApiRequest
    AuthApiRequest(_) as http_request ->
      http_request
      |> set_header_internal(header)
      |> AuthApiRequest
  }
}

pub fn merge_headers(
  request: TwitchApiRequest,
  into base: List(Header),
  from overrides: List(Header),
) -> TwitchApiRequest {
  case request {
    HelixApiRequest(http_request) ->
      HelixApiRequest(request_ext.merge_headers(http_request, base, overrides))
    AuthApiRequest(http_request) ->
      AuthApiRequest(request_ext.merge_headers(http_request, base, overrides))
  }
}

pub fn set_method(request, method) -> TwitchApiRequest {
  case request {
    HelixApiRequest(http_request) ->
      HelixApiRequest(Request(..http_request, method: method))
    AuthApiRequest(http_request) ->
      AuthApiRequest(Request(..http_request, method: method))
  }
}

pub fn set_query(request, query_params) -> TwitchApiRequest {
  case request {
    HelixApiRequest(http_request) ->
      http_request
      |> request.set_query(query_params)
      |> HelixApiRequest
    AuthApiRequest(http_request) ->
      http_request
      |> request.set_query(query_params)
      |> AuthApiRequest
  }
}

pub fn set_body(request, body) -> TwitchApiRequest {
  case request {
    HelixApiRequest(http_request) ->
      HelixApiRequest(Request(..http_request, body: body))
    AuthApiRequest(http_request) ->
      AuthApiRequest(Request(..http_request, body: body))
  }
}

pub fn set_path(request, path) -> TwitchApiRequest {
  case request {
    HelixApiRequest(http_request) ->
      HelixApiRequest(Request(..http_request, path: path))
    AuthApiRequest(http_request) ->
      AuthApiRequest(Request(..http_request, path: path))
  }
}
