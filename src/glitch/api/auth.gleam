import gleam/dynamic.{type Decoder}
import gleam/result
import gleam/uri.{type Uri}
import gleam/http.{Post}
import glitch/api/api
import glitch/api/api_response.{type TwitchApiResponse}
import glitch/api/api_request
import glitch/error/error.{type TwitchError, AuthError, InvalidGetTokenRequest}
import glitch/types/access_token.{type AccessToken}
import glitch/types/grant.{
  type GrantType, AuthorizationCode, ClientCredentials, RefreshToken,
}

pub opaque type GetTokenRequest {
  AuthorizationCodeGrant(
    client_id: String,
    client_secret: String,
    code: String,
    grant_type: GrantType,
    redirect_uri: Uri,
  )
  ClientCredentialsGrant(
    client_id: String,
    client_secret: String,
    grant_type: GrantType,
  )
  RefreshTokenGrant(
    client_id: String,
    client_secret: String,
    grant_type: GrantType,
    refresh_token: String,
  )
}

pub fn new_authorization_code_grant_request(
  client_id client_id: String,
  client_secret client_secret: String,
  code code: String,
  redirect_uri redirect_uri: Uri,
) -> GetTokenRequest {
  AuthorizationCodeGrant(
    client_id,
    client_secret,
    code,
    AuthorizationCode,
    redirect_uri,
  )
}

pub fn new_client_credentials_grant_request(
  client_id client_id: String,
  client_secret client_secret: String,
) -> GetTokenRequest {
  ClientCredentialsGrant(client_id, client_secret, ClientCredentials)
}

pub fn new_refresh_token_grant_request(
  client_id client_id: String,
  client_secret client_secret: String,
  refresh_token refresh_token: String,
) -> GetTokenRequest {
  RefreshTokenGrant(client_id, client_secret, RefreshToken, refresh_token)
}

fn get_token_request_to_form_data(get_token_request: GetTokenRequest) -> String {
  case get_token_request {
    AuthorizationCodeGrant(
      client_id,
      client_secret,
      code,
      grant_type,
      redirect_uri,
    ) -> [
      #("client_id", client_id),
      #("client_secret", client_secret),
      #("code", code),
      #("grant_type", grant.to_string(grant_type)),
      #("redirect_uri", uri.to_string(redirect_uri)),
    ]
    ClientCredentialsGrant(client_id, client_secret, grant_type) -> [
      #("client_id", client_id),
      #("client_secret", client_secret),
      #("grant_type", grant.to_string(grant_type)),
    ]
    RefreshTokenGrant(client_id, client_secret, grant_type, refresh_token) -> [
      #("client_id", client_id),
      #("client_secret", client_secret),
      #("grant_type", grant.to_string(grant_type)),
      #("refresh_token", uri.percent_encode(refresh_token)),
    ]
  }
  |> uri.query_to_string
}

pub type GetTokenResponse {
  GetTokenResponse(access_token: AccessToken)
}

pub fn get_token_response_decoder() -> Decoder(GetTokenResponse) {
  dynamic.decode1(GetTokenResponse, access_token.decoder())
}

pub fn get_token(
  get_token_request: GetTokenRequest,
) -> Result(
  GetTokenResponse,
  TwitchError(TwitchApiResponse(GetTokenResponse)),
) {
  case get_token_request {
    RefreshTokenGrant(_, _, _, _) -> Error(AuthError(InvalidGetTokenRequest))
    _ -> {
      let body =
        get_token_request
        |> get_token_request_to_form_data

      api_request.new_auth_request()
      |> api_request.set_body(body)
      |> api_request.set_path("oauth2/token")
      |> api_request.set_header(#(
        "content-type",
        "application/x-www-form-urlencoded",
      ))
      |> api_request.set_method(Post)
      |> api.send
      |> result.try(api_response.get_data(_, get_token_response_decoder()))
    }
  }
}

pub fn refresh_token(
  get_token_request: GetTokenRequest,
) -> Result(
  GetTokenResponse,
  TwitchError(TwitchApiResponse(GetTokenResponse)),
) {
  case get_token_request {
    RefreshTokenGrant(_, _, _, _) -> {
      let body =
        get_token_request
        |> get_token_request_to_form_data

      api_request.new_auth_request()
      |> api_request.set_body(body)
      |> api_request.set_path("oauth2/token")
      |> api_request.set_header(#(
        "content-type",
        "application/x-www-form-urlencoded",
      ))
      |> api_request.set_method(Post)
      |> api.send
      |> result.try(api_response.get_data(_, get_token_response_decoder()))
    }
    _ -> Error(AuthError(InvalidGetTokenRequest))
  }
}
