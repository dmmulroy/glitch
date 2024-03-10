import gleam/result

pub type User {
  Update
  Authorization(Authorization)
}

pub type InvalidUserSubscription {
  InvalidUserSubscription
}

pub fn from_string(str: String) -> Result(User, InvalidUserSubscription) {
  case str {
    "user.update" -> Ok(Update)
    _ ->
      str
      |> authorization_from_string
      |> result.map(Authorization)
  }
}

pub fn to_string(user: User) -> String {
  case user {
    Update -> "user.update"
    Authorization(authorization) -> authorization_to_string(authorization)
  }
}

pub type Authorization {
  Grant
  Revoke
}

pub fn authorization_to_string(authorization: Authorization) -> String {
  case authorization {
    Grant -> "user.authorization.grant"
    Revoke -> "user.authorization.revoke"
  }
}

pub fn authorization_from_string(
  str: String,
) -> Result(Authorization, InvalidUserSubscription) {
  case str {
    "user.authorization.grant" -> Ok(Grant)
    "user.authorization.revoke" -> Ok(Revoke)
    _ -> Error(InvalidUserSubscription)
  }
}
