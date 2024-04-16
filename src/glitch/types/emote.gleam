import gleam/dynamic.{type Decoder}
import gleam/result

pub type Emote {
  Emote(id: String, emote_set_id: String, owner_id: String, format: Format)
}

pub fn decoder() -> Decoder(Emote) {
  dynamic.decode4(
    Emote,
    dynamic.field("id", dynamic.string),
    dynamic.field("emote_set_id", dynamic.string),
    dynamic.field("owner_id", dynamic.string),
    dynamic.field("format", format_decoder()),
  )
}

pub type Format {
  Animated
  Static
}

pub fn format_to_string(format: Format) -> String {
  case format {
    Animated -> "animated"
    Static -> "static"
  }
}

pub fn format_from_string(string: String) -> Result(Format, Nil) {
  case string {
    "animated" -> Ok(Animated)
    "static" -> Ok(Static)
    _ -> Error(Nil)
  }
}

pub fn format_decoder() -> Decoder(Format) {
  fn(data: dynamic.Dynamic) {
    use string <- result.try(dynamic.string(data))

    string
    |> format_from_string
    |> result.replace_error([
      dynamic.DecodeError(
        expected: "Format",
        found: "String(" <> string <> ")",
        path: [],
      ),
    ])
  }
}
