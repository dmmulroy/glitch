import gleam/http.{Https}
import gleam/http/request.{type Request}

pub type TwitchApiRequest =
  Request(String)

const host = "api.twitch.tv/helix"

pub fn from_request(request: Request(String)) -> TwitchApiRequest {
  request
  |> request.set_scheme(Https)
  |> request.set_host(host)
}
