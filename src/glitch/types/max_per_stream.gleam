import gleam/dynamic.{type Decoder}

pub type MaxPerStream {
  MaxPerStream(is_enabled: Bool, value: Int)
}

pub fn max_per_stream_decoder() -> Decoder(MaxPerStream) {
  dynamic.decode2(
    MaxPerStream,
    dynamic.field("is_enabled", dynamic.bool),
    dynamic.field("value", dynamic.int),
  )
}
