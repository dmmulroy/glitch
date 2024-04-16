import gleam/dynamic.{type Decoder, type Dynamic}
import gleam/json.{type DecodeError}
import gleam/option.{type Option}
import gleam/result
import gleam/uri.{type Uri}
import glitch/extended/dynamic_ext
import glitch/types/subscription.{type Subscription, type SubscriptionType}

pub type WebSocketMessage {
  Close
  NotificationMessage(
    metadata: SubscriptionMetadata,
    payload: NotificationMessagePayload,
  )
  SessionKeepaliveMessage(metadata: Metadata)
  UnhandledMessage(raw_message: String)
  WelcomeMessage(metadata: Metadata, payload: WelcomeMessagePayload)
}

pub fn from_json(json_string: String) -> Result(WebSocketMessage, DecodeError) {
  json.decode(json_string, decoder())
}

pub fn decoder() -> Decoder(WebSocketMessage) {
  dynamic.any([
    welcome_message_decoder(),
    notification_message_decoder(),
    session_keepalive_message_decoder(),
  ])
}

fn welcome_message_decoder() -> Decoder(WebSocketMessage) {
  dynamic.decode2(
    WelcomeMessage,
    dynamic.field("metadata", metadata_decoder()),
    dynamic.field("payload", welcome_message_payload_decoder()),
  )
}

// TODO: Figure out how to handle "strict", i.e. not allowing additional filds
fn session_keepalive_message_decoder() -> Decoder(WebSocketMessage) {
  dynamic.decode1(
    SessionKeepaliveMessage,
    dynamic.field("metadata", metadata_decoder()),
  )
}

fn notification_message_decoder() -> Decoder(WebSocketMessage) {
  dynamic.decode2(
    NotificationMessage,
    dynamic.field("metadata", subscription_metadata_decoder()),
    dynamic.field("payload", notification_message_payload_decoder()),
  )
}

pub type MessageType {
  Notification
  SessionWelcome
  SessionKeepalive
  SessionReconnect
  Revocation
}

pub fn message_type_to_string(message_type: MessageType) -> String {
  case message_type {
    Notification -> "notification"
    SessionWelcome -> "session_welcome"
    SessionKeepalive -> "session_keepalive"
    SessionReconnect -> "sessions_reconnect"
    Revocation -> "revocation"
  }
}

pub fn message_type_from_string(string: String) -> Result(MessageType, Nil) {
  case string {
    "notification" -> Ok(Notification)
    "session_welcome" -> Ok(SessionWelcome)
    "session_keepalive" -> Ok(SessionKeepalive)
    "sessions_reconnect" -> Ok(SessionReconnect)
    "revocation" -> Ok(Revocation)
    _ -> Error(Nil)
  }
}

fn message_type_decoder() -> Decoder(MessageType) {
  fn(data: Dynamic) {
    use string <- result.try(dynamic.string(data))

    string
    |> message_type_from_string
    |> result.replace_error([
      dynamic.DecodeError(
        expected: "MessageType",
        found: "String(" <> string <> ")",
        path: [],
      ),
    ])
  }
}

pub type Metadata {
  Metadata(
    message_id: String,
    message_type: MessageType,
    message_timestamp: String,
  )
}

fn metadata_decoder() -> Decoder(Metadata) {
  dynamic.decode3(
    Metadata,
    dynamic.field("message_id", dynamic.string),
    dynamic.field("message_type", message_type_decoder()),
    dynamic.field("message_timestamp", dynamic.string),
  )
}

pub type SubscriptionMetadata {
  SubscriptionMetadata(
    message_id: String,
    message_type: MessageType,
    message_timestamp: String,
    subscription_type: SubscriptionType,
    subscription_version: String,
  )
}

fn subscription_metadata_decoder() -> Decoder(SubscriptionMetadata) {
  dynamic.decode5(
    SubscriptionMetadata,
    dynamic.field("message_id", dynamic.string),
    dynamic.field("message_type", message_type_decoder()),
    dynamic.field("message_timestamp", dynamic.string),
    dynamic.field("subscription_type", subscription.subscription_type_decoder()),
    dynamic.field("subscription_version", dynamic.string),
  )
}

pub type SessionStatus {
  Connected
}

pub fn session_status_to_string(session_status: SessionStatus) -> String {
  case session_status {
    Connected -> "connnected"
  }
}

pub fn session_status_from_string(string: String) -> Result(SessionStatus, Nil) {
  case string {
    "connected" -> Ok(Connected)
    _ -> Error(Nil)
  }
}

