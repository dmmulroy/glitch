import gleam/dynamic.{type Decoder}
import gleam/json
import gleam/http/response.{type Response}
import glitch/extended/function_ext

pub type TwitchApiResponse(data) {
  TwitchApiResponse(data: List(data))
}

fn decoder(of data_decoder: Decoder(data)) -> Decoder(TwitchApiResponse(data)) {
  dynamic.decode1(
    TwitchApiResponse,
    dynamic.field("data", dynamic.list(of: data_decoder)),
  )
}

pub fn from_json(json_string: String, of data_decoder: Decoder(data)) {
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
