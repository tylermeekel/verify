import gleeunit
import gleeunit/should
import verify

pub fn main() {
  gleeunit.main()
}

pub fn string_min_length_ok_test() {
  let str = "hello, world"
  let verifier = {
    use <- verify.string_min_length(7)
    verify.finalize()
  }

  verify.run(str, verifier)
  |> should.be_ok
  |> should.equal(str)
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
  |> should.equal(str)
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
  |> should.equal(str)
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
  |> should.equal(str)
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
  |> should.equal(str)
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
  |> should.equal(str)
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
  |> should.equal(str)
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
  |> should.equal(str)
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
  |> should.equal(str)
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
  |> should.equal(str)
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
  |> should.equal(str)
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
  |> should.equal(str)
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
  |> should.equal(str)
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
