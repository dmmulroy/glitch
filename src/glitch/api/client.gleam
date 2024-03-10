pub type Options {
  Options(client_id: String, access_token: String)
}

pub opaque type Client {
  Client(options: Options)
}

pub const make = Client
