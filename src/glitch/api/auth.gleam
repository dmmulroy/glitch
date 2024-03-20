import gleam/dynamic.{type Decoder}
import gleam/json.{type DecodeError, type Json}
import gleam/uri.{type Uri}
import gleam/result
import gleam/http/response.{type Response}
import gleam/http/request
import glitch/api/client.{type Client}
import glitch/api/api_response
import glitch/api/error.{type TwitchApiError}
import glitch/api/scope.{type Scope}

// https://id.twitch.tv/oauth2/token

pub type GrantType {
  AuthorizationCode
  ClientCredentials
  DeviceCode
  Implicit
}

pub fn grant_type_to_string(grant_type: GrantType) -> String {
  case grant_type {
    AuthorizationCode -> "authorization_code"
    // TODO: Implement the rest of these
    _ -> panic("not supported")
  }
}

pub type TokenType {
  Bearer
}

pub fn token_type_to_string(token_type: TokenType) -> String {
  case token_type {
    Bearer -> "bearer"
  }
}

pub type GetTokenRequest {
  GetTokenRequest(code: String, grant_type: GrantType, redirect_uri: Uri)
}

pub type GetTokenResponse {
  GetTokenResponse(
    access_token: String,
    expires_in: Int,
    refresh_token: String,
    // scope: List(Scope),
    scope: List(String),
    // token_type: TokenType,
    token_type: String,
  )
}

fn get_token_response_decoder() -> Decoder(GetTokenResponse) {
  dynamic.decode5(
    GetTokenResponse,
    dynamic.field("access_token", dynamic.string),
    dynamic.field("expires_in", dynamic.int),
    dynamic.field("refresh_token", dynamic.string),
    dynamic.field("scope", dynamic.list(dynamic.string)),
    dynamic.field("token_type", dynamic.string),
  )
}

pub fn get_token_response_from_json(
  json_string: String,
) -> Result(GetTokenResponse, DecodeError) {
  json.decode(json_string, get_token_response_decoder())
}

pub fn get_token(
  client: Client,
  _get_token_request: GetTokenRequest,
) -> Result(GetTokenResponse, TwitchApiError) {
  let request =
    request.new()
    |> request.set_body(json.string("todo"))
    |> request.set_path("oauth2/token")

  use response <- result.try(client.post(client, request))

  response
  |> response.try_map(api_response.from_json(_, get_token_response_decoder()))
  |> result.try(api_response.get_data_from_response)
}
