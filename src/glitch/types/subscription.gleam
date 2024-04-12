import gleam/dynamic.{type Decoder}
import gleam/json.{type DecodeError as JsonDecodeError, type Json}
import gleam/result

pub type SubscriptionType {
  AutomodMessageHold
  AutomodMessageUpdate
  AutomodSettingsUpdate
  AutomodTermsUpdate
  ChannelUpdate
  ChannelFollow
  ChannelAdBreakBegin
  ChannelChatClear
  ChannelChatClearUserMessages
  ChannelChatMessage
  ChannelChatMessageDelete
  ChannelChatNotification
  ChannelChatSettingsUpdate
  ChannelChatUserMessageHold
  ChannelChatUserMessageUpdate
  ChannelSubscribe
  ChannelSubscriptionEnd
  ChannelSubscriptionGift
  ChannelSubscriptionMessage
  ChannelCheer
  ChannelRaid
  ChannelBan
  ChannelUnban
  ChannelUnbanRequestCreate
  ChannelUnbanRequestResolve
  ChannelModerate
  ChannelModeratorAdd
  ChannelModeratorRemove
  ChannelGuestStarSessionBegin
  ChannelGuestStarSessionEnd
  ChannelGuestStarGuestUpdate
  ChannelGuestStarSettingsUpdate
  ChannelPointsAutomaticRewardRedemption
  ChannelPointsCustomRewardAdd
  ChannelPointsCustomRewardUpdate
  ChannelPointsCustomRewardRemove
  ChannelPointsCustomRewardRedemptionAdd
  ChannelPointsCustomRewardRedemptionUpdate
  ChannelPollBegin
  ChannelPollProgress
  ChannelPollEnd
  ChannelPredictionBegin
  ChannelPredictionProgress
  ChannelPredictionLock
  ChannelPredictionEnd
  ChannelSuspiciousUserMessage
  ChannelSuspiciousUserUpdate
  ChannelVIPAdd
  ChannelVIPRemove
  CharityDonation
  CharityCampaignStart
  CharityCampaignProgress
  CharityCampaignStop
  ConduitShardDisabled
  DropEntitlementGrant
  ExtensionBitsTransactionCreate
  GoalBegin
  GoalProgress
  GoalEnd
  HypeTrainBegin
  HypeTrainProgress
  HypeTrainEnd
  ShieldModeBegin
  ShieldModeEnd
  ShoutoutCreate
  ShoutoutReceived
  StreamOnline
  StreamOffline
  UserAuthorizationGrant
  UserAuthorizationRevoke
  UserUpdate
  WhisperReceived
}

pub type SubscriptionTypeError {
  InvalidSubscriptionType(String)
  DecodeError(JsonDecodeError)
}

