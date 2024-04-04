import gleam/option.{type Option}
import gleam/uri.{type Uri}
import glitch/auth/token_fetcher.{type TokenFetcher}
import glitch/types/access_token.{type AccessToken}
import glitch/types/scope.{type Scope}

// https://github.com/twurple/twurple/blob/main/packages/auth/src/helpers.ts#L60
pub opaque type AuthProvider {
  ClientCredentialsAuthProvider(
    client_id: String,
    client_secret: String,
    scopes: List(Scope),
    redirect_uri: Option(Uri),
    token_fetcher: TokenFetcher,
  )
  RefreshingAuthProvider(
    access_token: Option(AccessToken),
    client_id: String,
    client_secret: String,
    scopes: List(Scope),
    redirect_uri: Option(Uri),
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
  // let token_fetcher = token_fetcher.new()
  todo
}

pub fn new_static_provider() -> AuthProvider {
  todo
}

pub fn new_refreshing_provider() -> AuthProvider {
  todo
}

pub fn get_access_token() -> Result(AccessToken, AuthProviderError) {
  todo
}

pub fn get_scopes() -> List(Scope) {
  todo
}
