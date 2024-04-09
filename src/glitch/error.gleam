import gleam/dynamic.{type Dynamic}
import gleam/json.{type DecodeError}

// TODO: Write a pretty printer for errors

pub type TwitchError {
  AuthError(AuthError)
  InvalidResponseType(expected: String, received: String)
  RequestError(Dynamic)
  ResponseDecodeError(DecodeError)
  ResponseError(status: Int, message: String)
}

pub type AuthError {
  AccessTokenExpired
  InvalidGetTokenRequest
  InvalidAccessToken
  TokenFetcherFetchError(cause: TwitchError)
  TokenFetcherStartError
  ValidateTokenError(cause: TwitchError)
}
