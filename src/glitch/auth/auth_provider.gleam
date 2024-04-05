import gleam/function
import gleam/result
import gleam/option.{type Option, None, Some}
import gleam/uri.{type Uri}
import gleam/erlang/process.{type Subject}
import glitch/auth/token_fetcher.{type TokenFetcher}
import glitch/api/api_response.{type TwitchApiResponse}
import glitch/error/error.{
  type AuthError, type TwitchError, AuthError, TokenFetcherFetchError,
  TokenFetcherStartError,
}
import glitch/types/access_token.{type AccessToken}
import glitch/types/scope.{type Scope}

// https://github.com/twurple/twurple/blob/main/packages/auth/src/helpers.ts#L60
pub opaque type AuthProvider {
  ClientCredentialsAuthProvider(
    access_token: Option(AccessToken),
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
    None,
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

pub fn get_access_token(
  auth_provider: AuthProvider,
) -> Result(AccessToken, AuthProviderError) {
  case auth_provider {
    ClientCredentialsAuthProvider(Some(access_token), ..) -> Ok(access_token)
    ClientCredentialsAuthProvider(None, ..) -> todo as "fetch token"
    _ -> Error(AuthProviderError)
  }
}

fn fetch_token(
  client_id: String,
  client_secret: String,
  scopes: List(Scope),
  redirect_uri: Option(Uri),
) -> Result(Nil, TwitchError(error)) {
  // ) -> Result(AccessToken, TwitchError(TwitchApiResponse(AccessToken))) {
  // ) -> Result(AccessToken, TwitchError(AuthError(error))) {
  // use token_fetcher <- result.try(token_fetcher.new(
  //   client_id,
  //   client_secret,
  //   scopes,
  //   redirect_uri,
  // ))

  Ok(Nil)
  // let mailbox = process.new_subject()
  //
  // token_fetcher.fetch(token_fetcher, mailbox)
  //
  // process.new_selector()
  // |> process.selecting(mailbox, function.identity)
  // |> process.select_forever
}
// pub fn get_scopes() -> List(Scope) {
//   todo
// }
