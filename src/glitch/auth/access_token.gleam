import gleam/option.{type Option}
import gleam/erlang
import glitch/api/scope.{type Scope}

pub opaque type AccessToken {
  AccessToken(
    token: String,
    refresh_token: Option(String),
    scopes: List(Scope),
    expires_in: Int,
    obtained_at: Int,
  )
}

pub fn token(access_token: AccessToken) -> String {
  access_token.token
}

pub fn refresh_token(access_token: AccessToken) -> Option(String) {
  access_token.refresh_token
}

pub fn scopes(access_token: AccessToken) -> List(Scope) {
  access_token.scopes
}

pub fn is_expired(access_token: AccessToken) -> Bool {
  // TODO Check on what unit of time twitch uses
  let now = erlang.system_time(erlang.Millisecond)
  let expire_time = access_token.obtained_at + access_token.expires_in

  now > expire_time
}
