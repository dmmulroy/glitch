import gleam/dynamic.{type Dynamic}
import gleam/json.{type DecodeError}

pub type TwitchApiError(error) {
  InvalidResponseType(wanted: String, found: String)
  ResponseDecodeError(DecodeError)
  RequestError(Dynamic)
  ResponseError(error)
}
