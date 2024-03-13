import gleam/option.{type Option}
import gleam/uri.{type Uri}
import gleam/json.{type DecodeError, type Json}

pub type JsonDecoder(input, output) =
  fn(input) -> Result(output, DecodeError)

pub fn option(from opt: Option(a), using encoder: fn(a) -> Json) -> Json {
  json.nullable(opt, encoder)
}

pub fn uri(uri: Uri) -> Json {
  uri
  |> uri.to_string
  |> json.string
}
