pub type GrantType {
  AuthorizationCode
  ClientCredentials
  RefreshToken
  DeviceCode
  Implicit
}

pub fn to_string(grant_type: GrantType) -> String {
  case grant_type {
    AuthorizationCode -> "authorization_code"
    ClientCredentials -> "client_credentials"
    RefreshToken -> "refresh_token"
    DeviceCode -> "device_code"
    Implicit -> "implicit"
  }
}

pub fn from_string(str: String) -> Result(GrantType, Nil) {
  case str {
    "authorization_code" -> Ok(AuthorizationCode)
    "client_credentials" -> Ok(ClientCredentials)
    "refresh_token" -> Ok(RefreshToken)
    "device_code" -> Ok(DeviceCode)
    "implicit" -> Ok(Implicit)
    _ -> Error(Nil)
  }
}
