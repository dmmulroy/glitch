import gleam/function
import gleam/io
import gleam/option.{None}
import gleam/erlang/process.{type Subject}
// import dot_env/env
import glitch/auth/server
import shellout

const uri = "https://id.twitch.tv/oauth2/authorize
    ?response_type=code
    &client_id=cew8p1bv247ua1czt6a1okon8ejy1r
    &redirect_uri=http://localhost:3000/redirect
    &scope=user%3Awrite%3Achat+user%3Abot+channel%3Abot
    &state=foobar"

pub fn run() {
  // TODO: Arg parsing

  let mailbox: Subject(String) = process.new_subject()

  let assert Ok(redirect_server) = server.new("foobar", mailbox, None, None)

  server.start(redirect_server)

  // Look at Ryan's example for x-platform 'open'
  let assert Ok(_) = shellout.command("open", [uri], ".", [])

  process.new_selector()
  |> process.selecting(mailbox, function.identity)
  |> process.select_forever
  |> io.println

  io.println("finished successfully")
  // process.sleep_forever()
}
