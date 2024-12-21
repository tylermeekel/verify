import gleam/list
import gleam/result
import gleeunit
import gleeunit/should
import verify

pub fn main() {
  gleeunit.main()
}

pub type Item {
  Item(name: String, count: Int)
}

pub fn custom_item_verify_ok_test() {
  let item = Item("bread", 20)
  let verifier = {
    use <- verify.custom(verify_item)
    verify.finalize()
  }

  verify.run(item, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn custom_item_verify_error_test() {
  let item = Item("", -1)
  let verifier = {
    use <- verify.custom(verify_item)
    verify.finalize()
  }

  verify.run(item, verifier)
  |> should.be_error
  |> should.equal(["must be at least 0", "must not be empty"])
}

fn verify_item(item: Item) -> Result(Nil, List(String)) {
  let name_verifier = {
    use <- verify.string_not_empty
    verify.finalize()
  }

  let count_verifier = {
    use <- verify.int_min_value(0)
    verify.finalize()
  }

  let name_result = verify.run(item.name, name_verifier)
  let count_result = verify.run(item.count, count_verifier)

  let errors = result.partition([name_result, count_result]).1
  case errors {
    [] -> Ok(Nil)
    _ -> Error(list.flatten(errors))
  }
}

pub fn string_min_length_ok_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_min_length(7)
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn string_min_length_error_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_min_length(42)
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_error
  |> should.equal(["must be at least 42 characters long"])
}

pub fn string_max_length_ok_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_max_length(42)
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn string_max_length_error_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_max_length(7)
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_error
  |> should.equal(["must be less than 7 characters long"])
}

pub fn string_exact_length_ok_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_exact_length(12)
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn string_exact_length_error_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_exact_length(42)
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_error
  |> should.equal(["must be exactly 42 characters long"])
}

pub fn string_length_range_ok_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_length_range(0, 42)
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn string_length_range_error_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_length_range(0, 7)
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_error
  |> should.equal([
    "must be at least 0 characters long and at most 7 characters long",
  ])
}

pub fn string_not_empty_ok_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_not_empty
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn string_not_empty_error_test() {
  let str = ""
  let verifier = {
    use <- verify.string_not_empty
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_error
  |> should.equal(["must not be empty"])
}

pub fn string_allowed_characters_ok_test() {
  let str = "hello"
  let verifier = {
    use <- verify.string_allowed_characters(["h", "e", "l", "o"])
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn string_allowed_characters_error_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_allowed_characters(["h", "e", "l", "o"])
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_error
  |> should.equal([
    "must only contain the following characters: \"h\", \"e\", \"l\", \"o\"",
  ])
}

pub fn string_disallowed_characters_ok_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_disallowed_characters(["x", "y", "z"])
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn string_disallowed_characters_error_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_disallowed_characters(["h", "e", "l", "o"])
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_error
  |> should.equal([
    "must not contain the following characters: \"h\", \"e\", \"l\", \"o\"",
  ])
}

pub fn string_starts_with_ok_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_starts_with("hello")
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn string_starts_with_error_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_starts_with("Hellope!")
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_error
  |> should.equal(["must start with: \"Hellope!\""])
}

pub fn string_ends_with_ok_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_ends_with("world")
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn string_ends_with_error_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_ends_with("worm")
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_error
  |> should.equal(["must end with: \"worm\""])
}

pub fn string_contains_ok_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_contains("ello")
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn string_contains_error_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_contains("Hellope!")
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_error
  |> should.equal(["must contain: \"Hellope!\""])
}

pub fn string_does_not_contain_ok_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_does_not_contain("Hellope!")
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn string_does_not_contain_error_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_does_not_contain("hello")
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_error
  |> should.equal(["must not contain: \"hello\""])
}

pub fn string_equals_ok_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_equal_to("hello, world")
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn string_equals_error_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_equal_to("Hellope!")
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_error
  |> should.equal(["must be equal to: \"Hellope!\""])
}

pub fn string_not_equals_ok_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_not_equal_to("Hellope!")
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn string_not_equals_error_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_not_equal_to("hello, world")
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_error
  |> should.equal(["must not be equal to: \"hello, world\""])
}

