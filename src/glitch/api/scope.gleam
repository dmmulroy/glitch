pub type Scope {
  AnalyticsReadExtensions
  AnalyticsReadGames
  BitsRead
  ChannelManageAds
  ChannelReadAds
  ChannelManageBroadcast
  ChannelReadCharity
  ChannelEditCommercial
  ChannelReadEditors
  ChannelManageExtensions
  ChannelReadGoals
  ChannelReadGuestStar
  ChannelManageGuestStar
  ChannelReadHypeTrain
  ChannelManageModerators
  ChannelReadPolls
  ChannelManagePolls
  ChannelReadPredictions
  ChannelManagePredictions
  ChannelManageRaids
  ChannelReadRedemptions
  ChannelManageRedemptions
  ChannelManageSchedule
  ChannelReadStreamKey
  ChannelReadSubscriptions
  ChannelManageVideos
  ChannelReadVips
  ChannelManageVips
  ClipsEdit
  ModerationRead
  ModeratorManageAnnouncements
  ModeratorManageAutomod
  ModeratorReadAutomodSettings
  ModeratorManageAutomodSettings
  ModeratorManageBannedUsers
  ModeratorReadBlockedTerms
  ModeratorManageBlockedTerms
  ModeratorManageChatMessages
  ModeratorReadChatSettings
  ModeratorManageChatSettings
  ModeratorReadChatters
  ModeratorReadFollowers
  ModeratorReadGuestStar
  ModeratorManageGuestStar
  ModeratorReadShieldMode
  ModeratorManageShieldMode
  ModeratorReadShoutouts
  ModeratorManageShoutouts
  ModeratorReadUnbanRequests
  ModeratorManageUnbanRequests
  UserEdit
  UserEditFollows
  UserReadBlockedUsers
  UserManageBlockedUsers
  UserReadBroadcast
  UserManageChatColor
  UserReadEmail
  UserReadEmotes
  UserReadFollows
  UserReadModeratedChannels
  UserReadSubscriptions
  UserManageWhispers
  ChannelBot
  ChannelModerate
  ChatEdit
  ChatRead
  UserBot
  UserReadChat
  UserWriteChat
  WhispersRead
  WhispersEdit
}

pub const scopes: List(Scope) = [
  AnalyticsReadExtensions,
  AnalyticsReadGames,
  BitsRead,
  ChannelManageAds,
  ChannelReadAds,
  ChannelManageBroadcast,
  ChannelReadCharity,
  ChannelEditCommercial,
  ChannelReadEditors,
  ChannelManageExtensions,
  ChannelReadGoals,
  ChannelReadGuestStar,
  ChannelManageGuestStar,
  ChannelReadHypeTrain,
  ChannelManageModerators,
  ChannelReadPolls,
  ChannelManagePolls,
  ChannelReadPredictions,
  ChannelManagePredictions,
  ChannelManageRaids,
  ChannelReadRedemptions,
  ChannelManageRedemptions,
  ChannelManageSchedule,
  ChannelReadStreamKey,
  ChannelReadSubscriptions,
  ChannelManageVideos,
  ChannelReadVips,
  ChannelManageVips,
  ClipsEdit,
  ModerationRead,
  ModeratorManageAnnouncements,
  ModeratorManageAutomod,
  ModeratorReadAutomodSettings,
  ModeratorManageAutomodSettings,
  ModeratorManageBannedUsers,
  ModeratorReadBlockedTerms,
  ModeratorManageBlockedTerms,
  ModeratorManageChatMessages,
  ModeratorReadChatSettings,
  ModeratorManageChatSettings,
  ModeratorReadChatters,
  ModeratorReadFollowers,
  ModeratorReadGuestStar,
  ModeratorManageGuestStar,
  ModeratorReadShieldMode,
  ModeratorManageShieldMode,
  ModeratorReadShoutouts,
  ModeratorManageShoutouts,
  ModeratorReadUnbanRequests,
  ModeratorManageUnbanRequests,
  UserEdit,
  UserEditFollows,
  UserReadBlockedUsers,
  UserManageBlockedUsers,
  UserReadBroadcast,
  UserManageChatColor,
  UserReadEmail,
  UserReadEmotes,
  UserReadFollows,
  UserReadModeratedChannels,
  UserReadSubscriptions,
  UserManageWhispers,
  ChannelBot,
  ChannelModerate,
  ChatEdit,
  ChatRead,
  UserBot,
  UserReadChat,
  UserWriteChat,
  WhispersRead,
  WhispersEdit,
]

