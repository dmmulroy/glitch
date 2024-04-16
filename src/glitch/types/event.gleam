import gleam/dynamic.{type Decoder}
import gleam/option.{type Option}
import glitch/extended/dynamic_ext
import glitch/types/badge.{type Badge}
import glitch/types/cheer.{type Cheer}
import glitch/types/message.{type Message, type MessageType, type Reply}
import glitch/types/reward.{type Reward}

pub type Event {
  MessageEvent(
    badges: List(Badge),
    broadcaster_user_id: String,
    broadcaster_user_login: String,
    broadcaster_user_name: String,
    chatter_user_id: String,
    chatter_user_login: String,
    chatter_user_name: String,
    color: String,
    message: Message,
    message_id: String,
    message_type: MessageType,
    cheer: Option(Cheer),
    channel_points_custom_reward_id: Option(String),
    reply: Option(Reply),
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
    status: reward.Status,
    reward: Reward,
    redeemed_at: String,
  )
}

pub fn decoder() -> Decoder(Event) {
  dynamic.any([
    channel_chat_messsage_event_decoder(),
    channel_points_custom_reward_redemption_add_event_decoder(),
  ])
}

fn channel_chat_messsage_event_decoder() -> Decoder(Event) {
  dynamic_ext.decode14(
    MessageEvent,
    dynamic.field("badges", dynamic.list(of: badge.decoder())),
    dynamic.field("broadcaster_user_id", dynamic.string),
    dynamic.field("broadcaster_user_login", dynamic.string),
    dynamic.field("broadcaster_user_name", dynamic.string),
    dynamic.field("chatter_user_id", dynamic.string),
    dynamic.field("chatter_user_login", dynamic.string),
    dynamic.field("chatter_user_name", dynamic.string),
    dynamic.field("color", dynamic.string),
    dynamic.field("message", message.decoder()),
    dynamic.field("message_id", dynamic.string),
    dynamic.field("message_type", message.messsage_type_decoder()),
    dynamic.optional_field("cheer", cheer.decoder()),
    dynamic.optional_field("channel_points_custom_reward_id", dynamic.string),
    dynamic.optional_field("reply", message.reply_decoder()),
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
    dynamic.field("status", reward.reward_status_decoder()),
    dynamic.field("reward", reward.reward_decoder()),
    dynamic.field("redeemed_at", dynamic.string),
  )
}
