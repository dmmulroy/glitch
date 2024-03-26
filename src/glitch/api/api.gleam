import gleam/result
import gleam/httpc
import glitch/api/api_request.{type TwitchApiRequest}
import glitch/api/api_response.{type TwitchApiResponse}
import glitch/api/error.{type TwitchApiError, RequestError}

pub fn send(
  request: TwitchApiRequest,
) -> Result(TwitchApiResponse(String), TwitchApiError(error)) {
  request
  |> api_request.to_http_request
  |> httpc.send
  |> result.map_error(RequestError)
  // TODO: Consider the Error type
  |> result.map(api_response.of_http_response)
}
