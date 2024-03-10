import gleam/int
import gleam/result
import glitch/event_sub/subscription/user.{
  type InvalidUserSubscription, type User,
}

pub type Subscription {
  Subscription(name: Name, version: Version, condition: Condition)
}

pub type Name {
  User(User)
}

pub type InvalidName {
  InvalidUser(InvalidUserSubscription)
}

pub fn name_to_string(name: Name) -> String {
  case name {
    User(user) -> user.to_string(user)
  }
}

pub fn name_from_string(str: String) -> Result(Name, InvalidName) {
  str
  |> user.from_string
  |> result.map(User)
  |> result.map_error(InvalidUser)
}

pub type Condition {
  Condition
}

pub type Version {
  Int(Int)
  Beta
}

pub type InvalidVersion {
  InvalidVersion(String)
}

pub fn version_to_string(version: Version) -> String {
  case version {
    Int(version) -> int.to_string(version)
    Beta -> "beta"
  }
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
