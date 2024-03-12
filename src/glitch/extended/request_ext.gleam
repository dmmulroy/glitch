import gleam/list
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
