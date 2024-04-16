import gleam/erlang/process.{type Subject}
import gleam/function
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/otp/supervisor.{type Message as SupervisorMessage}
import gleam/result
import glitch/api/client.{type Client as ApiClient}
import glitch/api/eventsub.{CreateEventSubscriptionRequest}
import glitch/eventsub/websocket_message.{type WebSocketMessage}
import glitch/eventsub/websocket_server
import glitch/types/condition.{Condition}
import glitch/types/subscription
import glitch/types/transport.{Transport, WebSocket}

pub opaque type Client {
  State(
    api_client: ApiClient,
    mailbox: Subject(WebSocketMessage),
    status: Status,
    websocket_server_mailbox: Option(Subject(SupervisorMessage)),
  )
}

pub type Status {
  Running
  Stopped
}

pub fn new(api_client: ApiClient, mailbox: Subject(WebSocketMessage)) -> Client {
  State(api_client, mailbox, Stopped, None)
}

pub fn start(eventsub: Client) {
  let parent_subject = process.new_subject()
  let websocket_server_mailbox = process.new_subject()

  let websocket_server =
    supervisor.worker(fn(_) {
      parent_subject
      |> websocket_server.new(websocket_server_mailbox)
      |> function.tap(result.map(_, websocket_server.start))
    })

  let assert Ok(_) = supervisor.start(supervisor.add(_, websocket_server))

  let assert Ok(_child_subject) = process.receive(parent_subject, 1000)

  loop(process.new_selector(), websocket_server_mailbox, handle(eventsub, _))
}

fn loop(selector, websocket_server_mailbox, handle) {
  selector
  |> process.selecting(websocket_server_mailbox, handle)
  |> process.select_forever
  |> fn(_) { loop(selector, websocket_server_mailbox, handle) }
}

fn handle(state: Client, message: WebSocketMessage) {
  case message {
    websocket_message.Close -> {
      io.debug(message)
    }
    websocket_message.NotificationMessage(..) -> {
      io.debug(message)
    }
    websocket_message.SessionKeepaliveMessage(..) -> {
      io.debug(message)
    }
    websocket_message.UnhandledMessage(_) -> {
      io.debug(message)
    }
    websocket_message.WelcomeMessage(_, payload) -> {
      let assert Ok(_) =
        eventsub.create_eventsub_subscription(
          state.api_client,
          CreateEventSubscriptionRequest(
            subscription.ChannelChatMessage,
            "1",
            Condition(
              Some("209286766"),
              None,
              None,
              None,
              None,
              Some(client.client_id(state.api_client)),
              None,
              Some("209286766"),
            ),
            Transport(
              WebSocket,
              None,
              None,
              Some(payload.session.id),
              None,
              None,
              None,
            ),
          ),
        )

      let assert Ok(_) =
        eventsub.create_eventsub_subscription(
          state.api_client,
          CreateEventSubscriptionRequest(
            subscription.ChannelPointsCustomRewardRedemptionAdd,
            "1",
            Condition(
              Some("209286766"),
              None,
              None,
              None,
              None,
              None,
              None,
              None,
            ),
            Transport(
              WebSocket,
              None,
              None,
              Some(payload.session.id),
              None,
              None,
              None,
            ),
          ),
        )

      message
    }
  }
}
