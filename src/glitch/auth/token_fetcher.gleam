import gleam/bit_array
import gleam/function
import gleam/io
import gleam/pair
import gleam/string
import gleam/uri.{type Uri}
import gleam/option.{type Option, None}
import gleam/erlang/os
import gleam/erlang/process.{type Subject}
import gleam/otp/actor.{type StartError}
import prng/random
import prng/seed
import shellout
import glitch/auth/redirect_server
import glitch/api/client.{type Client}
import glitch/api/auth
import glitch/types/access_token.{type AccessToken}
import glitch/extended/uri_ext

const uri = "https://id.twitch.tv/oauth2/authorize?response_type=code&client_id=cew8p1bv247ua1czt6a1okon8ejy1r&redirect_uri=http://localhost:3000/redirect&scope=user%3Awrite%3Achat+user%3Abot+channel%3Abot&state=foobar"

pub opaque type TokenFetcher {
  State(client: Client, redirect_uri: Option(Uri))
}

pub type Message {
  Fetch(reply_to: Subject(Result(AccessToken, Nil)))
}

pub fn new(
  client: Client,
  redirect_uri: Option(Uri),
) -> Result(Subject(Message), StartError) {
  let state = State(client, redirect_uri)

  actor.start(state, handle_message)
}

// TODO START HERE ON THURSDAY
fn new_redirect_uri(_token_fetcher: TokenFetcher) -> Uri {
  uri_ext.new()
  // let client_id = client.client_id(token_fetcher.client)
  // let redirect_uri = option.unwrap(token_fetcher.redirect_uri, )
  todo
}

fn handle_message(
  message: Message,
  state: TokenFetcher,
) -> actor.Next(Message, TokenFetcher) {
  case message {
    Fetch(reply_to) -> handle_fetch(state, reply_to)
  }
}

pub fn fetch(
  token_fetcher: Subject(Message),
  reply_to: Subject(Result(AccessToken, Nil)),
) {
  actor.send(token_fetcher, Fetch(reply_to))
}

pub fn handle_fetch(state: TokenFetcher, reply_to) {
  let mailbox: Subject(String) = process.new_subject()

  let assert Ok(csrf_state) =
    random.bit_array()
    |> random.step(seed.random())
    |> pair.first
    |> bit_array.to_string

  io.debug(csrf_state)

  let assert Ok(server) =
    redirect_server.new(csrf_state, mailbox, uri_ext.new())

  redirect_server.start(server)

  let assert Ok(_) = case os.family() {
    os.WindowsNt ->
      shellout.command(
        "cmd",
        ["/c", "start", string.replace(uri, "&", "^&")],
        ".",
        [],
      )
    _ -> shellout.command("open", [uri], ".", [])
  }

  let code: String =
    process.new_selector()
    |> process.selecting(mailbox, function.identity)
    |> process.select_forever

  let assert Ok(redirect_uri) = uri.parse("http://localhost:3000/redirect")

  let assert Ok(request) =
    auth.new_authorization_code_grant_request(state.client, code, redirect_uri)

  let assert Ok(response) = auth.get_token(state.client, request)

  redirect_server.shutdown(server)

  actor.send(reply_to, Ok(response.access_token))

  actor.continue(state)
}
