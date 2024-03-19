import gleam/dynamic.{type Decoder}
import gleam/io
import gleam/option.{type Option}
import gleam/result
import gleam/json.{type DecodeError, type Json}
import gleam/http/response.{type Response}
import gleam/http/request
import glitch/api/client.{type Client}
import glitch/api/api_response
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

fn send_message_request_to_json(request: SendMessageRequest) -> Json {
  json.object([
    #("broadcaster_id", json.string(request.broadcaster_id)),
    #("sender_id", json.string(request.sender_id)),
    #("message", json.string(request.message)),
    #(
      "reply_parent_message_id",
      json_ext.option(request.reply_parent_message_id, json.string),
    ),
  ])
}

pub type SendMessageError {
  DecodeError(DecodeError)
  RequestError
}

pub fn send_message(
  client: Client,
  request: SendMessageRequest,
) -> Result(Response(List(Message)), SendMessageError) {
  let body = send_message_request_to_json(request)
  io.println(json.to_string(body))
  let request =
    request.new()
    |> request.set_body(send_message_request_to_json(request))
    |> request.set_path("chat/messages")

  use response <- result.try(
    client
    |> client.post(request)
    |> result.replace_error(RequestError),
  )

  response
  |> response.try_map(api_response.from_json(_, message_decoder()))
  |> result.try(api_response.get_data_from_response)
  |> result.map_error(DecodeError)
}
