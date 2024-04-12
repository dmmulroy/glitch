import gleam/dynamic.{type Decoder}
import gleam/option.{type Option}
import gleam/json.{type DecodeError as JsonDecodeError, type Json}
import glitch/extended/json_ext

pub type Condition {
  Condition(
    broadcaster_user_id: Option(String),
    from_broadcaster_id: Option(String),
    moderator_user_id: Option(String),
    to_broadcaster_id_user_id: Option(String),
    reward_id: Option(String),
    client_id: Option(String),
    extension_client_id: Option(String),
    user_id: Option(String),
  )
}

pub fn decoder() -> Decoder(Condition) {
  dynamic.decode8(
    Condition,
    dynamic.field("broadcaster_user_id", dynamic.optional(dynamic.string)),
    dynamic.field("from_broadcaster_id", dynamic.optional(dynamic.string)),
    dynamic.field("moderator_user_id", dynamic.optional(dynamic.string)),
    dynamic.field("to_broadcaster_id_user_id", dynamic.optional(dynamic.string)),
    dynamic.field("reward_id", dynamic.optional(dynamic.string)),
    dynamic.field("client_id", dynamic.optional(dynamic.string)),
    dynamic.field("extension_client_id", dynamic.optional(dynamic.string)),
    dynamic.field("user_id", dynamic.optional(dynamic.string)),
  )
}

pub fn from_json(json_string: String) -> Result(Condition, JsonDecodeError) {
  json.decode(json_string, decoder())
}

pub fn to_json(transport: Condition) -> Json {
  json.object([
    #(
      "broadcaster_user_id",
      json_ext.option(transport.broadcaster_user_id, json.string),
    ),
    #(
      "from_broadcaster_id",
      json_ext.option(transport.from_broadcaster_id, json.string),
    ),
    #(
      "moderator_user_id",
      json_ext.option(transport.moderator_user_id, json.string),
    ),
    #(
      "to_broadcaster_id_user_id",
      json_ext.option(transport.to_broadcaster_id_user_id, json.string),
    ),
    #("reward_id", json_ext.option(transport.reward_id, json.string)),
    #("client_id", json_ext.option(transport.client_id, json.string)),
    #(
      "extension_client_id",
      json_ext.option(transport.extension_client_id, json.string),
    ),
    #("user_id", json_ext.option(transport.user_id, json.string)),
  ])
}
