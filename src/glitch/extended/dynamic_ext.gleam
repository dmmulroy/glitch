import gleam/dynamic.{
  type DecodeError, type DecodeErrors, type Decoder, type Dynamic,
}
import gleam/list
import gleam/result
import gleam/uri.{type Uri}

pub fn uri(dyn: Dynamic) -> Result(Uri, List(DecodeError)) {
  result.try(dynamic.string(dyn), fn(str) {
    str
    |> uri.parse
    |> result.replace_error([
      dynamic.DecodeError(expected: "Uri", found: "String", path: []),
    ])
  })
}

fn decode_field(
  from dyn: Dynamic,
  using decoder: Decoder(a),
) -> Result(a, DecodeErrors) {
  decoder(dyn)
}

pub fn decode_bool_field(
  dyn: Dynamic,
  field_name: String,
) -> Result(Bool, DecodeErrors) {
  decode_field(dyn, dynamic.field(field_name, dynamic.bool))
}

pub fn decode_int_field(
  dyn: Dynamic,
  field_name: String,
) -> Result(Int, DecodeErrors) {
  decode_field(dyn, dynamic.field(field_name, dynamic.int))
}

pub fn decode_string_field(
  dyn: Dynamic,
  field_name: String,
) -> Result(String, DecodeErrors) {
  decode_field(dyn, dynamic.field(field_name, dynamic.string))
}

pub fn decode_uri_field(
  dyn: Dynamic,
  field_name: String,
) -> Result(Uri, DecodeErrors) {
  result.try(decode_string_field(dyn, field_name), fn(str) {
    str
    |> uri.parse
    |> result.replace_error([
      dynamic.DecodeError(expected: "Uri", found: "String", path: [field_name]),
    ])
  })
}

pub fn decode11(
  constructor: fn(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11) -> t,
  t1: Decoder(t1),
  t2: Decoder(t2),
  t3: Decoder(t3),
  t4: Decoder(t4),
  t5: Decoder(t5),
  t6: Decoder(t6),
  t7: Decoder(t7),
  t8: Decoder(t8),
  t9: Decoder(t9),
  t10: Decoder(t10),
  t11: Decoder(t11),
) -> Decoder(t) {
  fn(x: Dynamic) {
    case
      t1(x),
      t2(x),
      t3(x),
      t4(x),
      t5(x),
      t6(x),
      t7(x),
      t8(x),
      t9(x),
      t10(x),
      t11(x)
    {
      Ok(a),
        Ok(b),
        Ok(c),
        Ok(d),
        Ok(e),
        Ok(f),
        Ok(g),
        Ok(h),
        Ok(i),
        Ok(j),
        Ok(k)
      -> Ok(constructor(a, b, c, d, e, f, g, h, i, j, k))
      a, b, c, d, e, f, g, h, i, j, k ->
        Error(
          list.concat([
            all_errors(a),
            all_errors(b),
            all_errors(c),
            all_errors(d),
            all_errors(e),
            all_errors(f),
            all_errors(g),
            all_errors(h),
            all_errors(i),
            all_errors(j),
            all_errors(k),
          ]),
        )
    }
  }
}

pub fn decode14(
  constructor: fn(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14) ->
    t,
  t1: Decoder(t1),
  t2: Decoder(t2),
  t3: Decoder(t3),
  t4: Decoder(t4),
  t5: Decoder(t5),
  t6: Decoder(t6),
  t7: Decoder(t7),
  t8: Decoder(t8),
  t9: Decoder(t9),
  t10: Decoder(t10),
  t11: Decoder(t11),
  t12: Decoder(t12),
  t13: Decoder(t13),
  t14: Decoder(t14),
) -> Decoder(t) {
  fn(x: Dynamic) {
    case
      t1(x),
      t2(x),
      t3(x),
      t4(x),
      t5(x),
      t6(x),
      t7(x),
      t8(x),
      t9(x),
      t10(x),
      t11(x),
      t12(x),
      t13(x),
      t14(x)
    {
      Ok(a),
        Ok(b),
        Ok(c),
        Ok(d),
        Ok(e),
        Ok(f),
        Ok(g),
        Ok(h),
        Ok(i),
        Ok(j),
        Ok(k),
        Ok(l),
        Ok(m),
        Ok(n)
      -> Ok(constructor(a, b, c, d, e, f, g, h, i, j, k, l, m, n))
      a, b, c, d, e, f, g, h, i, j, k, l, m, n ->
        Error(
          list.concat([
            all_errors(a),
            all_errors(b),
            all_errors(c),
            all_errors(d),
            all_errors(e),
            all_errors(f),
            all_errors(g),
            all_errors(h),
            all_errors(i),
            all_errors(j),
            all_errors(k),
            all_errors(l),
            all_errors(m),
            all_errors(n),
          ]),
        )
    }
  }
}

fn all_errors(result: Result(a, List(DecodeError))) -> List(DecodeError) {
  case result {
    Ok(_) -> []
    Error(errors) -> errors
  }
}

pub fn decode20(
  constructor: fn(
    t1,
    t2,
    t3,
    t4,
    t5,
    t6,
    t7,
    t8,
    t9,
    t10,
    t11,
    t12,
    t13,
    t14,
    t15,
    t16,
    t17,
    t18,
    t19,
    t20,
  ) ->
    t,
  t1: Decoder(t1),
  t2: Decoder(t2),
  t3: Decoder(t3),
  t4: Decoder(t4),
  t5: Decoder(t5),
  t6: Decoder(t6),
  t7: Decoder(t7),
  t8: Decoder(t8),
  t9: Decoder(t9),
  t10: Decoder(t10),
  t11: Decoder(t11),
  t12: Decoder(t12),
  t13: Decoder(t13),
  t14: Decoder(t14),
  t15: Decoder(t15),
  t16: Decoder(t16),
  t17: Decoder(t17),
  t18: Decoder(t18),
  t19: Decoder(t19),
  t20: Decoder(t20),
) -> Decoder(t) {
  fn(x: Dynamic) {
    case
      t1(x),
      t2(x),
      t3(x),
      t4(x),
      t5(x),
      t6(x),
      t7(x),
      t8(x),
      t9(x),
      t10(x),
      t11(x),
      t12(x),
      t13(x),
      t14(x),
      t15(x),
      t16(x),
      t17(x),
      t18(x),
      t19(x),
      t20(x)
    {
      Ok(a),
        Ok(b),
        Ok(c),
        Ok(d),
        Ok(e),
        Ok(f),
        Ok(g),
        Ok(h),
        Ok(i),
        Ok(j),
        Ok(k),
        Ok(l),
        Ok(m),
        Ok(n),
        Ok(o),
        Ok(p),
        Ok(q),
        Ok(r),
        Ok(s),
        Ok(t)
      ->
        Ok(constructor(
          a,
          b,
          c,
          d,
          e,
          f,
          g,
          h,
          i,
          j,
          k,
          l,
          m,
          n,
          o,
          p,
          q,
          r,
          s,
          t,
        ))
      a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t ->
        Error(
          list.concat([
            all_errors(a),
            all_errors(b),
            all_errors(c),
            all_errors(d),
            all_errors(e),
            all_errors(f),
            all_errors(g),
            all_errors(h),
            all_errors(i),
            all_errors(j),
            all_errors(k),
            all_errors(l),
            all_errors(m),
            all_errors(n),
            all_errors(o),
            all_errors(p),
            all_errors(q),
            all_errors(r),
            all_errors(s),
            all_errors(t),
          ]),
        )
    }
  }
}
