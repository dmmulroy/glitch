import glitch/auth/redirect_server
import gleam/erlang/process

// const user_id = "209286766"

pub fn main() {
  redirect_server.run()

  process.sleep_forever()
}