pub fn int_min_value_ok_test() {
  let num = 42
  let verifier = {
    use <- verify.int_min_value(5)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn int_min_value_error_test() {
  let num = 42
  let verifier = {
    use <- verify.int_min_value(50)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_error
  |> should.equal(["must be at least 50"])
}

pub fn int_max_value_ok_test() {
  let num = 42
  let verifier = {
    use <- verify.int_max_value(50)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn int_max_value_error_test() {
  let num = 42
  let verifier = {
    use <- verify.int_max_value(5)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_error
  |> should.equal(["must be less than 5"])
}

pub fn int_value_range_ok_test() {
  let num = 42
  let verifier = {
    use <- verify.int_value_range(5, 50)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn int_value_range_error_test() {
  let num = 42
  let verifier = {
    use <- verify.int_value_range(0, 40)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_error
  |> should.equal(["must be at least 0 and at most 40"])
}

pub fn int_equal_to_ok_test() {
  let num = 42
  let verifier = {
    use <- verify.int_equal_to(42)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn int_equal_to_error_test() {
  let num = 42
  let verifier = {
    use <- verify.int_equal_to(24)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_error
  |> should.equal(["must be equal to: 24"])
}

pub fn int_not_equal_to_ok_test() {
  let num = 42
  let verifier = {
    use <- verify.int_not_equal_to(24)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn int_not_equal_to_error_test() {
  let num = 42
  let verifier = {
    use <- verify.int_not_equal_to(42)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_error
  |> should.equal(["must not be equal to: 42"])
}

pub fn int_divisible_by_ok_test() {
  let num = 42
  let verifier = {
    use <- verify.int_divisible_by(2)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn int_divisible_by_error_test() {
  let num = 42
  let verifier = {
    use <- verify.int_divisible_by(50)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_error
  |> should.equal(["must be divisible by: 50"])
}

pub fn float_min_value_ok_test() {
  let num = 42.0
  let verifier = {
    use <- verify.float_min_value(4.2)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn float_min_value_error_test() {
  let num = 42.0
  let verifier = {
    use <- verify.float_min_value(42.1)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_error
  |> should.equal(["must be at least 42.1"])
}

pub fn float_max_value_ok_test() {
  let num = 42.0
  let verifier = {
    use <- verify.float_max_value(42.1)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn float_max_value_error_test() {
  let num = 42.0
  let verifier = {
    use <- verify.float_max_value(4.2)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_error
  |> should.equal(["must be at most 4.2"])
}

pub fn float_value_range_ok_test() {
  let num = 42.0
  let verifier = {
    use <- verify.float_value_range(4.2, 50.0)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn float_value_range_error_test() {
  let num = 42.0
  let verifier = {
    use <- verify.float_value_range(42.1, 50.0)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_error
  |> should.equal(["must be at least 42.1 and at most 50.0"])
}

pub fn float_equal_to_ok_test() {
  let num = 42.0
  let verifier = {
    use <- verify.float_equal_to(42.0)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn float_equal_to_error_test() {
  let num = 42.0
  let verifier = {
    use <- verify.float_equal_to(42.1)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_error
  |> should.equal(["must be equal to: 42.1"])
}

pub fn float_not_equal_to_ok_test() {
  let num = 42.0
  let verifier = {
    use <- verify.float_not_equal_to(12.0)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn float_not_equal_to_error_test() {
  let num = 42.0
  let verifier = {
    use <- verify.float_not_equal_to(42.0)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_error
  |> should.equal(["must not be equal to: 42.0"])
}

pub fn float_divisible_by_ok_test() {
  let num = 42.0
  let verifier = {
    use <- verify.float_divisible_by(2.0)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_ok
  |> should.equal(Nil)
}

pub fn float_divisible_by_error_test() {
  let num = 42.0
  let verifier = {
    use <- verify.float_divisible_by(43.0)
    verify.finalize()
  }

  verify.run(num, verifier)
  |> should.be_error
  |> should.equal(["must be divisible by: 43.0"])
}
