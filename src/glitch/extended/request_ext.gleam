import gleam/list
import gleam/option.{type Option}
import gleam/string
import gleam/http/request.{type Request, Request}

/// Set a request's headers using a list.
///
/// Similar to `set_header` but for setting more than a single header at once.
/// Existing headers on the request will be replaced.
pub fn set_headers(
  request: Request(body),
  headers: List(#(String, String)),
) -> Request(body) {
  let new_headers =
    list.fold(headers, [], fn(acc, header) {
      list.key_set(acc, string.lowercase(header.0), header.1)
    })
  Request(..request, headers: new_headers)
}

pub fn set_header(
  request: Request(body),
  header: #(String, String),
) -> Request(body) {
  let key = string.lowercase(header.0)
  let value = header.1

  request.set_header(request, key, value)
}

pub fn set_query_string(
  request: Request(body),
  query: Option(String),
) -> Request(body) {
  Request(..request, query: query)
}
