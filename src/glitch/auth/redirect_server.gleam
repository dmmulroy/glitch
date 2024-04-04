import gleam/bytes_builder
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/uri.{type Uri}
import gleam/http.{Get}
import gleam/http/request.{type Request, Request}
import gleam/http/response.{type Response}
import gleam/erlang/process.{type Subject}
import gleam/otp/supervisor.{type Message as SupervisorMessage}
import gleam/otp/actor.{type StartError}
import mist.{type Connection, type ResponseData}

pub opaque type RedirectServer {
  State(
    csrf_state: String,
    mailbox: Subject(String),
    mist: Option(Subject(SupervisorMessage)),
    redirect_uri: Uri,
    status: Status,
  )
}

pub type Status {
  Running
  Stopped
}

pub type Message {
  Shutdown
  Start
}

pub fn new(
  csrf_state: String,
  mailbox: Subject(String),
  redirect_uri: Uri,
) -> Result(Subject(Message), StartError) {
  let state = State(csrf_state, mailbox, None, redirect_uri, Stopped)

  actor.start(state, handle_message)
}

fn handle_message(
  message: Message,
  state: RedirectServer,
) -> actor.Next(Message, RedirectServer) {
  case message {
    Shutdown -> {
      let assert Some(Nil) =
        state.mist
        |> option.map(process.subject_owner)
        |> option.map(process.kill)

      actor.Stop(process.Normal)
    }
    Start -> {
      let port = option.unwrap(state.redirect_uri.port, 3000)

      let assert Ok(mist_subject) =
        mist.new(new_router(state))
        |> mist.port(port)
        |> mist.start_http

      actor.continue(State(..state, mist: Some(mist_subject), status: Running))
    }
  }
}

pub fn start(server: Subject(Message)) {
  actor.send(server, Start)
}

pub fn shutdown(server: Subject(Message)) {
  actor.send(server, Shutdown)
}

fn new_router(server: RedirectServer) {
  let redirect_path = server.redirect_uri.path

  let router = fn(req: Request(Connection)) -> Response(ResponseData) {
    case req.method, request.path_segments(req) {
      Get, [path] if path == redirect_path -> make_redirect_handler(server)(req)
      _, _ ->
        response.new(404)
        |> response.set_body(mist.Bytes(bytes_builder.new()))
    }
  }

  router
}

/// 1024 bytes * 1024 bytes * 10
const ten_megabytes_in_bytes = 10_485_760

fn make_mist_body(body: Option(String)) {
  body
  |> option.unwrap("")
  |> bytes_builder.from_string
  |> mist.Bytes
}

fn get_code_and_csrf_token_query_params(req) {
  let query_params =
    request.get_query(req)
    |> result.unwrap([])

  let code_result = list.key_find(query_params, "code")
  let csrf_state_result = list.key_find(query_params, "state")

  #(option.from_result(code_result), option.from_result(csrf_state_result))
}

fn bad_request_response(message: Option(String)) -> Response(ResponseData) {
  response.new(400)
  |> response.set_body(make_mist_body(message))
}

fn generic_bad_request_response() -> Response(ResponseData) {
  bad_request_response(None)
}

fn ok_response(body: Option(String)) {
  response.new(200)
  |> response.set_body(make_mist_body(body))
}

fn make_redirect_handler(server: RedirectServer) {
  let handle_redirect = fn(req: Request(Connection)) -> Response(ResponseData) {
    case get_code_and_csrf_token_query_params(req) {
      #(Some(code), Some(state)) if state == server.csrf_state -> {
        mist.read_body(req, ten_megabytes_in_bytes)
        |> result.map(send_response(server, code))
        |> result.lazy_unwrap(generic_bad_request_response)
      }
      #(Some(_), Some(_)) -> bad_request_response(Some("Invalid csrf state"))
      #(Some(_), None) -> bad_request_response(Some("No csrf state received"))
      #(None, _) -> bad_request_response(Some("No code received"))
    }
  }

  handle_redirect
}

fn send_response(server: RedirectServer, code: String) {
  fn(_) {
    process.send_after(server.mailbox, 250, code)
    ok_response(Some("Successfully received redirect payload from Twitch."))
  }
}