fn session_status_decoder() -> Decoder(SessionStatus) {
  fn(data: Dynamic) {
    use string <- result.try(dynamic.string(data))

    string
    |> session_status_from_string
    |> result.replace_error([
      dynamic.DecodeError(
        expected: "SessionStatus",
        found: "String(" <> string <> ")",
        path: [],
      ),
    ])
  }
}

pub type Session {
  Session(
    id: String,
    status: SessionStatus,
    connected_at: String,
    keepalive_timeout_seconds: Int,
    reconnect_url: Option(Uri),
  )
}

fn session_decoder() -> Decoder(Session) {
  dynamic.decode5(
    Session,
    dynamic.field("id", dynamic.string),
    dynamic.field("status", session_status_decoder()),
    dynamic.field("connected_at", dynamic.string),
    dynamic.field("keepalive_timeout_seconds", dynamic.int),
    dynamic.field("reconnect_url", dynamic.optional(dynamic_ext.uri)),
  )
}

pub type WelcomeMessagePayload {
  WelcomeMessagePayload(session: Session)
}

fn welcome_message_payload_decoder() -> Decoder(WelcomeMessagePayload) {
  dynamic.decode1(
    WelcomeMessagePayload,
    dynamic.field("session", session_decoder()),
  )
}

pub type NotificationMessagePayload {
  NotificationMessagePayload(subscription: Subscription, event: Event)
}

fn notification_message_payload_decoder() -> Decoder(NotificationMessagePayload) {
  dynamic.decode2(
    NotificationMessagePayload,
    dynamic.field("subscription", subscription.decoder()),
    dynamic.field("event", event_decoder()),
  )
}

pub type Event {
  ChannelChatMessageEvent(
    badges: List(Badge),
    broadcaster_user_id: String,
    broadcaster_user_login: String,
    broadcaster_user_name: String,
    chatter_user_id: String,
    chatter_user_login: String,
    chatter_user_name: String,
    color: String,
    message: ChannelChatMessage,
    message_id: String,
    message_type: ChannelChatMessageType,
    cheer: Option(Cheer),
    channel_points_custom_reward_id: Option(String),
    reply: Option(ChannelChatMessageReply),
  )
  ChannelPointsCustomRewardRedemptionAddEvent(
    id: String,
    broadcaster_user_id: String,
    broadcaster_user_login: String,
    broadcaster_user_name: String,
    user_id: String,
    user_login: String,
    user_name: String,
    user_input: String,
    status: RewardStatus,
    reward: Reward,
    redeemed_at: String,
  )
}

pub type Reward {
  Reward(id: String, title: String, cost: Int, prompt: String)
}

pub fn reward_decoder() -> Decoder(Reward) {
  dynamic.decode4(
    Reward,
    dynamic.field("id", dynamic.string),
    dynamic.field("title", dynamic.string),
    dynamic.field("cost", dynamic.int),
    dynamic.field("prompt", dynamic.string),
  )
}

pub type RewardStatus {
  Canceled
  Fulfilled
  Unfulfilled
  Unknown
}

pub fn rewards_status_to_string(reward_status: RewardStatus) -> String {
  case reward_status {
    Canceled -> "canceled"
    Fulfilled -> "fulfilled"
    Unfulfilled -> "unfulfilled"
    Unknown -> "unknown"
  }
}

pub fn reward_status_from_string(string: String) -> Result(RewardStatus, Nil) {
  case string {
    "canceled" -> Ok(Canceled)
    "fulfilled" -> Ok(Fulfilled)
    "unfulfilled" -> Ok(Unfulfilled)
    "unknown" -> Ok(Unknown)
    _ -> Error(Nil)
  }
}

pub fn reward_status_decoder() -> Decoder(RewardStatus) {
  fn(data: Dynamic) {
    use string <- result.try(dynamic.string(data))

    string
    |> reward_status_from_string
    |> result.replace_error([
      dynamic.DecodeError(
        expected: "RewardsStatus",
        found: "String(" <> string <> ")",
        path: [],
      ),
    ])
  }
}

pub type Image {
  Image(url_1x: Uri, url_2x: Uri, url_3x: Uri)
}

pub fn image_decoder() -> Decoder(Image) {
  dynamic.decode3(
    Image,
    dynamic.field("url_1x", dynamic_ext.uri),
    dynamic.field("url_2x", dynamic_ext.uri),
    dynamic.field("url_3x", dynamic_ext.uri),
  )
}

pub type MaxPerStream {
  MaxPerStream(is_enabled: Bool, value: Int)
}

pub fn max_per_stream_decoder() -> Decoder(MaxPerStream) {
  dynamic.decode2(
    MaxPerStream,
    dynamic.field("is_enabled", dynamic.bool),
    dynamic.field("value", dynamic.int),
  )
}

pub type Cooldown {
  Cooldown(is_enabled: Bool, seconds: Int)
}