pub fn to_string(subscription_type: SubscriptionType) -> String {
  case subscription_type {
    AutomodMessageHold -> "automod.message.hold"
    AutomodMessageUpdate -> "automod.message.update"
    AutomodSettingsUpdate -> "automod.settings.update"
    AutomodTermsUpdate -> "automod.terms.update"
    ChannelUpdate -> "channel.update"
    ChannelFollow -> "channel.follow"
    ChannelAdBreakBegin -> "channel.ad_break.begin"
    ChannelChatClear -> "channel.chat.clear"
    ChannelChatClearUserMessages -> "channel.chat.clear_user_messages"
    ChannelChatMessage -> "channel.chat.message"
    ChannelChatMessageDelete -> "channel.chat.message_delete"
    ChannelChatNotification -> "channel.chat.notification"
    ChannelChatSettingsUpdate -> "channel.chat_settings.update"
    ChannelChatUserMessageHold -> "channel.chat.user_message_hold"
    ChannelChatUserMessageUpdate -> "channel.chat.user_message_update"
    ChannelSubscribe -> "channel.subscribe"
    ChannelSubscriptionEnd -> "channel.subscription.end"
    ChannelSubscriptionGift -> "channel.subscription.gift"
    ChannelSubscriptionMessage -> "channel.subscription.message"
    ChannelCheer -> "channel.cheer"
    ChannelRaid -> "channel.raid"
    ChannelBan -> "channel.ban"
    ChannelUnban -> "channel.unban"
    ChannelUnbanRequestCreate -> "channel.unban_request.create"
    ChannelUnbanRequestResolve -> "channel.unban_request.resolve"
    ChannelModerate -> "channel.moderate"
    ChannelModeratorAdd -> "channel.moderator.add"
    ChannelModeratorRemove -> "channel.moderator.remove"
    ChannelGuestStarSessionBegin -> "channel.guest_star_session.begin"
    ChannelGuestStarSessionEnd -> "channel.guest_star_session.end"
    ChannelGuestStarGuestUpdate -> "channel.guest_star_guest.update"
    ChannelGuestStarSettingsUpdate -> "channel.guest_star_settings.update"
    ChannelPointsAutomaticRewardRedemption ->
      "channel.channel_points_automatic_reward_redemption.add"
    ChannelPointsCustomRewardAdd -> "channel.channel_points_custom_reward.add"
    ChannelPointsCustomRewardUpdate ->
      "channel.channel_points_custom_reward.update"
    ChannelPointsCustomRewardRemove ->
      "channel.channel_points_custom_reward.remove"
    ChannelPointsCustomRewardRedemptionAdd ->
      "channel.channel_points_custom_reward_redemption.add"
    ChannelPointsCustomRewardRedemptionUpdate ->
      "channel.channel_points_custom_reward_redemption.update"
    ChannelPollBegin -> "channel.poll.begin"
    ChannelPollProgress -> "channel.poll.progress"
    ChannelPollEnd -> "channel.poll.end"
    ChannelPredictionBegin -> "channel.prediction.begin"
    ChannelPredictionProgress -> "channel.prediction.progress"
    ChannelPredictionLock -> "channel.prediction.lock"
    ChannelPredictionEnd -> "channel.prediction.end"
    ChannelSuspiciousUserMessage -> "channel.suspicious_user.message"
    ChannelSuspiciousUserUpdate -> "channel.suspicious_user.update"
    ChannelVIPAdd -> "channel.vip.add"
    ChannelVIPRemove -> "channel.vip.remove"
    CharityDonation -> "channel.charity_campaign.donate"
    CharityCampaignStart -> "channel.charity_campaign.start"
    CharityCampaignProgress -> "channel.charity_campaign.progress"
    CharityCampaignStop -> "channel.charity_campaign.stop"
    ConduitShardDisabled -> "conduit.shard.disabled"
    DropEntitlementGrant -> "drop.entitlement.grant"
    ExtensionBitsTransactionCreate -> "extension.bits_transaction.create"
    GoalBegin -> "channel.goal.begin"
    GoalProgress -> "channel.goal.progress"
    GoalEnd -> "channel.goal.end"
    HypeTrainBegin -> "channel.hype_train.begin"
    HypeTrainProgress -> "channel.hype_train.progress"
    HypeTrainEnd -> "channel.hype_train.end"
    ShieldModeBegin -> "channel.shield_mode.begin"
    ShieldModeEnd -> "channel.shield_mode.end"
    ShoutoutCreate -> "channel.shoutout.create"
    ShoutoutReceived -> "channel.shoutout.receive"
    StreamOnline -> "stream.online"
    StreamOffline -> "stream.offline"
    UserAuthorizationGrant -> "user.authorization.grant"
    UserAuthorizationRevoke -> "user.authorization.revoke"
    UserUpdate -> "user.update"
    WhisperReceived -> "user.whisper.message"
  }
}

