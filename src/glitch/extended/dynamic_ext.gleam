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
