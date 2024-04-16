import gleam/dynamic.{type Decoder}
import gleam/option.{type Option}
import gleam/result
import glitch/types/cheermote.{type Cheermote}
import glitch/types/emote.{type Emote}

pub type Message {
  Message(text: String, fragments: List(Fragment))
}

pub fn decoder() -> Decoder(Message) {
  dynamic.decode2(
    Message,
    dynamic.field("text", dynamic.string),
    dynamic.field("fragments", dynamic.list(of: message_fragment_decoder())),
  )
}

pub type MessageType {
  Text
  ChannelPointsHighlighted
  ChannelPointsSubOnly
  UserIntro
}

pub fn messsage_type_to_string(messsage_type: MessageType) -> String {
  case messsage_type {
    Text -> "text"
    ChannelPointsHighlighted -> "channel_point_highlighted"
    ChannelPointsSubOnly -> "channel_points_sub_only"
    UserIntro -> "user_intro"
  }
}

pub fn messsage_type_from_string(string: String) -> Result(MessageType, Nil) {
  case string {
    "text" -> Ok(Text)
    "channel_point_highlighted" -> Ok(ChannelPointsHighlighted)
    "channel_points_sub_only" -> Ok(ChannelPointsSubOnly)
    "user_intro" -> Ok(UserIntro)
    _ -> Error(Nil)
  }
}

pub fn messsage_type_decoder() -> Decoder(MessageType) {
  fn(data: dynamic.Dynamic) {
    use string <- result.try(dynamic.string(data))

    string
    |> messsage_type_from_string
    |> result.replace_error([
      dynamic.DecodeError(
        expected: "MessageType",
        found: "String(" <> string <> ")",
        path: [],
      ),
    ])
  }
}

pub type Fragment {
  Fragment(
    fragment_type: FragmentType,
    text: String,
    cheermote: Option(Cheermote),
    emote: Option(Emote),
    mention: Option(Mention),
  )
}

fn message_fragment_decoder() -> Decoder(Fragment) {
  dynamic.decode5(
    Fragment,
    dynamic.field("type", fragment_type_decoder()),
    dynamic.field("text", dynamic.string),
    dynamic.optional_field("cheermote", cheermote.decoder()),
    dynamic.optional_field("emote", emote.decoder()),
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

pub type Reply {
  Reply(
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

pub fn reply_decoder() -> Decoder(Reply) {
  dynamic.decode8(
    Reply,
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
