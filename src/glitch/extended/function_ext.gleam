pub fn compose(fun1: fn(a) -> b, fun2: fn(b) -> c) -> fn(a) -> c {
  fn(a) { fun2(fun1(a)) }
}

pub fn constant(value: value) -> fn(anything) -> value {
  fn(_) { value }
}
