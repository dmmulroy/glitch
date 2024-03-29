import gleam/dynamic.{type Decoder}
import gleam/json
import gleam/result
import gleam/http.{type Header}
import gleam/http/response.{type Response, Response}
import glitch/api/error.{type TwitchApiError, ResponseDecodeError, ResponseError}

pub opaque type TwitchApiResponse(data) {
  TwitchApiResponse(Response(data))
}

type TwitchApiErrorResponse {
  TwitchApiErrorResponse(status: Int, message: String)
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

fn error_decoder() -> Decoder(TwitchApiErrorResponse) {
  dynamic.decode2(
    TwitchApiErrorResponse,
    dynamic.field("status", dynamic.int),
    dynamic.field("message", dynamic.string),
  )
}

pub fn get_data(
  api_response: TwitchApiResponse(String),
  data_decoder: Decoder(data),
) -> Result(data, TwitchApiError(error)) {
  let body =
    api_response
    |> get_body

  let error = json.decode(body, error_decoder())

  case error {
    Ok(TwitchApiErrorResponse(status, message)) ->
      Error(ResponseError(status, message))
    _ ->
      body
      |> json.decode(
        dynamic.any([data_decoder, dynamic.field("data", data_decoder)]),
      )
      |> result.map_error(ResponseDecodeError)
  }
}

pub fn get_list_data(
  api_response: TwitchApiResponse(String),
  data_decoder: Decoder(data),
) -> Result(List(data), TwitchApiError(error)) {
  let body =
    api_response
    |> get_body

  let error = json.decode(body, error_decoder())

  case error {
    Ok(TwitchApiErrorResponse(status, message)) ->
      Error(ResponseError(status, message))
    _ ->
      body
      |> json.decode(
        dynamic.any([
          dynamic.field("data", dynamic.list(of: data_decoder)),
          dynamic.list(of: data_decoder),
        ]),
      )
      |> result.map_error(ResponseDecodeError)
  }
}
