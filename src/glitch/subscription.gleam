import gleam/int
import gleam/result
import glitch/subscription/user.{type User}

pub type Subscription {
  Subscription
}

pub type Type {
  User(User)
}

pub type Version {
  Int(Int)
  Beta
}

pub fn version_to_string(version: Version) -> String {
  case version {
    Int(version) -> int.to_string(version)
    Beta -> "beta"
  }
}

pub type InvalidVersion {
  InvalidVersion(String)
}

pub fn version_from_string(str: String) -> Result(Version, InvalidVersion) {
  case str {
    "beta" -> Ok(Beta)
    _ ->
      str
      |> int.parse
      |> result.map(Int)
      |> result.replace_error(InvalidVersion(str))
  }
}
