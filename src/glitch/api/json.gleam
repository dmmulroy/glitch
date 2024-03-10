import gleam/dynamic.{type Decoder, type Dynamic}
import gleam/option.{type Option}
import gleam/result
import gleam/uri.{type Uri}
import gleam/json.{UnexpectedFormat}

pub type Json =
  json.Json

pub type DecodeError =
  json.DecodeError

pub const array = json.array

pub const bool = json.bool

pub const decode = json.decode

pub const decode_bits = json.decode_bits

fn decode_field(
  from dyn: Dynamic,
  using decoder: Decoder(a),
) -> Result(a, DecodeError) {
  dyn
  |> decoder
  |> result.map_error(UnexpectedFormat)
}

pub fn decode_bool_field(
  dyn: Dynamic,
  field_name: String,
) -> Result(Bool, DecodeError) {
  decode_field(dyn, dynamic.field(field_name, dynamic.bool))
}

pub fn decode_int_field(
  dyn: Dynamic,
  field_name: String,
) -> Result(Int, DecodeError) {
  decode_field(dyn, dynamic.field(field_name, dynamic.int))
}

pub fn decode_string_field(
  dyn: Dynamic,
  field_name: String,
) -> Result(String, DecodeError) {
  decode_field(dyn, dynamic.field(field_name, dynamic.string))
}

pub fn decode_uri_field(
  dyn: Dynamic,
  field_name: String,
) -> Result(Uri, DecodeError) {
  result.try(decode_string_field(dyn, field_name), fn(str) {
    str
    |> uri.parse
    |> result.replace_error(
      UnexpectedFormat([
        dynamic.DecodeError(expected: "Uri", found: "String", path: [field_name]),
      ]),
    )
  })
}

pub const float = json.float

pub const int = json.int

pub const null = json.null

pub const nullable = json.nullable

pub const object = json.object

pub fn option(from opt: Option(a), using encoder: fn(a) -> Json) -> Json {
  nullable(opt, encoder)
}

pub const preprocessed_array = json.preprocessed_array

pub const string = json.string

pub const to_string = json.to_string

pub const to_string_builder = json.to_string_builder

pub fn uri(uri: Uri) -> Json {
  uri
  |> uri.to_string
  |> string
}
