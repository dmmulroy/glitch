import gleam/dynamic.{type Decoder}
import gleam/result
import gleam/uri.{type Uri}
import glitch/api/api_response.{type TwitchApiResponse}
import glitch/api/api_request
import glitch/api/client.{type Client}
import glitch/api/error.{type TwitchApiError}
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
  client,
  code: String,
  redirect_uri: Uri,
) -> Result(GetTokenRequest, TwitchApiError(error)) {
  use #(client_id, client_secret) <- result.try(client.client_credentials(
    client,
  ))

  Ok(AuthorizationCodeGrant(
    client_id,
    client_secret,
    code,
    AuthorizationCode,
    redirect_uri,
  ))
}

pub fn new_client_credentials_grant_request(
  client,
) -> Result(GetTokenRequest, TwitchApiError(error)) {
  use #(client_id, client_secret) <- result.try(client.client_credentials(
    client,
  ))

  Ok(ClientCredentialsGrant(client_id, client_secret, ClientCredentials))
}

pub fn new_refresh_token_grant_request(
  client,
) -> Result(GetTokenRequest, TwitchApiError(error)) {
  use #(client_id, client_secret) <- result.try(client.client_credentials(
    client,
  ))

  use refresh_token <- result.try(client.refresh_token(client))

  Ok(RefreshTokenGrant(client_id, client_secret, RefreshToken, refresh_token))
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

  response
  |> api_response.get_data(get_token_response_decoder())
}

pub fn refresh_token(
  client,
) -> Result(
  GetTokenResponse,
  TwitchApiError(TwitchApiResponse(GetTokenResponse)),
) {
  use get_token_request <- result.try(new_refresh_token_grant_request(client))

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

  response
  |> api_response.get_data(get_token_response_decoder())
}
