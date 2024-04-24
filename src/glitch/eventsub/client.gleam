import gleam/dict.{type Dict}
import gleam/erlang/process.{type Selector, type Subject}
import gleam/function
import gleam/option.{type Option, None, Some}
import gleam/otp/actor.{type StartError}
import gleam/otp/supervisor
import gleam/result
import glitch/api/client.{type Client as ApiClient} as api_client
import glitch/api/eventsub.{
  type CreateEventSubscriptionRequest, CreateEventSubscriptionRequest,
}
import glitch/error.{type TwitchError}
import glitch/eventsub/websocket_message.{type WebSocketMessage}
import glitch/eventsub/websocket_server.{type WebSocketServer}
import glitch/types/event.{type Event}
import glitch/types/subscription.{type SubscriptionType}

pub type Client =
  Subject(Message)

pub opaque type ClientState {
  State(
    api_client: ApiClient,
    websocket_message_mailbox: Subject(WebSocketMessage),
    session_id: Option(String),
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
  api_client api_client: ApiClient,
  websocket_mailbox parent_websocket_message_mailbox: Subject(WebSocketMessage),
  parent_subject parent_subject: Subject(Client),
) -> fn(Nil) -> Result(Client, StartError) {
  fn(_) {
    actor.start_spec(actor.Spec(
      init: fn() {
        // Allows parent to send messages to this process
        let self = process.new_subject()
        process.send(parent_subject, self)

        // Receives messages from parent
        let selector: Selector(Message) =
          process.selecting(process.new_selector(), self, function.identity)

        // Receive websocket_servers' subject from
        let child_subject_mailbox = process.new_subject()

        // Weebsocket server communicates to this process via this subject
        let websocket_message_mailbox = process.new_subject()

        // // Lets us send messages to the websocket_server
        let start_websocket_server =
          websocket_server.new(child_subject_mailbox, websocket_message_mailbox)

        let websocket_server_child_spec =
          supervisor.worker(start_websocket_server)

        let assert Ok(_supervisor_subject) =
          supervisor.start(supervisor.add(_, websocket_server_child_spec))

        let assert Ok(websocket_server) =
          process.receive(child_subject_mailbox, 1000)

        let initial_state =
          State(
            api_client,
            parent_websocket_message_mailbox,
            None,
            dict.new(),
            Stopped,
            websocket_server,
          )

        let websocket_mailbox_selector =
          process.selecting(
            process.new_selector(),
            websocket_message_mailbox,
            WebSocketMessage,
          )

        let merged_selector =
          process.merge_selector(selector, websocket_mailbox_selector)

        actor.Ready(initial_state, merged_selector)
      },
      init_timeout: 1000,
      loop: handle_message,
    ))
  }
}

pub fn start(client: Client) {
  actor.send(client, Start)
}

pub fn subscribe(
  client: Client,
  subscription_request: CreateEventSubscriptionRequest,
  subscription_event_mailbox,
) -> Result(Nil, TwitchError) {
  let state = actor.call(client, GetState(_), 1000)

  use _ <- result.try(eventsub.create_eventsub_subscription(
    state.api_client,
    subscription_request,
  ))

  actor.send(
    client,
    Subscribe(
      subscription_request.subscription_type,
      subscription_event_mailbox,
    ),
  )

  Ok(Nil)
}

pub fn websocket_message_mailbox(client: Client) -> Subject(WebSocketMessage) {
  let state = actor.call(client, GetState, 1000)
  state.websocket_message_mailbox
}

pub fn session_id(client: Client) -> Result(String, Nil) {
  let state = actor.call(client, GetState, 1000)

  option.to_result(state.session_id, Nil)
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
      websocket_server.start(state.websocket_server)
      actor.continue(State(..state, status: Running))
    }
    Stop -> panic as "todo"
  }
}

fn handle_websocket_message(state: ClientState, message: WebSocketMessage) {
  case message {
    websocket_message.Close -> {
      // TODO SHUTDOWN
      process.send(state.websocket_message_mailbox, message)
      actor.continue(state)
    }
    websocket_message.NotificationMessage(metadata, payload) -> {
      process.send(state.websocket_message_mailbox, message)

      let assert Ok(subject) =
        dict.get(state.subscriptions, metadata.subscription_type)

      process.send(subject, payload.event)

      actor.continue(state)
    }
    websocket_message.WelcomeMessage(_metadata, payload) -> {
      process.send(state.websocket_message_mailbox, message)

      let session_id = payload.session.id
      actor.continue(State(..state, session_id: Some(session_id)))
    }
    _ -> {
      actor.continue(state)
    }
  }
}
