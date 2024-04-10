import gleam/function
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/erlang/process.{type Subject}
import gleam/otp/actor.{type StartError}
import gleam/http/request
import stratus

pub opaque type WebsocketServer {
  State(
    mailbox: Subject(TwitchMessage),
    stratus: Option(Subject(stratus.InternalMessage(Nil))),
    status: Status,
  )
}

pub type Status {
  Running
  Stopped
}

pub type TwitchMessage {
  Foo
  Bar
  Baz
}

pub type Message {
  Start
  Shutdown
}

// Todo: Look into why we need https/wss
const event_sub_uri = "https://eventsub.wss.twitch.tv/ws"

pub fn new(
  parent_mailbox: Subject(Subject(TwitchMessage)),
) -> Result(Subject(Message), StartError) {
  actor.start_spec(actor.Spec(
    init: fn() {
      let websocket_server_subject: Subject(Message) = process.new_subject()
      let mailbox: Subject(TwitchMessage) = process.new_subject()

      process.send(parent_mailbox, mailbox)

      let selector =
        process.new_selector()
        |> process.selecting(websocket_server_subject, function.identity)

      let initial_state = State(mailbox, None, Stopped)

      actor.Ready(initial_state, selector)
    },
    init_timeout: 1000,
    loop: handle_message,
  ))
}

pub fn start(websocket_server: Subject(Message)) -> Nil {
  actor.send(websocket_server, Start)
}

fn handle_message(message: Message, state: WebsocketServer) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    Start -> handle_start(state)
  }
}

pub type Msg {
  Close
  TimeUpdated(String)
}

fn handle_start(state: WebsocketServer) {
  let assert Ok(req) = request.to(event_sub_uri)

  let assert Ok(websocket_client_subject) =
    stratus.websocket(
      request: req,
      init: fn() { #(Nil, None) },
      loop: fn(msg, state, _conn) {
        case msg {
          stratus.Text(msg) -> {
            io.debug(msg)
            actor.continue(state)
          }
          stratus.User(msg) -> {
            io.debug(msg)
            actor.continue(state)
          }
          stratus.Binary(msg) -> {
            io.debug(msg)
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
