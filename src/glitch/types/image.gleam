import gleam/dynamic.{type Decoder}
import gleam/uri.{type Uri}
import glitch/extended/dynamic_ext

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