pub fn to_string(scope: Scope) -> String {
  case scope {
    AnalyticsReadExtensions -> "analytics:read:extensions"
    AnalyticsReadGames -> "analytics:read:games"
    BitsRead -> "bits:read"
    ChannelManageAds -> "channel:manage:ads"
    ChannelReadAds -> "channel:read:ads"
    ChannelManageBroadcast -> "channel:manage:broadcast"
    ChannelReadCharity -> "channel:read:charity"
    ChannelEditCommercial -> "channel:edit:commercial"
    ChannelReadEditors -> "channel:read:editors"
    ChannelManageExtensions -> "channel:manage:extensions"
    ChannelReadGoals -> "channel:read:goals"
    ChannelReadGuestStar -> "channel:read:guest_star"
    ChannelManageGuestStar -> "channel:manage:guest_star"
    ChannelReadHypeTrain -> "channel:read:hype_train"
    ChannelManageModerators -> "channel:manage:moderators"
    ChannelReadPolls -> "channel:read:polls"
    ChannelManagePolls -> "channel:manage:polls"
    ChannelReadPredictions -> "channel:read:predictions"
    ChannelManagePredictions -> "channel:manage:predictions"
    ChannelManageRaids -> "channel:manage:raids"
    ChannelReadRedemptions -> "channel:read:redemptions"
    ChannelManageRedemptions -> "channel:manage:redemptions"
    ChannelManageSchedule -> "channel:manage:schedule"
    ChannelReadStreamKey -> "channel:read:stream_key"
    ChannelReadSubscriptions -> "channel:read:subscriptions"
    ChannelManageVideos -> "channel:manage:videos"
    ChannelReadVips -> "channel:read:vips"
    ChannelManageVips -> "channel:manage:vips"
    ClipsEdit -> "clips:edit"
    ModerationRead -> "moderation:read"
    ModeratorManageAnnouncements -> "moderator:manage:announcements"
    ModeratorManageAutomod -> "moderator:manage:automod"
    ModeratorReadAutomodSettings -> "moderator:read:automod_settings"
    ModeratorManageAutomodSettings -> "moderator:manage:automod_settings"
    ModeratorManageBannedUsers -> "moderator:manage:banned_users"
    ModeratorReadBlockedTerms -> "moderator:read:blocked_terms"
    ModeratorManageBlockedTerms -> "moderator:manage:blocked_terms"
    ModeratorManageChatMessages -> "moderator:manage:chat_messages"
    ModeratorReadChatSettings -> "moderator:read:chat_settings"
    ModeratorManageChatSettings -> "moderator:manage:chat_settings"
    ModeratorReadChatters -> "moderator:read:chatters"
    ModeratorReadFollowers -> "moderator:read:followers"
    ModeratorReadGuestStar -> "moderator:read:guest_star"
    ModeratorManageGuestStar -> "moderator:manage:guest_star"
    ModeratorReadShieldMode -> "moderator:read:shield_mode"
    ModeratorManageShieldMode -> "moderator:manage:shield_mode"
    ModeratorReadShoutouts -> "moderator:read:shoutouts"
    ModeratorManageShoutouts -> "moderator:manage:shoutouts"
    ModeratorReadUnbanRequests -> "moderator:read:unban_requests"
    ModeratorManageUnbanRequests -> "moderator:manage:unban_requests"
    UserEdit -> "user:edit"
    UserEditFollows -> "user:edit:follows"
    UserReadBlockedUsers -> "user:read:blocked_users"
    UserManageBlockedUsers -> "user:manage:blocked_users"
    UserReadBroadcast -> "user:read:broadcast"
    UserManageChatColor -> "user:manage:chat_color"
    UserReadEmail -> "user:read:email"
    UserReadEmotes -> "user:read:emotes"
    UserReadFollows -> "user:read:follows"
    UserReadModeratedChannels -> "user:read:moderated_channels"
    UserReadSubscriptions -> "user:read:subscriptions"
    UserManageWhispers -> "user:manage:whispers"
    ChannelBot -> "channel:bot"
    ChannelModerate -> "channel:moderate"
    ChatEdit -> "chat:edit"
    ChatRead -> "chat:read"
    UserBot -> "user:bot"
    UserReadChat -> "user:read:chat"
    UserWriteChat -> "user:write:chat"
    WhispersRead -> "whispers:read"
    WhispersEdit -> "whispers:edit"
  }
}

pub type InvalidScope {
  InvalidScope(String)
}

