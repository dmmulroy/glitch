import gleam/option.{type Option, None, Some}
import gleam/result
import glitch/api/auth.{type GetTokenRequest}
import glitch/error.{
  type AuthError, type TwitchError, AccessTokenExpired, AuthError,
  TokenFetcherFetchError, ValidateTokenError,
}
import glitch/types/access_token.{type AccessToken}

pub opaque type AuthProvider {
  ClientCredentialsAuthProvider(
    access_token: Option(AccessToken),
    client_id: String,
    client_secret: String,
  )
  RefreshingAuthProvider(
    access_token: AccessToken,
    client_id: String,
    client_secret: String,
    on_refresh: Option(fn(AccessToken) -> Nil),
  )
  StaticAuthProvider(access_token: AccessToken, client_id: String)
}

pub fn new_client_credentials_provider(
  client_id: String,
  client_secret: String,
) -> AuthProvider {
  ClientCredentialsAuthProvider(None, client_id, client_secret)
}

pub fn new_static_provider(
  access_token: AccessToken,
  client_id: String,
) -> AuthProvider {
  StaticAuthProvider(access_token, client_id)
}

pub fn new_refreshing_provider(
  access_token: AccessToken,
  client_id: String,
  client_secret: String,
  on_refresh: Option(fn(AccessToken) -> Nil),
) -> AuthProvider {
  RefreshingAuthProvider(access_token, client_id, client_secret, on_refresh)
}

pub fn client_id(auth_provider: AuthProvider) -> String {
  case auth_provider {
    ClientCredentialsAuthProvider(_, client_id, _) -> client_id
    RefreshingAuthProvider(_, client_id, _, _) -> client_id
    StaticAuthProvider(_, client_id) -> client_id
  }
}

pub fn access_token(
  auth_provider: AuthProvider,
) -> Result(AccessToken, TwitchError) {
  case auth_provider {
    ClientCredentialsAuthProvider(access_token, client_id, client_secret) ->
      access_token_for_client_credential_provider(
        access_token,
        client_id,
        client_secret,
      )
    RefreshingAuthProvider(access_token, client_id, client_secret, on_refresh) -> {
      access_token_for_refreshing_provider(
        access_token,
        client_id,
        client_secret,
        on_refresh,
      )
    }
    StaticAuthProvider(access_token, ..) -> Ok(access_token)
  }
}

fn access_token_for_client_credential_provider(
  access_token: Option(AccessToken),
  client_id: String,
  client_secret: String,
) -> Result(AccessToken, TwitchError) {
  case access_token {
    None ->
      fetch_token(auth.new_client_credentials_grant_request(
        client_id,
        client_secret,
      ))
    Some(access_token) -> {
      case
        access_token.is_expired(access_token),
        access_token.needs_validated(access_token)
      {
        True, _ -> Error(AuthError(AccessTokenExpired))
        False, True -> {
          use validate_token_response <- result.try(
            auth.validate_token(access_token)
            |> result.map_error(fn(error) {
              AuthError(ValidateTokenError(error))
            }),
          )

          Ok(access_token.set_expires_in(
            access_token,
            validate_token_response.expires_in,
          ))
        }
        False, False -> {
          Ok(access_token)
        }
      }
    }
  }
}

fn access_token_for_refreshing_provider(
  access_token: AccessToken,
  client_id: String,
  client_secret: String,
  on_refresh: Option(fn(AccessToken) -> Nil),
) -> Result(AccessToken, TwitchError) {
  case
    access_token.is_expired(access_token),
    access_token.needs_validated(access_token)
  {
    True, _ -> {
      use refresh_token <- result.try(access_token.refresh_token(access_token))

      let refresh_token_request =
        auth.new_refresh_token_grant_request(
          client_id,
          client_secret,
          refresh_token,
        )

      use refreshed_token <- result.try(auth.refresh_token(
        refresh_token_request,
      ))

      case on_refresh {
        None -> Ok(refreshed_token)
        Some(on_refresh) -> {
          on_refresh(refreshed_token)
          Ok(refreshed_token)
        }
      }
    }
    False, True -> {
      use validate_token_response <- result.try(
        auth.validate_token(access_token)
        |> result.map_error(fn(error) { AuthError(ValidateTokenError(error)) }),
      )

      Ok(access_token.set_expires_in(
        access_token,
        validate_token_response.expires_in,
      ))
    }
    False, False -> {
      Ok(access_token)
    }
  }
}

fn fetch_token(request: GetTokenRequest) {
  request
  |> auth.get_token
  |> result.map_error(fn(error) {
    AuthError(TokenFetcherFetchError(cause: error))
  })
}
