import gleam/dynamic.{type Decoder, type Dynamic}
import gleam/result
import gleam/erlang
import glitch/error.{type TwitchError, AuthError, InvalidAccessToken}
import glitch/types/scope.{type Scope}

pub opaque type AccessToken {
  AppAccessToken(
    expires_in: Int,
    obtained_at: Int,
    token: String,
    last_validated_at: Int,
  )
  UserAccessToken(
    expires_in: Int,
    obtained_at: Int,
    refresh_token: String,
    scopes: List(Scope),
    token: String,
    last_validated_at: Int,
  )
}

pub type RawAccessToken {
  RawAppAccessToken(access_token: String, expires_in: Int)
  RawUserAccessToken(
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
      RawUserAccessToken,
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

  case raw_access_token {
    RawAppAccessToken(access_token, expires_in) ->
      AppAccessToken(
        expires_in: expires_in,
        obtained_at: now,
        token: access_token,
        last_validated_at: now,
      )
    RawUserAccessToken(access_token, expires_in, refresh_token, scope) ->
      UserAccessToken(
        expires_in: expires_in,
        obtained_at: now,
        refresh_token: refresh_token,
        scopes: scope,
        token: access_token,
        last_validated_at: now,
      )
  }
}

pub fn token(access_token: AccessToken) -> String {
  case access_token {
    UserAccessToken(_, _, _, _, token, _) -> token
    AppAccessToken(_, _, token, _) -> token
  }
}

pub fn refresh_token(access_token: AccessToken) -> Result(String, TwitchError) {
  case access_token {
    UserAccessToken(_, _, refresh_token, _, _, _) -> Ok(refresh_token)
    _ -> Error(AuthError(InvalidAccessToken))
  }
}

pub fn scopes(access_token: AccessToken) -> Result(List(Scope), TwitchError) {
  case access_token {
    UserAccessToken(_, _, _, scopes, _, _) -> Ok(scopes)
    _ -> Error(AuthError(InvalidAccessToken))
  }
}

pub fn is_expired(access_token: AccessToken) -> Bool {
  let #(expires_in, obtained_at) = case access_token {
    UserAccessToken(expires_in, obtained_at, _, _, _, _) -> #(
      expires_in,
      obtained_at,
    )
    AppAccessToken(expires_in, obtained_at, _, _) -> #(expires_in, obtained_at)
  }

  let now = erlang.system_time(erlang.Second)
  let expire_time = obtained_at + expires_in

  now > expire_time
}

pub fn needs_validated(access_token: AccessToken) -> Bool {
  let last_validated_at = case access_token {
    UserAccessToken(_, _, _, _, _, last_validated_at) -> last_validated_at
    AppAccessToken(_, _, _, last_validated_at) -> last_validated_at
  }

  let now = erlang.system_time(erlang.Second)
  let one_hour_seconds = 3600
  let next_validation_time = last_validated_at + one_hour_seconds

  now >= next_validation_time
}

pub fn set_expires_in(access_token: AccessToken, expires_in: Int) -> AccessToken {
  case access_token {
    UserAccessToken(
      _,
      obtained_at,
      refresh_token,
      scopes,
      token,
      last_validated_at,
    ) ->
      UserAccessToken(
        expires_in,
        obtained_at,
        refresh_token,
        scopes,
        token,
        last_validated_at,
      )
    AppAccessToken(_, obtained_at, token, last_validated_at) ->
      AppAccessToken(expires_in, obtained_at, token, last_validated_at)
  }
}
