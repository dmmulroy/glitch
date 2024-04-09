import gleam/option.{type Option}

pub opaque type Client {
  Client(session_id: Option(String))
}
