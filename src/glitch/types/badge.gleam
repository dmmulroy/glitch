import gleam/dynamic.{type Decoder}

pub type Badge {
  Badge(set_id: String, id: String, info: String)
}

pub fn decoder() -> Decoder(Badge) {
  dynamic.decode3(
    Badge,
    dynamic.field("set_id", dynamic.string),
    dynamic.field("id", dynamic.string),
    dynamic.field("info", dynamic.string),
  )
}