pub fn from_string(
  str: String,
) -> Result(SubscriptionType, SubscriptionTypeError) {
  case str {
    "automod.message.hold" -> Ok(AutomodMessageHold)
    "automod.message.update" -> Ok(AutomodMessageUpdate)
    "automod.settings.update" -> Ok(AutomodSettingsUpdate)
    "automod.terms.update" -> Ok(AutomodTermsUpdate)
    "channel.update" -> Ok(ChannelUpdate)
    "channel.follow" -> Ok(ChannelFollow)
    "channel.ad_break.begin" -> Ok(ChannelAdBreakBegin)
    "channel.chat.clear" -> Ok(ChannelChatClear)
    "channel.chat.clear_user_messages" -> Ok(ChannelChatClearUserMessages)
    "channel.chat.message" -> Ok(ChannelChatMessage)
    "channel.chat.message_delete" -> Ok(ChannelChatMessageDelete)
    "channel.chat.notification" -> Ok(ChannelChatNotification)
    "channel.chat_settings.update" -> Ok(ChannelChatSettingsUpdate)
    "channel.chat.user_message_hold" -> Ok(ChannelChatUserMessageHold)
    "channel.chat.user_message_update" -> Ok(ChannelChatUserMessageUpdate)
    "channel.subscribe" -> Ok(ChannelSubscribe)
    "channel.subscription.end" -> Ok(ChannelSubscriptionEnd)
    "channel.subscription.gift" -> Ok(ChannelSubscriptionGift)
    "channel.subscription.message" -> Ok(ChannelSubscriptionMessage)
    "channel.cheer" -> Ok(ChannelCheer)
    "channel.raid" -> Ok(ChannelRaid)
    "channel.ban" -> Ok(ChannelBan)
    "channel.unban" -> Ok(ChannelUnban)
    "channel.unban_request.create" -> Ok(ChannelUnbanRequestCreate)
    "channel.unban_request.resolve" -> Ok(ChannelUnbanRequestResolve)
    "channel.moderate" -> Ok(ChannelModerate)
    "channel.moderator.add" -> Ok(ChannelModeratorAdd)
    "channel.moderator.remove" -> Ok(ChannelModeratorRemove)
    "channel.guest_star_session.begin" -> Ok(ChannelGuestStarSessionBegin)
    "channel.guest_star_session.end" -> Ok(ChannelGuestStarSessionEnd)
    "channel.guest_star_guest.update" -> Ok(ChannelGuestStarGuestUpdate)
    "channel.guest_star_settings.update" -> Ok(ChannelGuestStarSettingsUpdate)
    "channel.channel_points_automatic_reward_redemption.add" ->
      Ok(ChannelPointsAutomaticRewardRedemption)
    "channel.channel_points_custom_reward.add" ->
      Ok(ChannelPointsCustomRewardAdd)
    "channel.channel_points_custom_reward.update" ->
      Ok(ChannelPointsCustomRewardUpdate)
    "channel.channel_points_custom_reward.remove" ->
      Ok(ChannelPointsCustomRewardRemove)
    "channel.channel_points_custom_reward_redemption.add" ->
      Ok(ChannelPointsCustomRewardRedemptionAdd)
    "channel.channel_points_custom_reward_redemption.update" ->
      Ok(ChannelPointsCustomRewardRedemptionUpdate)
    "channel.poll.begin" -> Ok(ChannelPollBegin)
    "channel.poll.progress" -> Ok(ChannelPollProgress)
    "channel.poll.end" -> Ok(ChannelPollEnd)
    "channel.prediction.begin" -> Ok(ChannelPredictionBegin)
    "channel.prediction.progress" -> Ok(ChannelPredictionProgress)
    "channel.prediction.lock" -> Ok(ChannelPredictionLock)
    "channel.prediction.end" -> Ok(ChannelPredictionEnd)
    "channel.suspicious_user.message" -> Ok(ChannelSuspiciousUserMessage)
    "channel.suspicious_user.update" -> Ok(ChannelSuspiciousUserUpdate)
    "channel.vip.add" -> Ok(ChannelVIPAdd)
    "channel.vip.remove" -> Ok(ChannelVIPRemove)
    "channel.charity_campaign.donate" -> Ok(CharityDonation)
    "channel.charity_campaign.start" -> Ok(CharityCampaignStart)
    "channel.charity_campaign.progress" -> Ok(CharityCampaignProgress)
    "channel.charity_campaign.stop" -> Ok(CharityCampaignStop)
    "conduit.shard.disabled" -> Ok(ConduitShardDisabled)
    "drop.entitlement.grant" -> Ok(DropEntitlementGrant)
    "extension.bits_transaction.create" -> Ok(ExtensionBitsTransactionCreate)
    "channel.goal.begin" -> Ok(GoalBegin)
    "channel.goal.progress" -> Ok(GoalProgress)
    "channel.goal.end" -> Ok(GoalEnd)
    "channel.hype_train.begin" -> Ok(HypeTrainBegin)
    "channel.hype_train.progress" -> Ok(HypeTrainProgress)
    "channel.hype_train.end" -> Ok(HypeTrainEnd)
    "channel.shield_mode.begin" -> Ok(ShieldModeBegin)
    "channel.shield_mode.end" -> Ok(ShieldModeEnd)
    "channel.shoutout.create" -> Ok(ShoutoutCreate)
    "channel.shoutout.receive" -> Ok(ShoutoutReceived)
    "stream.online" -> Ok(StreamOnline)
    "stream.offline" -> Ok(StreamOffline)
    "user.authorization.grant" -> Ok(UserAuthorizationGrant)
    "user.authorization.revoke" -> Ok(UserAuthorizationRevoke)
    "user.update" -> Ok(UserUpdate)
    "user.whisper.message" -> Ok(WhisperReceived)
    _ -> Error(InvalidSubscriptionType(str))
  }
}

pub fn decoder() -> Decoder(SubscriptionType) {
  fn(data: dynamic.Dynamic) {
    use string <- result.try(dynamic.string(data))

    string
    |> from_string
    |> result.replace_error([
      dynamic.DecodeError(
        expected: "SubscriptionType",
        found: "String(" <> string <> ")",
        path: [],
      ),
    ])
  }
}

pub fn to_json(subscription_type: SubscriptionType) -> Json {
  subscription_type
  |> to_string
  |> json.string
}

pub fn from_json(
  json_string: String,
) -> Result(SubscriptionType, SubscriptionTypeError) {
  json_string
  |> json.decode(dynamic.string)
  |> result.map_error(DecodeError)
  |> result.try(from_string)
}
