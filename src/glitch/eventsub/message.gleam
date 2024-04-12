import gleam/dynamic.{type Decoder, type Dynamic}
import gleam/result

pub type Message(payload) {
  Message(metadate: Metadata, payload: payload)
}

pub fn decoder(payload_decoder: Decoder(payload)) -> Decoder(Message(payload)) {
  fn(data: Dynamic) {
    data
    |> dynamic.decode2(
      Message,
      dynamic.field("metatdata", metadate_decoder()),
      dynamic.field("payload", payload_decoder),
    )
  }
}

pub type Metadata {
  Metadata(
    message_id: String,
    message_type: MessageType,
    message_timestamp: String,
  )
}

pub fn metadate_decoder() -> Decoder(Metadata) {
  fn(data: Dynamic) {
    data
    |> dynamic.decode3(
      Metadata,
      dynamic.field("message_id", dynamic.string),
      dynamic.field("message_type", message_type_decoder()),
      dynamic.field("message_timestamp", dynamic.string),
    )
  }
}

pub type MessageType {
  SessionWelcome
}

pub fn message_type_decoder() -> Decoder(MessageType) {
  fn(data: Dynamic) {
    use string <- result.try(
      data
      |> dynamic.string,
    )

    string
    |> message_type_from_string
    |> result.replace_error([
      dynamic.DecodeError(
        expected: "MessageType",
        found: "String(" <> string <> ")",
        path: [],
      ),
    ])
  }
}

pub fn message_type_to_string(message_type: MessageType) -> String {
  case message_type {
    SessionWelcome -> "session_welcome"
  }
}

pub fn message_type_from_string(str: String) -> Result(MessageType, Nil) {
  case str {
    "session_welcome" -> Ok(SessionWelcome)
    _ -> Error(Nil)
  }
}
