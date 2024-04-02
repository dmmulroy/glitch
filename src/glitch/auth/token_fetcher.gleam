import gleam/function
import gleam/io
import gleam/string
import gleam/option.{None}
import gleam/erlang/process.{type Subject}
import gleam/erlang/os
import glitch/auth/redirect_server
import glitch/api/client.{type Client}
import shellout

const uri = "https://id.twitch.tv/oauth2/authorize
    ?response_type=code
    &client_id=cew8p1bv247ua1czt6a1okon8ejy1r
    &redirect_uri=http://localhost:3000/redirect
    &scope=user%3Awrite%3Achat+user%3Abot+channel%3Abot
    &state=foobar"

pub opaque type TokenFetcher {
  TokenFetcher(client: Client)
}

pub fn new(client: Client) -> TokenFetcher {
  TokenFetcher(client)
}

//
// pub fn fetch() {
//   todo
// }

pub fn run() {
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

  process.new_selector()
  |> process.selecting(mailbox, function.identity)
  |> process.select_forever
  |> io.println

  redirect_server.shutdown(server)
}
