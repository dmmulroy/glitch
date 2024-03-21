import gleam/dynamic.{type Decoder}
import gleam/json.{type DecodeError}
import gleam/uri.{type Uri}
import gleam/result
import gleam/http/response
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

pub type TokenTypeError {
  InvalidTokenType(String)
}

fn token_type_decoder() -> Decoder(TokenType) {
  fn(data: dynamic.Dynamic) {
    use string <- result.try(
      data
      |> dynamic.string,
    )

    string
    |> token_type_from_string
    |> result.replace_error([
      dynamic.DecodeError(
        expected: "TokenType",
        found: "String(" <> string <> ")",
        path: [],
      ),
    ])
  }
}

pub fn token_type_to_string(token_type: TokenType) -> String {
  case token_type {
    Bearer -> "bearer"
  }
}

pub fn token_type_from_string(
  string: String,
) -> Result(TokenType, TokenTypeError) {
  case string {
    "bearer" -> Ok(Bearer)
    _ -> Error(InvalidTokenType(string))
  }
}

pub type GetTokenRequest {
  GetTokenRequest(code: String, grant_type: GrantType, redirect_uri: Uri)
}

fn get_token_request_to_form_data(get_token_request: GetTokenRequest) -> String {
  [
    #("code", get_token_request.code),
    #("grant_type", grant_type_to_string(get_token_request.grant_type)),
    #("code", uri.to_string(get_token_request.redirect_uri)),
  ]
  |> uri.query_to_string
}

pub type GetTokenResponse {
  GetTokenResponse(
    access_token: String,
    expires_in: Int,
    refresh_token: String,
    scope: List(Scope),
    token_type: TokenType,
  )
}

fn get_token_response_decoder() -> Decoder(GetTokenResponse) {
  dynamic.decode2(
    GetTokenResponse,
    dynamic.field("access_token", dynamic.string),
    dynamic.field("expires_in", dynamic.int),
    dynamic.field("refresh_token", dynamic.string),
    dynamic.field("scope", dynamic.list(scope.decoder())),
    dynamic.field("token_type", token_type_decoder()),
  )
}

pub fn get_token_response_from_json(
  json_string: String,
) -> Result(GetTokenResponse, DecodeError) {
  json.decode(json_string, get_token_response_decoder())
}

pub fn get_token(
  client: Client,
  get_token_request: GetTokenRequest,
) -> Result(GetTokenResponse, TwitchApiError) {
  let body =
    get_token_request
    |> get_token_request_to_form_data

  let request =
    request.new()
    |> request.set_body(body)
    |> request.set_path("oauth2/token")

  use response <- result.try(client.post(client, request))

  response
  |> response.try_map(api_response.from_json(_, get_token_response_decoder()))
  |> result.try(api_response.get_data_from_response)
}
