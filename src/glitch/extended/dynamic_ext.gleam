import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/result
import gleam/uri.{type Uri}

pub fn uri(dyn: Dynamic) -> Result(Uri, List(DecodeError)) {
  result.try(dynamic.string(dyn), fn(str) {
    str
    |> uri.parse
    |> result.replace_error([
      dynamic.DecodeError(expected: "Uri", found: "String", path: []),
    ])
  })
}

fn decode_field(
  from dyn: Dynamic,
  using decoder: Decoder(a),
) -> Result(a, DecodeError) {
  decoder(dyn)
}

pub fn decode_bool_field(
  dyn: Dynamic,
  field_name: String,
) -> Result(Bool, GleamJsonDecodeError) {
  decode_field(dyn, dynamic.field(field_name, dynamic.bool))
}

pub fn decode_int_field(
  dyn: Dynamic,
  field_name: String,
) -> Result(Int, GleamJsonDecodeError) {
  decode_field(dyn, dynamic.field(field_name, dynamic.int))
}

pub fn decode_string_field(
  dyn: Dynamic,
  field_name: String,
) -> Result(String, GleamJsonDecodeError) {
  decode_field(dyn, dynamic.field(field_name, dynamic.string))
}

pub fn decode_uri_field(
  dyn: Dynamic,
  field_name: String,
) -> Result(Uri, GleamJsonDecodeError) {
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
