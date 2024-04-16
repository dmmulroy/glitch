import gleam/erlang/process.{type Subject}
import gleam/function
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/otp/supervisor.{type Message as SupervisorMessage}
import gleam/result
import glitch/api/client.{type Client}
import glitch/api/eventsub.{CreateEventSubSubscriptionRequest}
import glitch/eventsub/websocket_message.{type WebSocketMessage}
import glitch/eventsub/websocket_server
import glitch/types/condition.{Condition}
import glitch/types/subscription
import glitch/types/transport.{Transport, WebSocket}

pub opaque type EventSub {
  State(
    client: Client,
    status: Status,
    mailbox: Option(Subject(SupervisorMessage)),
  )
}

pub type Status {
  Running
  Stopped
}

pub fn new(client: Client) {
  State(client, Stopped, None)
}

pub fn start(eventsub: EventSub) {
  let parent_subject = process.new_subject()
  let mailbox = process.new_subject()

  let websocket_server =
    supervisor.worker(fn(_) {
      parent_subject
      |> websocket_server.new(mailbox)
      |> function.tap(result.map(_, websocket_server.start))
    })

  let assert Ok(_) = supervisor.start(supervisor.add(_, websocket_server))

  let assert Ok(_child_subject) = process.receive(parent_subject, 1000)

  loop(process.new_selector(), mailbox, handle(eventsub, _))
}

fn loop(selector, mailbox, handle) {
  selector
  |> process.selecting(mailbox, handle)
  |> process.select_forever
  |> fn(_) { loop(selector, mailbox, handle) }
}

fn handle(state: EventSub, message: WebSocketMessage) {
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
          state.client,
          CreateEventSubSubscriptionRequest(
            subscription.ChannelChatMessage,
            "1",
            Condition(
              Some("209286766"),
              None,
              None,
              None,
              None,
              Some(client.client_id(state.client)),
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
          state.client,
          CreateEventSubSubscriptionRequest(
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
