import gleam/dynamic.{type Decoder}

pub type Cheermote {
  Cheermote(prefix: String, bits: Int, tier: Int)
}

pub fn decoder() -> Decoder(Cheermote) {
  dynamic.decode3(
    Cheermote,
    dynamic.field("prefix", dynamic.string),
    dynamic.field("bits", dynamic.int),
    dynamic.field("tier", dynamic.int),
  )
}
