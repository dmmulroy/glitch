import gleam/bit_array
import gleam/erlang/os
import gleam/erlang/process.{type Subject}
import gleam/function
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/otp/actor
import gleam/pair
import gleam/result
import gleam/string
import gleam/uri.{type Uri, Uri}
import glitch/api/auth
import glitch/auth/redirect_server
import glitch/error.{
  type AuthError, type TwitchError, AuthError, TokenFetcherFetchError,
  TokenFetcherStartError,
}
import glitch/extended/uri_ext
import glitch/types/access_token.{type AccessToken}
import glitch/types/scope.{type Scope}
import prng/random
import prng/seed
import shellout

const base_authorization_uri = Uri(
  Some("https"),
  None,
  Some("id.twitch.tv"),
  None,
  "oauth2/authorize",
  None,
  None,
)

const default_redirect_uri = Uri(
  Some("http"),
  None,
  Some("localhost"),
  Some(3000),
  "redirect",
  None,
  None,
)

pub type TokenFetcher =
  Subject(Message)

pub opaque type Message {
  Fetch(reply_to: Subject(Result(AccessToken, TwitchError)))
}

pub opaque type TokenFetcherState {
  State(
    client_id: String,
    client_secret: String,
    redirect_uri: Option(Uri),
    scopes: List(Scope),
  )
}

pub fn new(
  client_id: String,
  client_secret: String,
  scopes: List(Scope),
  redirect_uri: Option(Uri),
) -> Result(TokenFetcher, TwitchError) {
  let state = State(client_id, client_secret, redirect_uri, scopes)

  actor.start(state, handle_message)
  |> result.replace_error(AuthError(TokenFetcherStartError))
}

fn new_authorization_uri(token_fetcher: TokenFetcherState, csrf_state) -> Uri {
  let scopes =
    token_fetcher.scopes
    |> list.fold("", fn(acc, scope) {
      case acc {
        "" -> scope.to_string(scope)
        _ -> acc <> "+" <> scope.to_string(scope)
      }
    })

  let redirect_uri =
    token_fetcher.redirect_uri
    |> option.unwrap(default_redirect_uri)
    |> uri.to_string

  let query_params = [
    #("client_id", token_fetcher.client_id),
    #("redirect_uri", redirect_uri),
    #("response_type", "code"),
    #("scope", scopes),
    #("state", csrf_state),
  ]

  uri_ext.set_query(base_authorization_uri, query_params)
}

fn handle_message(
  message: Message,
  state: TokenFetcherState,
) -> actor.Next(Message, TokenFetcherState) {
  case message {
    Fetch(reply_to) -> handle_fetch(state, reply_to)
  }
}

pub fn fetch(
  token_fetcher: TokenFetcher,
  reply_to: Subject(Result(AccessToken, TwitchError)),
) -> Nil {
  actor.send(token_fetcher, Fetch(reply_to))
}

fn handle_fetch(
  state: TokenFetcherState,
  reply_to: Subject(Result(AccessToken, TwitchError)),
) {
  let mailbox: Subject(String) = process.new_subject()

  let assert Ok(csrf_state) =
    random.bit_array()
    |> random.step(seed.random())
    |> pair.first
    |> bit_array.to_string

  let redirect_uri = option.unwrap(state.redirect_uri, default_redirect_uri)

  let assert Ok(server) = redirect_server.new(csrf_state, mailbox, redirect_uri)

  redirect_server.start(server)

  let authorize_uri =
    state
    |> new_authorization_uri(csrf_state)
    |> uri.to_string

  let assert Ok(_) = case os.family() {
    os.WindowsNt ->
      shellout.command(
        "cmd",
        ["/c", "start", string.replace(authorize_uri, "&", "^&")],
        ".",
        [],
      )
    _ -> shellout.command("open", [authorize_uri], ".", [])
  }

  let code: String =
    process.new_selector()
    |> process.selecting(mailbox, function.identity)
    |> process.select_forever

  let request =
    auth.new_authorization_code_grant_request(
      state.client_id,
      state.client_secret,
      code,
      redirect_uri,
    )

  let response =
    auth.get_token(request)
    |> result.map_error(fn(error) {
      AuthError(TokenFetcherFetchError(cause: error))
    })

  redirect_server.shutdown(server)

  actor.send(reply_to, response)

  actor.continue(state)
}
