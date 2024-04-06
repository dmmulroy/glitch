import gleam/result
import gleam/httpc
import glitch/api/api_request.{type TwitchApiRequest}
import glitch/api/api_response.{type TwitchApiResponse}
import glitch/error/error.{type TwitchError, RequestError}

pub fn send(
  request: TwitchApiRequest,
) -> Result(TwitchApiResponse(String), TwitchError) {
  request
  |> api_request.to_http_request
  |> httpc.send
  |> result.map_error(RequestError)
  // TODO: Consider the Error type
  |> result.map(api_response.of_http_response)
}
