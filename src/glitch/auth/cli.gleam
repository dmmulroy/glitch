import dot_env/env

pub fn run() {
  let assert Ok(client_id) = env.get("CLIENT_ID")
  let assert Ok(client_secret) = env.get("CLIENT_SECRET")
  let assert Ok(access_token) = env.get("ACCESS_TOKEN")
  let assert Ok(refresh_token) = env.get("REFRESH_TOKEN")
}
