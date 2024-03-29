import gleam/bytes_builder
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/uri.{type Uri}
import gleam/http.{Get}
import gleam/http/request.{type Request, Request}
import gleam/http/response.{type Response}
import gleam/erlang/process.{type Selector, type Subject}
import gleam/otp/actor
import mist.{type Connection, type ResponseData}

pub opaque type RedirectServer {
  RedirectServer(
    csrf_state: String,
    mailbox: Subject(String),
    port: Option(Int),
    redirect_uri: Option(Uri),
    stop_server_signal: Selector(Message),
  )
}

pub const new = RedirectServer

pub type Message {
  TakeCode(code: String)
  Stop
}

pub fn start(server: RedirectServer) {
  let assert Ok(_) =
    mist.new(new_router(server))
    |> mist.port(option.unwrap(server.port, 3000))
    |> mist.start_http

  let message_selector: Subject(Nil) = process.new_subject()

  process.select_forever(
    process.selecting(server.stop_server_signal, message_selector, fn(message) {
      case message {
        // START HERE
        Stop -> Nil
        _ -> Nil
      }
    }),
  )
  // process.sleep_forever()
}

fn new_router(server: RedirectServer) {
  let redirect_uri_str =
    server.redirect_uri
    |> option.map(uri.to_string)
    |> option.unwrap("redirect")

  let router = fn(req: Request(Connection)) -> Response(ResponseData) {
    case req.method, request.path_segments(req) {
      Get, [path] if path == redirect_uri_str ->
        make_redirect_handler(server)(req)
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
    actor.send(server.mailbox, code)
    ok_response(Some("Hello chat!"))
  }
}
