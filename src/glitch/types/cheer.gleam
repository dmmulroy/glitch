import gleam/dynamic.{type Decoder}

pub type Cheer {
  Cheer(bits: Int)
}

pub fn decoder() -> Decoder(Cheer) {
  dynamic.decode1(Cheer, dynamic.field("bits", dynamic.int))
}
