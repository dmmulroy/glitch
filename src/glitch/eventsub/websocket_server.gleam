import gleam/function
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/erlang/process.{type Subject}
import gleam/otp/actor.{type StartError}
import gleam/http/request
import stratus
import glitch/eventsub/websocket_message.{
  type WebSocketMessage, UnhandledMessage,
}

pub opaque type WebSockerServer {
  State(
    mailbox: Subject(WebSocketMessage),
    stratus: Option(Subject(stratus.InternalMessage(Nil))),
    status: Status,
  )
}

pub type Status {
  Running
  Stopped
}

pub type Message {
  Start
  Shutdown
}

// Todo: Look into why we need https/wss
const eventsub_uri = "https://eventsub.wss.twitch.tv/ws"

pub fn new(
  parent_subject,
  parent_mailbox: Subject(WebSocketMessage),
) -> Result(Subject(Message), StartError) {
  actor.start_spec(actor.Spec(
    init: fn() {
      let websocket_server_subject = process.new_subject()

      process.send(parent_subject, websocket_server_subject)

      let selector =
        process.new_selector()
        |> process.selecting(websocket_server_subject, function.identity)

      let initial_state = State(parent_mailbox, None, Stopped)

      actor.Ready(initial_state, selector)
    },
    init_timeout: 1000,
    loop: handle_message,
  ))
}

pub fn start(websocket_server: Subject(Message)) -> Nil {
  actor.send(websocket_server, Start)
}

fn handle_message(message: Message, state: WebSockerServer) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    Start -> handle_start(state)
  }
}

pub type Msg {
  Close
  TimeUpdated(String)
}

// TODO: Add KeepAlive decoder/Types
// "{\"metadata\":{\"message_id\":\"f7af5b20-4b9c-467a-a70b-a242cbaaaecb\",\"message_type\":\"session_keepalive\",\"message_timestamp\":\"2024-04-12T13:47:50.014441929Z\"},\"payload\":{}}"
fn handle_start(state: WebSockerServer) {
  let assert Ok(req) = request.to(eventsub_uri)

  let assert Ok(websocket_client_subject) =
    stratus.websocket(
      request: req,
      init: fn() { #(state, None) },
      loop: fn(message, state, _conn) {
        case message {
          stratus.Text(message) -> {
            let decoded_message =
              websocket_message.from_json(message)
              |> result.unwrap(UnhandledMessage(message))

            process.send(state.mailbox, decoded_message)
            actor.continue(state)
          }
          message -> {
            io.println("Received unexpected message:")
            io.debug(message)
            actor.continue(state)
          }
        }
      },
    )
    |> stratus.on_close(fn(_state) { io.println("rawhat is a legend") })
    |> stratus.initialize

  actor.continue(
    State(..state, stratus: Some(websocket_client_subject), status: Running),
  )
}
