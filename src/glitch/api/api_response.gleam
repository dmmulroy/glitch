import gleam/dynamic.{type Decoder}
import gleam/json
import gleam/result
import gleam/http.{type Header}
import gleam/http/response.{type Response, Response}
import glitch/api/error.{
  type TwitchApiError, InvalidResponseType, ResponseDecodeError, ResponseError,
}

pub type TwitchApiResponse(data) {
  TwitchApiResponse(data: data)
  // TwitchApiResponse(status: Int, header: List(Header), data: data)
  TwitchApiListResponse(data: List(data))
  // TwitchApiListResponse(status: Int, header: List(Header), data: List(data))
  // TODO: Condiser making the error field Dynamic
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

pub fn decoder(data_decoder: Decoder(data)) -> Decoder(TwitchApiResponse(data)) {
  dynamic.any([
    twitch_api_response_decoder(data_decoder),
    twitch_api_list_response_decoder(data_decoder),
    twitch_api_error_response_decoder(),
  ])
}

// fn from_json(
//   json_string: String,
//   data_decoder: Decoder(data),
// ) -> Result(TwitchApiResponse(data), TwitchApiError(error)) {
//   json_string
//   |> json.decode(decoder(data_decoder))
//   |> result.map_error(ResponseDecodeError)
// }

// we probably need to deserialize the body here
pub fn of_http_response(response: Response(String)) -> TwitchApiResponse(String) {
  case response {
    Response(status, _, _) if status >= 300 -> {
      TwitchApiErrorResponse("TODO", status, "TODO")
    }
    Response(_status, _, body) -> TwitchApiResponse(body)
  }
}

pub fn get_data(
  api_response: TwitchApiResponse(data),
) -> Result(data, TwitchApiError(TwitchApiResponse(data))) {
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

pub fn get_list_data(
  api_response: TwitchApiResponse(String),
  data_decoder: Decoder(data),
) -> Result(List(data), TwitchApiError(error)) {
  case api_response {
    TwitchApiListResponse(data) -> todo
    // json.decode(data, twitch_api_list_response_decoder(data_decoder))
    _ ->
      Error(InvalidResponseType(
        wanted: "TwitchApiListResponse",
        found: "TwitchApiResponse",
      ))
  }
}
