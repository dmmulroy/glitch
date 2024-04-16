import gleam/dynamic.{type Decoder, type Dynamic}
import gleam/result

pub type Reward {
  Reward(id: String, title: String, cost: Int, prompt: String)
}

pub fn reward_decoder() -> Decoder(Reward) {
  dynamic.decode4(
    Reward,
    dynamic.field("id", dynamic.string),
    dynamic.field("title", dynamic.string),
    dynamic.field("cost", dynamic.int),
    dynamic.field("prompt", dynamic.string),
  )
}

pub type Status {
  Canceled
  Fulfilled
  Unfulfilled
  Unknown
}

pub fn rewards_status_to_string(reward_status: Status) -> String {
  case reward_status {
    Canceled -> "canceled"
    Fulfilled -> "fulfilled"
    Unfulfilled -> "unfulfilled"
    Unknown -> "unknown"
  }
}

pub fn reward_status_from_string(string: String) -> Result(Status, Nil) {
  case string {
    "canceled" -> Ok(Canceled)
    "fulfilled" -> Ok(Fulfilled)
    "unfulfilled" -> Ok(Unfulfilled)
    "unknown" -> Ok(Unknown)
    _ -> Error(Nil)
  }
}

pub fn reward_status_decoder() -> Decoder(Status) {
  fn(data: Dynamic) {
    use string <- result.try(dynamic.string(data))

    string
    |> reward_status_from_string
    |> result.replace_error([
      dynamic.DecodeError(
        expected: "RewardsStatus",
        found: "String(" <> string <> ")",
        path: [],
      ),
    ])
  }
}
