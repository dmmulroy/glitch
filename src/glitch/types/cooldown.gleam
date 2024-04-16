import gleam/dynamic.{type Decoder}

pub type Cooldown {
  Cooldown(is_enabled: Bool, seconds: Int)
}

pub fn cooldown_decoder() -> Decoder(Cooldown) {
  dynamic.decode2(
    Cooldown,
    dynamic.field("is_enabled", dynamic.bool),
    dynamic.field("second", dynamic.int),
  )
}
