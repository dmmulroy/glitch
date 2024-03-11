import gleam/dynamic.{type DecodeError, type Decoder, type Dynamic}
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/uri.{type Uri}
import gleam/json.{type DecodeError as GleamJsonDecodeError, UnexpectedFormat}

pub type Json =
  json.Json

pub const array = json.array

pub const bool = json.bool

pub const decode = json.decode

pub const decode_bits = json.decode_bits

fn decode_field(
  from dyn: Dynamic,
  using decoder: Decoder(a),
) -> Result(a, GleamJsonDecodeError) {
  dyn
  |> decoder
  |> result.map_error(UnexpectedFormat)
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

pub fn decode11(
  constructor: fn(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11) -> t,
  t1: Decoder(t1),
  t2: Decoder(t2),
  t3: Decoder(t3),
  t4: Decoder(t4),
  t5: Decoder(t5),
  t6: Decoder(t6),
  t7: Decoder(t7),
  t8: Decoder(t8),
  t9: Decoder(t9),
  t10: Decoder(t10),
  t11: Decoder(t11),
) -> Decoder(t) {
  fn(x: Dynamic) {
    case
      t1(x),
      t2(x),
      t3(x),
      t4(x),
      t5(x),
      t6(x),
      t7(x),
      t8(x),
      t9(x),
      t10(x),
      t11(x)
    {
      Ok(a), Ok(b), Ok(c), Ok(d), Ok(e), Ok(f), Ok(g), Ok(h), Ok(i), Ok(j), Ok(
        k,
      ) -> Ok(constructor(a, b, c, d, e, f, g, h, i, j, k))
      a, b, c, d, e, f, g, h, i, j, k ->
        Error(
          list.concat([
            all_errors(a),
            all_errors(b),
            all_errors(c),
            all_errors(d),
            all_errors(e),
            all_errors(f),
            all_errors(g),
            all_errors(h),
            all_errors(i),
            all_errors(j),
            all_errors(k),
          ]),
        )
    }
  }
}

fn all_errors(result: Result(a, List(DecodeError))) -> List(DecodeError) {
  case result {
    Ok(_) -> []
    Error(errors) -> errors
  }
}
