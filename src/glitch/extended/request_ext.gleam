import gleam/list
import gleam/pair
import gleam/http/request.{type Request}

pub fn set_headers(
  req: Request(String),
  headers: List(#(String, String)),
) -> Request(String) {
  list.fold(headers, req, fn(acc, header) {
    let key = pair.first(header)
    let value = pair.first(header)
    request.prepend_header(acc, key, value)
  })
}