pub fn cooldown_decoder() -> Decoder(Cooldown) {
  dynamic.decode2(
    Cooldown,
    dynamic.field("is_enabled", dynamic.bool),
    dynamic.field("second", dynamic.int),
  )
}

fn event_decoder() -> Decoder(Event) {
  dynamic.any([
    channel_chat_messsage_event_decoder(),
    channel_points_custom_reward_redemption_add_event_decoder(),
  ])
}

fn channel_chat_messsage_event_decoder() -> Decoder(Event) {
  dynamic_ext.decode14(
    ChannelChatMessageEvent,
    dynamic.field("badges", dynamic.list(of: badge_decoder())),
    dynamic.field("broadcaster_user_id", dynamic.string),
    dynamic.field("broadcaster_user_login", dynamic.string),
    dynamic.field("broadcaster_user_name", dynamic.string),
    dynamic.field("chatter_user_id", dynamic.string),
    dynamic.field("chatter_user_login", dynamic.string),
    dynamic.field("chatter_user_name", dynamic.string),
    dynamic.field("color", dynamic.string),
    dynamic.field("message", channel_chat_message_decoder()),
    dynamic.field("message_id", dynamic.string),
    dynamic.field("message_type", channel_chat_messsage_type_decoder()),
    dynamic.optional_field("cheer", cheer_decoder()),
    dynamic.optional_field("channel_points_custom_reward_id", dynamic.string),
    dynamic.optional_field("reply", channel_chat_message_reply_decoder()),
  )
}

fn channel_points_custom_reward_redemption_add_event_decoder() -> Decoder(Event) {
  dynamic_ext.decode11(
    ChannelPointsCustomRewardRedemptionAddEvent,
    dynamic.field("id", dynamic.string),
    dynamic.field("broadcaster_user_id", dynamic.string),
    dynamic.field("broadcaster_user_login", dynamic.string),
    dynamic.field("broadcaster_user_name", dynamic.string),
    dynamic.field("user_id", dynamic.string),
    dynamic.field("user_login", dynamic.string),
    dynamic.field("user_name", dynamic.string),
    dynamic.field("user_input", dynamic.string),
    dynamic.field("status", reward_status_decoder()),
    dynamic.field("reward", reward_decoder()),
    dynamic.field("redeemed_at", dynamic.string),
  )
}

pub type ChannelChatMessageType {
  Text
  ChannelPointsHighlighted
  ChannelPointsSubOnly
  UserIntro
}

pub fn channel_chat_messsage_type_to_string(
  channel_chat_messsage_type: ChannelChatMessageType,
) -> String {
  case channel_chat_messsage_type {
    Text -> "text"
    ChannelPointsHighlighted -> "channel_point_highlighted"
    ChannelPointsSubOnly -> "channel_points_sub_only"
    UserIntro -> "user_intro"
  }
}

pub fn channel_chat_messsage_type_from_string(
  string: String,
) -> Result(ChannelChatMessageType, Nil) {
  case string {
    "text" -> Ok(Text)
    "channel_point_highlighted" -> Ok(ChannelPointsHighlighted)
    "channel_points_sub_only" -> Ok(ChannelPointsSubOnly)
    "user_intro" -> Ok(UserIntro)
    _ -> Error(Nil)
  }
}

pub fn channel_chat_messsage_type_decoder() -> Decoder(ChannelChatMessageType) {
  fn(data: dynamic.Dynamic) {
    use string <- result.try(dynamic.string(data))

    string
    |> channel_chat_messsage_type_from_string
    |> result.replace_error([
      dynamic.DecodeError(
        expected: "ChannelChatMessageType",
        found: "String(" <> string <> ")",
        path: [],
      ),
    ])
  }
}

pub type Badge {
  Badge(set_id: String, id: String, info: String)
}

pub fn badge_decoder() -> Decoder(Badge) {
  dynamic.decode3(
    Badge,
    dynamic.field("set_id", dynamic.string),
    dynamic.field("id", dynamic.string),
    dynamic.field("info", dynamic.string),
  )
}

pub type Cheer {
  Cheer(bits: Int)
}

pub fn cheer_decoder() -> Decoder(Cheer) {
  dynamic.decode1(Cheer, dynamic.field("bits", dynamic.int))
}

pub type ChannelChatMessageReply {
  ChannelChatMessageReply(
    parent_message_id: String,
    parent_message_body: String,
    parent_user_id: String,
    parent_user_name: String,
    thread_message_id: String,
    thread_user_id: String,
    thread_user_name: String,
    thread_user_login: String,
  )
}