pub fn from_string(str: String) -> Result(Scope, InvalidScope) {
  case str {
    "analytics:read:extensions" -> Ok(AnalyticsReadExtensions)
    "analytics:read:games" -> Ok(AnalyticsReadGames)
    "bits:read" -> Ok(BitsRead)
    "channel:manage:ads" -> Ok(ChannelManageAds)
    "channel:read:ads" -> Ok(ChannelReadAds)
    "channel:manage:broadcast" -> Ok(ChannelManageBroadcast)
    "channel:read:charity" -> Ok(ChannelReadCharity)
    "channel:edit:commercial" -> Ok(ChannelEditCommercial)
    "channel:read:editors" -> Ok(ChannelReadEditors)
    "channel:manage:extensions" -> Ok(ChannelManageExtensions)
    "channel:read:goals" -> Ok(ChannelReadGoals)
    "channel:read:guest_star" -> Ok(ChannelReadGuestStar)
    "channel:manage:guest_star" -> Ok(ChannelManageGuestStar)
    "channel:read:hype_train" -> Ok(ChannelReadHypeTrain)
    "channel:manage:moderators" -> Ok(ChannelManageModerators)
    "channel:read:polls" -> Ok(ChannelReadPolls)
    "channel:manage:polls" -> Ok(ChannelManagePolls)
    "channel:read:predictions" -> Ok(ChannelReadPredictions)
    "channel:manage:predictions" -> Ok(ChannelManagePredictions)
    "channel:manage:raids" -> Ok(ChannelManageRaids)
    "channel:read:redemptions" -> Ok(ChannelReadRedemptions)
    "channel:manage:redemptions" -> Ok(ChannelManageRedemptions)
    "channel:manage:schedule" -> Ok(ChannelManageSchedule)
    "channel:read:stream_key" -> Ok(ChannelReadStreamKey)
    "channel:read:subscriptions" -> Ok(ChannelReadSubscriptions)
    "channel:manage:videos" -> Ok(ChannelManageVideos)
    "channel:read:vips" -> Ok(ChannelReadVips)
    "channel:manage:vips" -> Ok(ChannelManageVips)
    "clips:edit" -> Ok(ClipsEdit)
    "moderation:read" -> Ok(ModerationRead)
    "moderator:manage:announcements" -> Ok(ModeratorManageAnnouncements)
    "moderator:manage:automod" -> Ok(ModeratorManageAutomod)
    "moderator:read:automod_settings" -> Ok(ModeratorReadAutomodSettings)
    "moderator:manage:automod_settings" -> Ok(ModeratorManageAutomodSettings)
    "moderator:manage:banned_users" -> Ok(ModeratorManageBannedUsers)
    "moderator:read:blocked_terms" -> Ok(ModeratorReadBlockedTerms)
    "moderator:manage:blocked_terms" -> Ok(ModeratorManageBlockedTerms)
    "moderator:manage:chat_messages" -> Ok(ModeratorManageChatMessages)
    "moderator:read:chat_settings" -> Ok(ModeratorReadChatSettings)
    "moderator:manage:chat_settings" -> Ok(ModeratorManageChatSettings)
    "moderator:read:chatters" -> Ok(ModeratorReadChatters)
    "moderator:read:followers" -> Ok(ModeratorReadFollowers)
    "moderator:read:guest_star" -> Ok(ModeratorReadGuestStar)
    "moderator:manage:guest_star" -> Ok(ModeratorManageGuestStar)
    "moderator:read:shield_mode" -> Ok(ModeratorReadShieldMode)
    "moderator:manage:shield_mode" -> Ok(ModeratorManageShieldMode)
    "moderator:read:shoutouts" -> Ok(ModeratorReadShoutouts)
    "moderator:manage:shoutouts" -> Ok(ModeratorManageShoutouts)
    "moderator:read:unban_requests" -> Ok(ModeratorReadUnbanRequests)
    "moderator:manage:unban_requests" -> Ok(ModeratorManageUnbanRequests)
    "user:edit" -> Ok(UserEdit)
    "user:edit:follows" -> Ok(UserEditFollows)
    "user:read:blocked_users" -> Ok(UserReadBlockedUsers)
    "user:manage:blocked_users" -> Ok(UserManageBlockedUsers)
    "user:read:broadcast" -> Ok(UserReadBroadcast)
    "user:manage:chat_color" -> Ok(UserManageChatColor)
    "user:read:email" -> Ok(UserReadEmail)
    "user:read:emotes" -> Ok(UserReadEmotes)
    "user:read:follows" -> Ok(UserReadFollows)
    "user:read:moderated_channels" -> Ok(UserReadModeratedChannels)
    "user:read:subscriptions" -> Ok(UserReadSubscriptions)
    "user:manage:whispers" -> Ok(UserManageWhispers)
    "channel:bot" -> Ok(ChannelBot)
    "channel:moderate" -> Ok(ChannelModerate)
    "chat:edit" -> Ok(ChatEdit)
    "chat:read" -> Ok(ChatRead)
    "user:bot" -> Ok(UserBot)
    "user:read:chat" -> Ok(UserReadChat)
    "user:write:chat" -> Ok(UserWriteChat)
    "whispers:read" -> Ok(WhispersRead)
    "whispers:edit" -> Ok(WhispersEdit)
    _ -> Error(InvalidScope(str))
  }
}
