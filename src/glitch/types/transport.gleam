import gleam/dynamic.{type Decoder}
import gleam/json.{type DecodeError as JsonDecodeError, type Json}
import gleam/option.{type Option}
import gleam/result
import glitch/extended/json_ext

pub type Transport {
  Transport(
    method: Method,
    callback: Option(String),
    // WebHook only
    secret: Option(String),
    // WebSocket only
    session_id: Option(String),
    // WebSocket only & Response only
    connected_at: Option(String),
    // WebSocket only & Response only
    disconnected_at: Option(String),
    // Conduit only & Response only
    conduit_id: Option(String),
  )
}

pub fn decoder() -> Decoder(Transport) {
  dynamic.decode7(
    Transport,
    dynamic.field("method", method_decoder()),
    dynamic.optional_field("callback", dynamic.string),
    dynamic.optional_field("secret", dynamic.string),
    dynamic.optional_field("session_id", dynamic.string),
    dynamic.optional_field("connected_at", dynamic.string),
    dynamic.optional_field("disconnected_at", dynamic.string),
    dynamic.optional_field("conduit_id", dynamic.string),
  )
}

pub fn from_json(json_string: String) -> Result(Transport, JsonDecodeError) {
  json.decode(json_string, decoder())
}

pub fn to_json(transport: Transport) -> Json {
  json.object([
    #("method", json.string(method_to_string(transport.method))),
    #("callback", json_ext.option(transport.callback, json.string)),
    #("secret", json_ext.option(transport.secret, json.string)),
    #("session_id", json_ext.option(transport.session_id, json.string)),
    #("connected_at", json_ext.option(transport.connected_at, json.string)),
    #(
      "disconnected_at",
      json_ext.option(transport.disconnected_at, json.string),
    ),
  ])
}

pub type Method {
  Conduit
  WebHook
  WebSocket
}

pub fn method_to_string(method: Method) -> String {
  case method {
    Conduit -> "conduit"
    WebHook -> "webhook"
    WebSocket -> "websocket"
  }
}

pub fn method_from_string(string: String) -> Result(Method, Nil) {
  case string {
    "conduit" -> Ok(Conduit)
    "webhook" -> Ok(WebHook)
    "websocket" -> Ok(WebSocket)
    _ -> Error(Nil)
  }
}

pub fn method_decoder() -> Decoder(Method) {
  fn(data: dynamic.Dynamic) {
    use string <- result.try(dynamic.string(data))

    string
    |> method_from_string
    |> result.replace_error([
      dynamic.DecodeError(
        expected: "Method",
        found: "String(" <> string <> ")",
        path: [],
      ),
    ])
  }
}
