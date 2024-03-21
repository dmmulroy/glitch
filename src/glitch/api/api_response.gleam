import gleam/io
import gleam/dynamic.{type Decoder}
import gleam/json
import gleam/result
import gleam/http/response.{type Response, Response}
import glitch/api/error.{
  type TwitchApiError, InvalidResponseType, ResponseDecodeError, ResponseError,
}

pub type TwitchApiResponse(data) {
  TwitchApiResponse(data: data)
  TwitchApiListResponse(data: List(data))
  TwitchApiErrorResponse(error: String, status: Int, message: String)
}

fn twitch_api_response_decoder(
  data_decoder: Decoder(data),
) -> Decoder(TwitchApiResponse(data)) {
  dynamic.decode1(TwitchApiResponse, data_decoder)
}

fn twitch_api_list_response_decoder(
  data_decoder: Decoder(data),
) -> Decoder(TwitchApiResponse(data)) {
  dynamic.decode1(
    TwitchApiListResponse,
    dynamic.field("data", dynamic.list(of: data_decoder)),
  )
}

fn twitch_api_error_response_decoder() {
  dynamic.decode3(
    TwitchApiErrorResponse,
    dynamic.field("error", dynamic.string),
    dynamic.field("status", dynamic.int),
    dynamic.field("message", dynamic.string),
  )
}

fn decoder(data_decoder: Decoder(data)) -> Decoder(TwitchApiResponse(data)) {
  dynamic.any([
    twitch_api_response_decoder(data_decoder),
    twitch_api_list_response_decoder(data_decoder),
    twitch_api_error_response_decoder(),
  ])
}

pub fn from_json(
  json_string: String,
  data_decoder: Decoder(data),
) -> Result(TwitchApiResponse(data), TwitchApiError(error)) {
  io.debug(json_string)
  json_string
  |> json.decode(decoder(data_decoder))
  |> result.map_error(ResponseDecodeError)
}

// Start here on Friday
fn get_data(
  api_response: TwitchApiResponse(data),
) -> Result(data, TwitchApiError(error)) {
  case api_response {
    TwitchApiResponse(data) -> Ok(data)
    TwitchApiErrorResponse(_, _, _) as error -> Error(ResponseError(error))
    _ ->
      Error(InvalidResponseType(
        wanted: "TwitchApiResponse",
        found: "TwitchApiListResponse",
      ))
  }
}

fn get_list_data(
  api_response: TwitchApiResponse(data),
) -> Result(List(data), TwitchApiError(error)) {
  case api_response {
    TwitchApiListResponse(data) -> Ok(data)
    _ ->
      Error(InvalidResponseType(
        wanted: "TwitchApiListResponse",
        found: "TwitchApiResponse",
      ))
  }
}

pub fn get_data_from_response(
  response: Response(TwitchApiResponse(data)),
) -> Result(data, TwitchApiError(error)) {
  use data <- result.try(response.try_map(response, get_data))
  Ok(data.body)
}

pub fn get_list_data_from_response(
  response: Response(TwitchApiResponse(data)),
) -> Result(List(data), TwitchApiError(error)) {
  use data <- result.try(response.try_map(response, get_list_data))
  Ok(data.body)
}
