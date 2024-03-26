import gleam/dynamic.{type Decoder}
import gleam/json
import gleam/result
import gleam/http.{type Header}
import gleam/http/response.{type Response, Response}
import glitch/api/error.{type TwitchApiError, ResponseDecodeError}

pub opaque type TwitchApiResponse(data) {
  TwitchApiResponse(Response(data))
}

pub fn of_http_response(response: Response(String)) -> TwitchApiResponse(String) {
  TwitchApiResponse(response)
}

fn get_http_response(api_response: TwitchApiResponse(data)) -> Response(data) {
  case api_response {
    TwitchApiResponse(response) -> response
  }
}

pub fn get_body(api_response: TwitchApiResponse(data)) -> data {
  get_http_response(api_response).body
}

pub fn get_headers(api_response: TwitchApiResponse(data)) -> List(Header) {
  let http_response = get_http_response(api_response)
  http_response.headers
}

pub fn get_data(
  api_response: TwitchApiResponse(String),
  data_decoder: Decoder(data),
) -> Result(data, TwitchApiError(error)) {
  api_response
  |> get_body
  |> json.decode(dynamic.field("data", data_decoder))
  |> result.map_error(ResponseDecodeError)
}

pub fn get_list_data(
  api_response: TwitchApiResponse(String),
  data_decoder: Decoder(data),
) -> Result(List(data), TwitchApiError(error)) {
  api_response
  |> get_body
  |> json.decode(dynamic.field("data", dynamic.list(of: data_decoder)))
  |> result.map_error(ResponseDecodeError)
}
