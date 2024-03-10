import gleam/result

// "user.authorization.grant" => 1,
// "user.authorization.revoke" => 1,
// "user.update" => 1

pub type User {
  Update
  Authorization(Authorization)
}

pub type InvalidUserSubscription {
  InvalidUserSubscription
}

pub fn of_string(str: String) -> Result(User, InvalidUserSubscription) {
  case str {
    "user.update" -> Ok(Update)
    _ ->
      str
      |> authorization_of_string
      |> result.map(Authorization)
  }
}

pub fn to_string(user: User) -> String {
  case user {
    Update -> "update"
    Authorization(authorization) -> authorization_to_string(authorization)
  }
}

// pub fn of_json(_json: String) -> User {
//   todo
// }

pub type Authorization {
  Grant
  Revoke
}

pub fn authorization_to_string(authorization: Authorization) -> String {
  case authorization {
    Grant -> "grant"
    Revoke -> "revoke"
  }
}

pub fn authorization_of_string(
  str: String,
) -> Result(Authorization, InvalidUserSubscription) {
  case str {
    "user.authorization.grant" -> Ok(Grant)
    "user.authorization.revoke" -> Ok(Revoke)
    _ -> Error(InvalidUserSubscription)
  }
}
