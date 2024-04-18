import gleam/erlang/process.{type Subject}
import gleam/function
import gleam/http/request
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/otp/actor.{type StartError}
import gleam/result
import glitch/eventsub/websocket_message.{
  type WebSocketMessage, UnhandledMessage,
}
import stratus

pub type WebSocketServer =
  Subject(Message)

pub opaque type WebSockerServerState {
  State(
    websocket_message_mailbox: Subject(WebSocketMessage),
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
  websocket_message_mailbox,
) -> Result(WebSocketServer, StartError) {
  actor.start_spec(actor.Spec(
    init: fn() {
      let self = process.new_subject()

      process.send(parent_subject, self)

      let selector =
        process.selecting(process.new_selector(), self, function.identity)

      let initial_state = State(websocket_message_mailbox, None, Stopped)

      actor.Ready(initial_state, selector)
    },
    init_timeout: 1000,
    loop: handle_message,
  ))
}

pub fn start(websocket_server: Subject(Message)) -> Nil {
  actor.send(websocket_server, Start)
}

fn handle_message(message: Message, state: WebSockerServerState) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    Start -> handle_start(state)
  }
}

fn handle_start(state: WebSockerServerState) {
  let assert Ok(req) = request.to(eventsub_uri)

  let assert Ok(websocket_client_subject) =
    stratus.websocket(
      request: req,
      init: fn() { #(state, None) },
      loop: fn(message, state, _conn) {
        case message {
          stratus.Text(message) -> {
            io.debug(message)
            let decoded_message =
              websocket_message.from_json(message)
              |> result.unwrap(UnhandledMessage(message))

            process.send(state.websocket_message_mailbox, decoded_message)

            actor.continue(state)
          }
          _ -> {
            io.println("Received unexpected message:")
            actor.continue(state)
          }
        }
      },
    )
    |> stratus.on_close(fn(state) {
      process.send(state.websocket_message_mailbox, websocket_message.Close)
    })
    |> stratus.initialize

  actor.continue(
    State(..state, stratus: Some(websocket_client_subject), status: Running),
  )
}
