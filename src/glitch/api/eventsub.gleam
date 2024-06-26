import gleam/dynamic.{type Decoder}
import gleam/json
import gleam/result
import glitch/api/api_request
import glitch/api/api_response.{type EventSubData}
import glitch/api/client.{type Client}
import glitch/error.{type TwitchError}
import glitch/types/condition.{type Condition}
import glitch/types/subscription.{type SubscriptionStatus, type SubscriptionType}
import glitch/types/transport.{type Transport}

pub type CreateEventSubscriptionRequest {
  CreateEventSubscriptionRequest(
    subscription_type: SubscriptionType,
    version: String,
    condition: Condition,
    transport: Transport,
  )
}

fn send_message_request_to_json(
  request: CreateEventSubscriptionRequest,
) -> String {
  json.object([
    #("type", subscription.subscription_type_to_json(request.subscription_type)),
    #("version", json.string(request.version)),
    #("condition", condition.to_json(request.condition)),
    #("transport", transport.to_json(request.transport)),
  ])
  |> json.to_string
}

pub type CreateEventSubSubscriptionResponse {
  CreateEventSubSubscriptionResponse(
    id: String,
    subscription_status: SubscriptionStatus,
    subscription_type: SubscriptionType,
    version: String,
    condition: Condition,
    created_at: String,
    cost: Int,
  )
}

fn create_eventsub_subscription_response_decoder() -> Decoder(
  CreateEventSubSubscriptionResponse,
) {
  dynamic.decode7(
    CreateEventSubSubscriptionResponse,
    dynamic.field("id", dynamic.string),
    dynamic.field("status", subscription.subscription_status_decoder()),
    dynamic.field("type", subscription.subscription_type_decoder()),
    dynamic.field("version", dynamic.string),
    dynamic.field("condition", condition.decoder()),
    dynamic.field("created_at", dynamic.string),
    dynamic.field("cost", dynamic.int),
  )
}

pub fn create_eventsub_subscription(
  client: Client,
  request: CreateEventSubscriptionRequest,
) -> Result(EventSubData(List(CreateEventSubSubscriptionResponse)), TwitchError) {
  let api_req =
    api_request.new_helix_request()
    |> api_request.set_body(send_message_request_to_json(request))
    |> api_request.set_path("eventsub/subscriptions")

  use response <- result.try(client.post(client, api_req))

  api_response.get_eventsub_data(
    response,
    create_eventsub_subscription_response_decoder(),
  )
}
