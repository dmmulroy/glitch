import gleam/dynamic.{type Decoder}
import gleam/io
import gleam/json
import gleam/http/response.{type Response}
import glitch/extended/function_ext

pub type TwitchApiResponse(data) {
  TwitchApiResponse(data: List(data))
}

fn decoder(data_decoder: Decoder(data)) -> Decoder(TwitchApiResponse(data)) {
  dynamic.decode1(
    TwitchApiResponse,
    dynamic.field("data", dynamic.list(of: data_decoder)),
  )
}

pub fn from_json(json_string: String, data_decoder: Decoder(data)) {
  io.println(json_string)
  json.decode(json_string, decoder(data_decoder))
}

pub fn get_data(api_response: TwitchApiResponse(data)) -> List(data) {
  api_response.data
}

pub fn get_data_from_response(
  response: Response(TwitchApiResponse(data)),
) -> Result(Response(List(data)), error) {
  response
  |> response.try_map(function_ext.compose(get_data, Ok))
}
