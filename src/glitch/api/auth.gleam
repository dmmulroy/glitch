import gleam/uri.{type Uri}
import gleam/http/response.{type Response}
import glitch/api/client.{type Client}
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
    scope: List(Scope),
    token_type: TokenType,
  )
}

pub fn get_token(
  _client: Client,
  _get_token_request: GetTokenRequest,
) -> Result(Response(GetTokenResponse), error) {
  todo
}