pub fn channel_chat_message_reply_decoder() -> Decoder(ChannelChatMessageReply) {
  dynamic.decode8(
    ChannelChatMessageReply,
    dynamic.field("parent_message_id", dynamic.string),
    dynamic.field("parent_message_body", dynamic.string),
    dynamic.field("parent_message_body", dynamic.string),
    dynamic.field("parent_user_name", dynamic.string),
    dynamic.field("parent_user_name", dynamic.string),
    dynamic.field("thread_user_id", dynamic.string),
    dynamic.field("thread_user_id", dynamic.string),
    dynamic.field("thread_user_login", dynamic.string),
  )
}

pub type ChannelChatMessage {
  ChannelChatMessage(text: String, fragments: List(MessageFragment))
}

pub fn channel_chat_message_decoder() -> Decoder(ChannelChatMessage) {
  dynamic.decode2(
    ChannelChatMessage,
    dynamic.field("text", dynamic.string),
    dynamic.field("fragments", dynamic.list(of: message_fragment_decoder())),
  )
}

pub type MessageFragment {
  MessageFragment(
    fragment_type: FragmentType,
    text: String,
    cheermote: Option(Cheermote),
    emote: Option(Emote),
    mention: Option(Mention),
  )
}

fn message_fragment_decoder() -> Decoder(MessageFragment) {
  dynamic.decode5(
    MessageFragment,
    dynamic.field("type", fragment_type_decoder()),
    dynamic.field("text", dynamic.string),
    dynamic.optional_field("cheermote", cheermote_decoder()),
    dynamic.optional_field("emote", emote_decoder()),
    dynamic.optional_field("mention", mention_decoder()),
  )
}

pub type FragmentType {
  TextFragment
  CheermoteFragment
  EmoteFragment
  MentionFragment
}

pub fn fragment_type_to_string(fragment_type: FragmentType) -> String {
  case fragment_type {
    TextFragment -> "text"
    CheermoteFragment -> "cheermote"
    EmoteFragment -> "emote"
    MentionFragment -> "mentiond"
  }
}

pub fn fragment_type_from_string(string: String) -> Result(FragmentType, Nil) {
  case string {
    "text" -> Ok(TextFragment)
    "cheermote" -> Ok(CheermoteFragment)
    "emote" -> Ok(EmoteFragment)
    "mentiond" -> Ok(MentionFragment)
    _ -> Error(Nil)
  }
}

pub fn fragment_type_decoder() -> Decoder(FragmentType) {
  fn(data: dynamic.Dynamic) {
    use string <- result.try(dynamic.string(data))

    string
    |> fragment_type_from_string
    |> result.replace_error([
      dynamic.DecodeError(
        expected: "FragmentType",
        found: "String(" <> string <> ")",
        path: [],
      ),
    ])
  }
}

pub type Cheermote {
  Cheermote(prefix: String, bits: Int, tier: Int)
}

pub fn cheermote_decoder() -> Decoder(Cheermote) {
  dynamic.decode3(
    Cheermote,
    dynamic.field("prefix", dynamic.string),
    dynamic.field("bits", dynamic.int),
    dynamic.field("tier", dynamic.int),
  )
}

pub type Emote {
  Emote(id: String, emote_set_id: String, owner_id: String, format: EmoteFormat)
}

pub fn emote_decoder() -> Decoder(Emote) {
  dynamic.decode4(
    Emote,
    dynamic.field("id", dynamic.string),
    dynamic.field("emote_set_id", dynamic.string),
    dynamic.field("owner_id", dynamic.string),
    dynamic.field("format", emote_format_decoder()),
  )
}

pub type EmoteFormat {
  Animated
  Static
}

pub fn emote_format_to_string(emote_format: EmoteFormat) -> String {
  case emote_format {
    Animated -> "animated"
    Static -> "static"
  }
}

pub fn emote_format_from_string(string: String) -> Result(EmoteFormat, Nil) {
  case string {
    "animated" -> Ok(Animated)
    "static" -> Ok(Static)
    _ -> Error(Nil)
  }
}

pub fn emote_format_decoder() -> Decoder(EmoteFormat) {
  fn(data: dynamic.Dynamic) {
    use string <- result.try(dynamic.string(data))

    string
    |> emote_format_from_string
    |> result.replace_error([
      dynamic.DecodeError(
        expected: "EmoteFormat",
        found: "String(" <> string <> ")",
        path: [],
      ),
    ])
  }
}

pub type Mention {
  Mention(user_id: String, user_name: String, user_login: String)
}

pub fn mention_decoder() -> Decoder(Mention) {
  dynamic.decode3(
    Mention,
    dynamic.field("user_id", dynamic.string),
    dynamic.field("user_name", dynamic.string),
    dynamic.field("user_login", dynamic.string),
  )
}
