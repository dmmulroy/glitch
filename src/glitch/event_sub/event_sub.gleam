import gleam/option.{type Option, None, Some}
import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import gleam/otp/supervisor.{type Message as SupervisorMessage}
import glitch/event_sub/websocket_server

pub type EventSub =
  Subject(Message)

pub opaque type EventSubState {
  State(
    status: Status,
    websocket_server_mailbox: Option(Subject(SupervisorMessage)),
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

pub fn new() {
  actor.start(State(Stopped, None), handle_message)
}

pub fn start(event_sub: EventSub) {
  actor.send(event_sub, Start)
}

pub fn shutdown(event_sub: EventSub) {
  actor.send(event_sub, Shutdown)
}

fn handle_message(
  message: Message,
  _state: EventSubState,
) -> actor.Next(a, EventSubState) {
  case message {
    Start -> handle_start()
    Shutdown -> actor.Stop(process.Normal)
  }
}

fn handle_start() {
  let mailbox = process.new_subject()

  let websocket_server =
    supervisor.worker(fn(_) { websocket_server.new(mailbox, None) })

  let init = fn(children) { supervisor.add(children, websocket_server) }

  let assert Ok(mailbox) = supervisor.start(init)

  actor.continue(State(status: Running, websocket_server_mailbox: Some(mailbox)))
}
