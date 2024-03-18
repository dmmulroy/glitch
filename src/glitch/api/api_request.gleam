import gleam/http.{Https}
import gleam/http/request.{type Request}
import gleam/json.{type Json}

pub type TwitchApiRequest =
  Request(String)

const host = "api.twitch.tv/helix"

pub fn from_request(request: Request(Json)) -> TwitchApiRequest {
  let body =
    request.body
    |> json.to_string

  request
  |> request.set_scheme(Https)
  |> request.set_host(host)
  |> request.set_body(body)
}
