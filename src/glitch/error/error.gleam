import gleam/dynamic.{type Dynamic}
import gleam/json.{type DecodeError}

// TODO: Consolidate all error types here 
// TODO: Write a pretty printer for errors

pub type TwitchError {
  AuthError(AuthError)
  ClientError(ClientError)
  InvalidResponseType(wanted: String, found: String)
  RequestError(Dynamic)
  ResponseDecodeError(DecodeError)
  ResponseError(status: Int, message: String)
}

pub type ClientError {
  NoAccessToken
  NoClientSecret
  NoRefreshToken
}

pub type AuthError {
  InvalidGetTokenRequest
  TokenFetcherFetchError(cause: TwitchError)
  TokenFetcherStartError
}
