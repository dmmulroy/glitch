import gleam/dynamic.{type Decoder}
import gleam/json.{type DecodeError}
import gleam/option.{type Option}
import gleam/result
import glitch/api/api_request
import glitch/api/api_response
import glitch/api/client.{type Client}
import glitch/error.{type TwitchError}
import glitch/extended/json_ext

pub type Message {
  Message(message_id: String, is_sent: Bool)
}

fn message_decoder() -> Decoder(Message) {
  dynamic.decode2(
    Message,
    dynamic.field("message_id", dynamic.string),
    dynamic.field("is_sent", dynamic.bool),
  )
}

pub fn message_from_json(json_string: String) -> Result(Message, DecodeError) {
  json.decode(json_string, message_decoder())
}

pub type SendMessageRequest {
  SendMessageRequest(
    broadcaster_id: String,
    sender_id: String,
    message: String,
    reply_parent_message_id: Option(String),
  )
}

pub const new_send_message_request = SendMessageRequest

fn send_message_request_to_json(request: SendMessageRequest) -> String {
  json.object([
    #("broadcaster_id", json.string(request.broadcaster_id)),
    #("sender_id", json.string(request.sender_id)),
    #("message", json.string(request.message)),
    #(
      "reply_parent_message_id",
      json_ext.option(request.reply_parent_message_id, json.string),
    ),
  ])
  |> json.to_string
}

pub fn send_message(
  client: Client,
  request: SendMessageRequest,
) -> Result(List(Message), TwitchError) {
  let api_req =
    api_request.new_helix_request()
    |> api_request.set_body(send_message_request_to_json(request))
    |> api_request.set_path("chat/messages")

  use response <- result.try(client.post(client, api_req))

  api_response.get_list_data(response, message_decoder())
}
