pub type Transport

// Transport()

pub type Method {
  WebHook
  WebSocket
}

pub fn method_to_string(method: Method) -> String {
  case method {
    WebHook -> "webhook"
    WebSocket -> "websocket"
  }
}

pub fn method_from_string(string: String) -> Result(Method, Nil) {
  case string {
    "webhook" -> Ok(WebHook)
    "websocket" -> Ok(WebSocket)
    _ -> Error(Nil)
  }
}
