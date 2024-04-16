import gleam/dynamic.{type Decoder, type Dynamic}
import gleam/json.{type DecodeError}
import gleam/option.{type Option}
import gleam/result
import gleam/uri.{type Uri}
import glitch/extended/dynamic_ext
import glitch/types/event.{type Event}
import glitch/types/subscription.{type Subscription, type SubscriptionType}

pub type WebSocketMessage {
  Close
  NotificationMessage(
    metadata: SubscriptionMetadata,
    payload: NotificationMessagePayload,
  )
  SessionKeepaliveMessage(metadata: Metadata)
  UnhandledMessage(raw_message: String)
  WelcomeMessage(metadata: Metadata, payload: WelcomeMessagePayload)
}

pub fn from_json(json_string: String) -> Result(WebSocketMessage, DecodeError) {
  json.decode(json_string, decoder())
}

pub fn decoder() -> Decoder(WebSocketMessage) {
  dynamic.any([
    welcome_message_decoder(),
    notification_message_decoder(),
    session_keepalive_message_decoder(),
  ])
}

fn welcome_message_decoder() -> Decoder(WebSocketMessage) {
  dynamic.decode2(
    WelcomeMessage,
    dynamic.field("metadata", metadata_decoder()),
    dynamic.field("payload", welcome_message_payload_decoder()),
  )
}

// TODO: Figure out how to handle "strict", i.e. not allowing additional filds
fn session_keepalive_message_decoder() -> Decoder(WebSocketMessage) {
  dynamic.decode1(
    SessionKeepaliveMessage,
    dynamic.field("metadata", metadata_decoder()),
  )
}

fn notification_message_decoder() -> Decoder(WebSocketMessage) {
  dynamic.decode2(
    NotificationMessage,
    dynamic.field("metadata", subscription_metadata_decoder()),
    dynamic.field("payload", notification_message_payload_decoder()),
  )
}

pub type MessageType {
  Notification
  SessionWelcome
  SessionKeepalive
  SessionReconnect
  Revocation
}

pub fn message_type_to_string(message_type: MessageType) -> String {
  case message_type {
    Notification -> "notification"
    SessionWelcome -> "session_welcome"
    SessionKeepalive -> "session_keepalive"
    SessionReconnect -> "sessions_reconnect"
    Revocation -> "revocation"
  }
}

pub fn message_type_from_string(string: String) -> Result(MessageType, Nil) {
  case string {
    "notification" -> Ok(Notification)
    "session_welcome" -> Ok(SessionWelcome)
    "session_keepalive" -> Ok(SessionKeepalive)
    "sessions_reconnect" -> Ok(SessionReconnect)
    "revocation" -> Ok(Revocation)
    _ -> Error(Nil)
  }
}

fn message_type_decoder() -> Decoder(MessageType) {
  fn(data: Dynamic) {
    use string <- result.try(dynamic.string(data))

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

pub type Metadata {
  Metadata(
    message_id: String,
    message_type: MessageType,
    message_timestamp: String,
  )
}

fn metadata_decoder() -> Decoder(Metadata) {
  dynamic.decode3(
    Metadata,
    dynamic.field("message_id", dynamic.string),
    dynamic.field("message_type", message_type_decoder()),
    dynamic.field("message_timestamp", dynamic.string),
  )
}

pub type SubscriptionMetadata {
  SubscriptionMetadata(
    message_id: String,
    message_type: MessageType,
    message_timestamp: String,
    subscription_type: SubscriptionType,
    subscription_version: String,
  )
}

fn subscription_metadata_decoder() -> Decoder(SubscriptionMetadata) {
  dynamic.decode5(
    SubscriptionMetadata,
    dynamic.field("message_id", dynamic.string),
    dynamic.field("message_type", message_type_decoder()),
    dynamic.field("message_timestamp", dynamic.string),
    dynamic.field("subscription_type", subscription.subscription_type_decoder()),
    dynamic.field("subscription_version", dynamic.string),
  )
}

pub type SessionStatus {
  Connected
}

pub fn session_status_to_string(session_status: SessionStatus) -> String {
  case session_status {
    Connected -> "connnected"
  }
}

pub fn session_status_from_string(string: String) -> Result(SessionStatus, Nil) {
  case string {
    "connected" -> Ok(Connected)
    _ -> Error(Nil)
  }
}

fn session_status_decoder() -> Decoder(SessionStatus) {
  fn(data: Dynamic) {
    use string <- result.try(dynamic.string(data))

    string
    |> session_status_from_string
    |> result.replace_error([
      dynamic.DecodeError(
        expected: "SessionStatus",
        found: "String(" <> string <> ")",
        path: [],
      ),
    ])
  }
}

pub type Session {
  Session(
    id: String,
    status: SessionStatus,
    connected_at: String,
    keepalive_timeout_seconds: Int,
    reconnect_url: Option(Uri),
  )
}

fn session_decoder() -> Decoder(Session) {
  dynamic.decode5(
    Session,
    dynamic.field("id", dynamic.string),
    dynamic.field("status", session_status_decoder()),
    dynamic.field("connected_at", dynamic.string),
    dynamic.field("keepalive_timeout_seconds", dynamic.int),
    dynamic.field("reconnect_url", dynamic.optional(dynamic_ext.uri)),
  )
}

pub type WelcomeMessagePayload {
  WelcomeMessagePayload(session: Session)
}

fn welcome_message_payload_decoder() -> Decoder(WelcomeMessagePayload) {
  dynamic.decode1(
    WelcomeMessagePayload,
    dynamic.field("session", session_decoder()),
  )
}

pub type NotificationMessagePayload {
  NotificationMessagePayload(subscription: Subscription, event: Event)
}

fn notification_message_payload_decoder() -> Decoder(NotificationMessagePayload) {
  dynamic.decode2(
    NotificationMessagePayload,
    dynamic.field("subscription", subscription.decoder()),
    dynamic.field("event", event.decoder()),
  )
}
