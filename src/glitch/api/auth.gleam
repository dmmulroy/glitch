import gleam/dynamic.{type Decoder}
import gleam/result
import gleam/uri.{type Uri}
import glitch/api/api_response.{type TwitchApiResponse}
import glitch/api/api_request
import glitch/api/client.{type Client}
import glitch/api/error.{type TwitchApiError}
import glitch/api/scope.{type Scope}

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
  GetTokenRequest(
    client_id: String,
    client_secret: String,
    code: String,
    grant_type: GrantType,
    redirect_uri: Uri,
  )
}

fn get_token_request_to_form_data(get_token_request: GetTokenRequest) -> String {
  [
    #("client_id", get_token_request.client_id),
    #("client_secret", get_token_request.client_secret),
    #("code", get_token_request.code),
    #("grant_type", grant_type_to_string(get_token_request.grant_type)),
    #("redirect_uri", uri.to_string(get_token_request.redirect_uri)),
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
  dynamic.decode5(
    GetTokenResponse,
    dynamic.field("access_token", dynamic.string),
    dynamic.field("expires_in", dynamic.int),
    dynamic.field("refresh_token", dynamic.string),
    dynamic.field("scope", dynamic.list(scope.decoder())),
    dynamic.field("token_type", token_type_decoder()),
  )
}

pub fn get_token(
  client: Client,
  get_token_request: GetTokenRequest,
) -> Result(
  GetTokenResponse,
  TwitchApiError(TwitchApiResponse(GetTokenResponse)),
) {
  let body =
    get_token_request
    |> get_token_request_to_form_data

  let request =
    api_request.new_auth_request()
    |> api_request.set_body(body)
    |> api_request.set_path("oauth2/token")
    |> api_request.set_header(#(
      "content-type",
      "application/x-www-form-urlencoded",
    ))

  use response <- result.try(client.post(client, request))

  // START WEDNESDAY: Data Decoding is failing
  response
  |> api_response.get_data(get_token_response_decoder())
}
