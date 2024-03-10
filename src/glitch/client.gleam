import gleam/uri.{type Uri}
import gleam/option.{type Option}
import glitch/subscription.{type Subscription}

// * `:client_id` - Twitch app client id.
// * `:access_token` - Twitch app access token with required scopes for the
//    provided `:subscriptions`.
// * `:subscriptions` - The subscriptions for EventSub.
// * `:url` - A websocket URL to connect to. `Defaults to "wss://eventsub.wss.twitch.tv/ws"`.
// * `:keepalive_timeout` - The keepalive timeout in seconds. Specifying an invalid,
//    but numeric value will return the nearest acceptable value. Defaults to `10`.
// * `:start?` - A boolean value of whether or not to start the eventsub socket.
// TODOS:
// - Find a WS client for Gleam

pub type Options {
  Options(
    client_id: String,
    access_token: String,
    subscriptions: List(Subscription),
    url: Uri,
    keepalive_timeout: Int,
    start: Option(Bool),
  )
}
