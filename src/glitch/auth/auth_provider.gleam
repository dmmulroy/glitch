import gleam/option.{type Option, None}
import gleam/uri.{type Uri}
import glitch/auth/token_fetcher.{type TokenFetcher}
// import glitch/error/error.{type TwitchError, AuthError, TokenFetcherStartError}
import glitch/types/access_token.{type AccessToken}
import glitch/types/scope.{type Scope}

// https://github.com/twurple/twurple/blob/main/packages/auth/src/helpers.ts#L60
pub opaque type AuthProvider {
  ClientCredentialsAuthProvider(
    client_id: String,
    client_secret: String,
    scopes: List(Scope),
    redirect_uri: Option(Uri),
    token_fetcher: Option(TokenFetcher),
  )
  RefreshingAuthProvider(
    access_token: Option(AccessToken),
    client_id: String,
    client_secret: String,
    scopes: List(Scope),
    redirect_uri: Option(Uri),
    token_fetcher: Option(TokenFetcher),
  )
  StaticAuthProvider(
    access_token: AccessToken,
    client_id: String,
    scopes: List(Scope),
  )
}

pub type AuthProviderError {
  AuthProviderError
}

pub fn new_client_credentials_provider(
  client_id: String,
  client_secret: String,
  scopes: List(Scope),
  redirect_uri: Option(Uri),
) -> AuthProvider {
  ClientCredentialsAuthProvider(
    client_id,
    client_secret,
    scopes,
    redirect_uri,
    None,
  )
}

pub fn new_static_provider(
  access_token: AccessToken,
  client_id: String,
  scopes: List(Scope),
) -> AuthProvider {
  StaticAuthProvider(access_token, client_id, scopes)
}

pub fn new_refreshing_provider(
  access_token: Option(AccessToken),
  client_id: String,
  client_secret: String,
  scopes: List(Scope),
  redirect_uri: Option(Uri),
) -> AuthProvider {
  RefreshingAuthProvider(
    access_token,
    client_id,
    client_secret,
    scopes,
    redirect_uri,
    None,
  )
}
//
// pub fn get_access_token() -> Result(AccessToken, AuthProviderError) {
//   todo
// }
//
// pub fn get_scopes() -> List(Scope) {
//   todo
// }
