import gleam/option.{type Option}
import gleam/uri.{type Uri}
import gleam/json.{type Json}

pub fn option(from opt: Option(a), using encoder: fn(a) -> Json) -> Json {
  json.nullable(opt, encoder)
}

pub fn uri(uri: Uri) -> Json {
  uri
  |> uri.to_string
  |> json.string
}
