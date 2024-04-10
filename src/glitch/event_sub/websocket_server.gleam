import gleam/bytes_builder
import gleam/function
import gleam/option.{type Option, None, Some}
import gleam/uri.{type Uri, Uri}
import gleam/erlang/process.{type Subject}
import gleam/http.{Get}
import gleam/http/request.{type Request, Request}
import gleam/http/response.{type Response}
import gleam/otp/actor.{type StartError}
import gleam/otp/supervisor.{type Message as SupervisorMessage}
import mist.{type Connection, type ResponseData}

const default_ws_uri = Uri(
  Some("http"),
  None,
  Some("localhost"),
  Some(3001),
  "ws",
  None,
  None,
)

pub type WebsocketServer {
  State(mist: Option(Subject(SupervisorMessage)), status: Status, ws_uri: Uri)
}

pub type Status {
  Running
  Stopped
}

pub type Message {
  Start
  Shutdown
}

pub fn new(
  parent_mailbox: Subject(Subject(Message)),
  ws_uri: Option(Uri),
) -> Result(Subject(Message), StartError) {
  actor.start_spec(actor.Spec(
    init: fn() {
      let mailbox = process.new_subject()

      process.send(parent_mailbox, mailbox)

      let selector =
        process.new_selector()
        |> process.selecting(mailbox, function.identity)

      let initial_state =
        State(None, Stopped, option.unwrap(ws_uri, default_ws_uri))

      actor.Ready(initial_state, selector)
    },
    init_timeout: 1000,
    loop: handle_message,
  ))
}

fn handle_message(message: Message, state: WebsocketServer) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    Start -> handle_start(state)
  }
}

fn handle_start(state: WebsocketServer) {
  let port = option.unwrap(state.ws_uri.port, 3000)

  let assert Ok(mist_subject) =
    mist.new(new_router(state))
    |> mist.port(port)
    |> mist.start_http

  actor.continue(State(..state, mist: Some(mist_subject), status: Running))
}

fn new_router(state: WebsocketServer) {
  let redirect_path = state.ws_uri.path

  let router = fn(req: Request(Connection)) -> Response(ResponseData) {
    case req.method, request.path_segments(req) {
      Get, [path] if path == redirect_path ->
        response.new(200)
        |> response.set_body(mist.Bytes(bytes_builder.new()))
      _, _ ->
        response.new(404)
        |> response.set_body(mist.Bytes(bytes_builder.new()))
    }
  }

  router
}
