import gleam/dynamic.{type Decoder, type Dynamic}
import gleam/result
import gleam/erlang
import glitch/types/scope.{type Scope}

pub opaque type AccessToken {
  AccessToken(
    expires_in: Int,
    obtained_at: Int,
    refresh_token: String,
    scopes: List(Scope),
    token: String,
  )
}

pub type RawAccessToken {
  RawAccessToken(
    access_token: String,
    expires_in: Int,
    refresh_token: String,
    scope: List(Scope),
  )
}

pub fn decoder() -> Decoder(AccessToken) {
  fn(data: Dynamic) {
    data
    |> dynamic.decode4(
      RawAccessToken,
      dynamic.field("access_token", dynamic.string),
      dynamic.field("expires_in", dynamic.int),
      dynamic.field("refresh_token", dynamic.string),
      dynamic.field("scope", dynamic.list(scope.decoder())),
    )
    |> result.map(from_raw_access_token)
  }
}

fn from_raw_access_token(raw_access_token: RawAccessToken) -> AccessToken {
  let now = erlang.system_time(erlang.Second)

  AccessToken(
    expires_in: raw_access_token.expires_in,
    obtained_at: now,
    refresh_token: raw_access_token.refresh_token,
    scopes: raw_access_token.scope,
    token: raw_access_token.access_token,
  )
}

pub fn token(access_token: AccessToken) -> String {
  access_token.token
}

pub fn refresh_token(access_token: AccessToken) -> String {
  access_token.refresh_token
}

pub fn scopes(access_token: AccessToken) -> List(Scope) {
  access_token.scopes
}

pub fn is_expired(access_token: AccessToken) -> Bool {
  let now = erlang.system_time(erlang.Second)
  let expire_time = access_token.obtained_at + access_token.expires_in

  now > expire_time
}
