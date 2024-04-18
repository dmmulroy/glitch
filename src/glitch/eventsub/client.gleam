import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/function
import gleam/io
import gleam/otp/actor
import gleam/otp/supervisor
import gleam/result
import glitch/api/client.{type Client as ApiClient} as api_client
import glitch/api/eventsub.{
  type CreateEventSubscriptionRequest, CreateEventSubscriptionRequest,
}
import glitch/error.{type TwitchError, EventSubError, EventSubStartError}
import glitch/eventsub/websocket_message.{type WebSocketMessage}
import glitch/eventsub/websocket_server.{type WebSocketServer}
import glitch/types/event.{type Event}
import glitch/types/subscription.{type SubscriptionType}

pub type Client =
  Subject(Message)

pub opaque type ClientState {
  State(
    api_client: ApiClient,
    mailbox: Subject(WebSocketMessage),
    subscriptions: Dict(SubscriptionType, Subject(Event)),
    status: Status,
    websocket_server: WebSocketServer,
  )
}

pub opaque type Message {
  Subscribe(to: SubscriptionType, mailbox: Subject(Event))
  GetState(Subject(ClientState))
  WebSocketMessage(WebSocketMessage)
  Start
  Stop
}

pub type Status {
  Running
  Stopped
}

pub fn new(
  api_client: ApiClient,
  websocket_message_mailbox: Subject(WebSocketMessage),
) -> Result(Client, TwitchError) {
  actor.start_spec(actor.Spec(
    init: fn() {
      let self: Subject(Message) = process.new_subject()
      let child_subject_mailbox: Subject(WebSocketServer) =
        process.new_subject()

      let websocket_server =
        supervisor.worker(fn(_) {
          child_subject_mailbox
          |> websocket_server.new(websocket_message_mailbox)
          |> function.tap(result.map(_, websocket_server.start))
        })

      let assert Ok(_) = supervisor.start(supervisor.add(_, websocket_server))

      let assert Ok(child_subject) =
        process.receive(child_subject_mailbox, 1000)

      let initial_state =
        State(
          api_client,
          websocket_message_mailbox,
          dict.new(),
          Stopped,
          child_subject,
        )

      let selector =
        process.selecting(process.new_selector(), self, function.identity)

      let mailbox_selector =
        process.selecting(
          process.new_selector(),
          websocket_message_mailbox,
          WebSocketMessage,
        )

      actor.Ready(
        initial_state,
        process.merge_selector(selector, mailbox_selector),
      )
    },
    init_timeout: 1000,
    loop: handle_message,
  ))
  |> result.replace_error(EventSubError(EventSubStartError))
}

pub fn start(client: Client) {
  actor.send(client, Start)
}

pub fn subscribe(
  client: Client,
  subscription_request: CreateEventSubscriptionRequest,
) -> Result(Subject(Event), TwitchError) {
  let state = actor.call(client, GetState(_), 1000)

  use _ <- result.try(eventsub.create_eventsub_subscription(
    state.api_client,
    subscription_request,
  ))

  let mailbox = process.new_subject()

  actor.send(client, Subscribe(subscription_request.subscription_type, mailbox))
  Ok(mailbox)
}

pub fn mailbox(client: Client) -> Subject(WebSocketMessage) {
  let state = actor.call(client, GetState, 1000)
  state.mailbox
}

pub fn api_client(client: Client) -> api_client.Client {
  let state = actor.call(client, GetState, 1000)
  state.api_client
}

fn handle_message(message: Message, state: ClientState) {
  case message {
    GetState(state_mailbox) -> {
      process.send(state_mailbox, state)
      actor.continue(state)
    }
    Subscribe(subscription_type, mailbox) -> {
      let subscriptions =
        dict.insert(state.subscriptions, subscription_type, mailbox)
      actor.continue(State(..state, subscriptions: subscriptions))
    }
    WebSocketMessage(message) -> handle_websocket_message(state, message)
    Start -> {
      process.send(state.websocket_server, websocket_server.Start)
      actor.continue(State(..state, status: Running))
    }
    Stop -> panic as "todo"
  }
}

fn handle_websocket_message(state: ClientState, message: WebSocketMessage) {
  io.println("handle_websocket_message")
  io.debug(message)
  case message {
    websocket_message.Close -> {
      // TODO SHUTDOWN
      Nil
    }
    websocket_message.NotificationMessage(metadata, payload) -> {
      state.subscriptions
      |> dict.get(metadata.subscription_type)
      |> result.map(process.send(_, payload.event))
      |> result.unwrap_both
    }
    _ -> {
      Nil
    }
  }
  // process.send(state.mailbox, message)
  actor.continue(state)
}
