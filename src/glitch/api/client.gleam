import gleam/http.{type Header}

pub opaque type Client {
  Client(options: Options)
}

pub type Options {
  Options(client_id: String, access_token: String)
}

pub const make = Client

pub fn client_id(client: Client) -> String {
  client.options.client_id
}

pub fn access_token(client: Client) -> String {
  client.options.access_token
}

pub fn headers(client: Client) -> List(Header) {
  let client_id = client_id(client)
  let access_token = access_token(client)

  [#("client_id", client_id), #("access_token", access_token)]
}
