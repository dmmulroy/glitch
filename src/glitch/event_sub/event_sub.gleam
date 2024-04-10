import gleam/io
import gleam/function
import gleam/option.{type Option, None}
import gleam/result
import gleam/erlang/process.{type Subject}
import gleam/otp/supervisor.{type Message as SupervisorMessage}
import glitch/event_sub/websocket_server

pub opaque type EventSub {
  State(status: Status, mailbox: Option(Subject(SupervisorMessage)))
}

pub type Status {
  Running
  Stopped
}

pub fn new() {
  State(Stopped, None)
}

pub fn start(_event_sub: EventSub) {
  let parent_subject = process.new_subject()

  let websocket_server =
    supervisor.worker(fn(_) {
      parent_subject
      |> websocket_server.new
      |> function.tap(result.map(_, websocket_server.start))
    })

  let assert Ok(_) = supervisor.start(supervisor.add(_, websocket_server))

  let assert Ok(mailbox): Result(Subject(websocket_server.TwitchMessage), Nil) =
    process.receive(parent_subject, 1000)

  process.new_selector()
  |> process.selecting(mailbox, io.debug)
  |> process.select_forever
}
