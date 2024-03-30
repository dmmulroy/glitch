import glitch/auth/auth
import gleam/erlang/process

// const user_id = "209286766"

pub fn main() {
  let _ = auth.run()

  process.sleep_forever()
}
