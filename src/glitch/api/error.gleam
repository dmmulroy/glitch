import gleam/dynamic.{type Dynamic}
import gleam/json.{type DecodeError}

// TODO: Consolidate all error types here 
// TODO: Write a pretty printer for errors

pub type TwitchApiError(error) {
  ClientError(ClientError)
  InvalidResponseType(wanted: String, found: String)
  ResponseDecodeError(DecodeError)
  RequestError(Dynamic)
  ResponseError(status: Int, message: String)
}

pub type ClientError {
  NoClientSecret
  NoAccessToken
  NoRefreshToken
}
