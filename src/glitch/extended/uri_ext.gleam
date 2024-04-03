import gleam/list
import gleam/option.{None, Some}
import gleam/string
import gleam/uri.{type Uri, Uri}
import gleam/http.{type Scheme}

const empty = Uri(
  scheme: None,
  userinfo: None,
  host: None,
  port: None,
  path: "",
  query: None,
  fragment: None,
)

pub fn new() -> Uri {
  empty
}

pub fn path_from_segments(segments: List(String)) -> Result(Uri, Nil) {
  segments
  |> list.map(string.replace(in: _, each: "/", with: ""))
  |> string.join(with: "/")
  |> uri.parse
}

pub fn host_from_string(host_str: String) -> Result(Uri, Nil) {
  uri.parse(host_str)
}

pub fn set_host(uri: Uri, host: Uri) -> Uri {
  Uri(..uri, host: host.host)
}

pub fn set_scheme(uri: Uri, scheme: Scheme) -> Uri {
  Uri(..uri, scheme: Some(http.scheme_to_string(scheme)))
}

pub fn set_path(uri: Uri, path: Uri) -> Uri {
  Uri(..uri, path: path.path)
}

pub fn set_port(uri: Uri, port: Int) -> Uri {
  Uri(..uri, port: Some(port))
}

pub fn set_query(uri: Uri, query_params: List(#(String, String))) -> Uri {
  let query =
    query_params
    |> uri.query_to_string
    |> Some

  Uri(..uri, query: query)
}
