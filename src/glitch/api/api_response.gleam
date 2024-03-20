import gleam/dynamic.{type Decoder}
import gleam/json
import gleam/result
import gleam/http/response.{type Response, Response}
import glitch/api/error.{
  type TwitchApiError, InvalidResponseType, ResponseDecodeError,
}

pub type TwitchApiResponse(data) {
  TwitchApiResponse(data: data)
  TwitchApiListResponse(data: List(data))
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

fn decoder(data_decoder: Decoder(data)) -> Decoder(TwitchApiResponse(data)) {
  dynamic.any([
    twitch_api_response_decoder(data_decoder),
    twitch_api_list_response_decoder(data_decoder),
  ])
}

pub fn from_json(
  json_string: String,
  data_decoder: Decoder(data),
) -> Result(TwitchApiResponse(data), TwitchApiError) {
  json_string
  |> json.decode(decoder(data_decoder))
  |> result.map_error(ResponseDecodeError)
}

fn get_data(
  api_response: TwitchApiResponse(data),
) -> Result(data, TwitchApiError) {
  case api_response {
    TwitchApiResponse(data) -> Ok(data)
    _ ->
      Error(InvalidResponseType(
        wanted: "TwitchApiResponse",
        found: "TwitchApiListResponse",
      ))
  }
}

fn get_list_data(
  api_response: TwitchApiResponse(data),
) -> Result(List(data), TwitchApiError) {
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
) -> Result(data, TwitchApiError) {
  use data <- result.try(response.try_map(response, get_data))
  Ok(data.body)
}

pub fn get_list_data_from_response(
  response: Response(TwitchApiResponse(data)),
) -> Result(List(data), TwitchApiError) {
  use data <- result.try(response.try_map(response, get_list_data))
  Ok(data.body)
}
