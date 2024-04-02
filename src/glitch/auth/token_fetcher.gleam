import gleam/function
import gleam/string
import gleam/uri
import gleam/option.{type Option, None}
import gleam/erlang/os
import gleam/erlang/process.{type Subject}
import gleam/otp/actor.{type StartError}
import shellout
import glitch/auth/redirect_server
import glitch/api/client.{type Client}
import glitch/api/auth
import glitch/types/access_token.{type AccessToken}

const uri = "https://id.twitch.tv/oauth2/authorize?response_type=code&client_id=cew8p1bv247ua1czt6a1okon8ejy1r&redirect_uri=http://localhost:3000/redirect&scope=user%3Awrite%3Achat+user%3Abot+channel%3Abot&state=foobar"

pub opaque type TokenFetcher {
  State(client: Client, reply_to: Option(Subject(Result(String, Nil))))
}

pub type Message {
  Fetch(reply_to: Subject(Result(AccessToken, Nil)))
}

pub fn new(client: Client) -> Result(Subject(Message), StartError) {
  let state = State(client, None)

  actor.start(state, handle_message)
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

  // todo generate random state
  let assert Ok(server) = redirect_server.new("foobar", mailbox, None, None)

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
