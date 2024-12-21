//// Based on the [decode](https://hexdocs.pm/decode/) library, `verify`
//// provides an easy, composable way to validate data.
////
//// # Examples
//// ```gleam
//// let str = "hello, world"
//// let verifier = {
////    use <- verify.string_min_length(2)
////    use <- verify.string_max_length(32)
////    verify.finalize()
//// }
////
//// let result = verify.run(str, verifier)
//// assert result == Ok(str)
//// ```

import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string

/// A verifier is a value that can be used to test a set of rules
/// against a piece of data passed into it.
///
/// Verifiers are easily combined to allow large rule sets to be
/// used for more complex data requirements.
pub opaque type Verifier(t) {
  Verifier(function: fn(t) -> List(String))
}

/// Run a verifier against a piece of data, returning a result containing
/// either the data that was passed in, or a list of error messages from
/// failed validations.
pub fn run(data: t, verifier: Verifier(t)) -> Result(Nil, List(String)) {
  let errors = verifier.function(data)
  case errors {
    [] -> Ok(Nil)
    _ -> Error(errors)
  }
}

/// Finalize a verifier.
pub fn finalize() {
  Verifier(fn(_) { [] })
}

/// Creates a custom verifier. Pass in a function that returns Ok(Nil) on success,
/// or a list of error messages on failure.
pub fn custom(
  function: fn(t) -> Result(Nil, List(String)),
  next: fn() -> Verifier(t),
) {
  Verifier(fn(data) {
    case function(data) {
      Ok(_) -> {
        next().function(data)
      }
      Error(error_messages) -> {
        let errors = next().function(data)
        list.flatten([error_messages, errors])
      }
    }
  })
}

// --------------- STRINGS ---------------

/// Verifies that strings length is at least the given length.
pub fn string_min_length(length: Int, next: fn() -> Verifier(String)) {
  Verifier(function: fn(data) {
    let is_string_min_length = string.length(data) >= length
    case is_string_min_length {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let min_length_str = int.to_string(length)
        ["must be at least " <> min_length_str <> " characters long", ..errors]
      }
    }
  })
}

/// Verifies that a strings length is at most the given length. The max length value is inclusive.
pub fn string_max_length(length: Int, next: fn() -> Verifier(String)) {
  Verifier(fn(data) {
    let is_string_max_length = string.length(data) <= length
    case is_string_max_length {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let max_length_str = int.to_string(length)
        ["must be less than " <> max_length_str <> " characters long", ..errors]
      }
    }
  })
}

/// Verifies that a strings length is exactly the given length.
pub fn string_exact_length(length: Int, next: fn() -> Verifier(String)) {
  Verifier(fn(data) {
    let is_string_exact_length = string.length(data) == length
    case is_string_exact_length {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let exact_length_str = int.to_string(length)
        ["must be exactly " <> exact_length_str <> " characters long", ..errors]
      }
    }
  })
}

/// Verifies that a strings length falls within a given inclusive range.
pub fn string_length_range(
  min_length: Int,
  max_length: Int,
  next: fn() -> Verifier(String),
) {
  Verifier(fn(data) {
    let is_string_within_range =
      string.length(data) <= max_length && string.length(data) >= min_length
    case is_string_within_range {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let min_length_str = int.to_string(min_length)
        let max_length_str = int.to_string(max_length)
        [
          "must be at least "
            <> min_length_str
            <> " characters long and at most "
            <> max_length_str
            <> " characters long",
          ..errors
        ]
      }
    }
  })
}

/// Verifies that a string is not empty.
pub fn string_not_empty(next: fn() -> Verifier(String)) {
  Verifier(fn(data) {
    let is_string_not_empty = !string.is_empty(data)
    case is_string_not_empty {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        ["must not be empty", ..errors]
      }
    }
  })
}

/// Verifies that a string contains only a set of allowed characters.
pub fn string_allowed_characters(
  characters: List(String),
  next: fn() -> Verifier(String),
) {
  Verifier(fn(data) {
    let split_string = string.split(data, "")
    let does_string_have_only_allowed =
      list.all(split_string, fn(character) {
        list.contains(characters, character)
      })

    case does_string_have_only_allowed {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        [allowed_characters_error_message(characters), ..errors]
      }
    }
  })
}

fn allowed_characters_error_message(characters: List(String)) -> String {
  let char_list_str =
    list.map(characters, fn(char) { "\"" <> char <> "\"" })
    |> string.join(", ")
  "must only contain the following characters: " <> char_list_str
}

/// Verifies that a string does not contain a set of disallowed characters
pub fn string_disallowed_characters(
  characters: List(String),
  next: fn() -> Verifier(String),
) {
  Verifier(fn(data) {
    let does_string_not_have_disallowed =
      !list.any(characters, fn(char) { string.contains(data, char) })

    case does_string_not_have_disallowed {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        [disallowed_characters_error_message(characters), ..errors]
      }
    }
  })
}

fn disallowed_characters_error_message(characters: List(String)) -> String {
  let char_list_str =
    list.map(characters, fn(char) { "\"" <> char <> "\"" })
    |> string.join(", ")
  "must not contain the following characters: " <> char_list_str
}

/// Verifies that a string starts with a given string.
pub fn string_starts_with(start: String, next: fn() -> Verifier(String)) {
  Verifier(fn(data) {
    let does_string_start_with = string.starts_with(data, start)
    case does_string_start_with {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        ["must start with: \"" <> start <> "\"", ..errors]
      }
    }
  })
}

/// Verifies that a string ends with a given string.
pub fn string_ends_with(end: String, next: fn() -> Verifier(String)) {
  Verifier(fn(data) {
    let does_string_end_with = string.ends_with(data, end)
    case does_string_end_with {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        ["must end with: \"" <> end <> "\"", ..errors]
      }
    }
  })
}

/// Verifies that a string contains a given substring.
pub fn string_contains(substring: String, next: fn() -> Verifier(String)) {
  Verifier(fn(data) {
    let does_string_contain = string.contains(data, substring)
    case does_string_contain {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        ["must contain: \"" <> substring <> "\"", ..errors]
      }
    }
  })
}

/// Verifies that a string does not contain a given substring.
pub fn string_does_not_contain(
  substring: String,
  next: fn() -> Verifier(String),
) {
  Verifier(fn(data) {
    let does_string_not_contain = !string.contains(data, substring)
    case does_string_not_contain {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        ["must not contain: \"" <> substring <> "\"", ..errors]
      }
    }
  })
}

/// Verifies that a string is equal to a given string.
pub fn string_equal_to(compare_to: String, next: fn() -> Verifier(String)) {
  Verifier(fn(data) {
    let is_string_equal_to = data == compare_to
    case is_string_equal_to {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        ["must be equal to: \"" <> compare_to <> "\"", ..errors]
      }
    }
  })
}

/// Verifies that a string is not equal to a given string.
pub fn string_not_equal_to(compare_to: String, next: fn() -> Verifier(String)) {
  Verifier(fn(data) {
    let is_string_not_equal_to = data != compare_to
    case is_string_not_equal_to {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        ["must not be equal to: \"" <> compare_to <> "\"", ..errors]
      }
    }
  })
}

// --------------- INTEGERS ---------------

/// Verifies that an integer is at least a given value.
pub fn int_min_value(value: Int, next: fn() -> Verifier(Int)) {
  Verifier(fn(data) {
    let is_int_min_value = data >= value
    case is_int_min_value {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let min_value_string = int.to_string(value)
        ["must be at least " <> min_value_string, ..errors]
      }
    }
  })
}

/// Verifies that an integer is at most a given value.
pub fn int_max_value(value: Int, next: fn() -> Verifier(Int)) {
  Verifier(fn(data) {
    let is_int_max_value = data <= value
    case is_int_max_value {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let max_value_string = int.to_string(value)
        ["must be less than " <> max_value_string, ..errors]
      }
    }
  })
}

/// Verifies that an integer has a value that falls within a given inclusive range of values.
pub fn int_value_range(
  min_value: Int,
  max_value: Int,
  next: fn() -> Verifier(Int),
) {
  Verifier(fn(data) {
    let is_int_within_range = data >= min_value && data <= max_value
    case is_int_within_range {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let min_value_string = int.to_string(min_value)
        let max_value_string = int.to_string(max_value)
        [
          "must be at least "
            <> min_value_string
            <> " and at most "
            <> max_value_string,
          ..errors
        ]
      }
    }
  })
}

/// Verifies that an int is equal to a given value.
pub fn int_equal_to(compare_to: Int, next: fn() -> Verifier(Int)) {
  Verifier(fn(data) {
    let is_int_equal_to = data == compare_to
    case is_int_equal_to {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let compare_to_string = int.to_string(compare_to)
        ["must be equal to: " <> compare_to_string, ..errors]
      }
    }
  })
}

/// Verifies that an int is not equal to a given range of values.
pub fn int_not_equal_to(compare_to: Int, next: fn() -> Verifier(Int)) {
  Verifier(fn(data) {
    let is_int_not_equal_to = data != compare_to
    case is_int_not_equal_to {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let compare_to_string = int.to_string(compare_to)
        ["must not be equal to: " <> compare_to_string, ..errors]
      }
    }
  })
}

/// Verifies that an int is divisible by a given divisor.
pub fn int_divisible_by(divisor: Int, next: fn() -> Verifier(Int)) {
  Verifier(fn(data) {
    let is_int_divisible_by = data % divisor == 0
    case is_int_divisible_by {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let divisor_string = int.to_string(divisor)
        ["must be divisible by: " <> divisor_string, ..errors]
      }
    }
  })
}

// --------------- FLOATS ---------------
/// Verifies that a float is at least a given value.
pub fn float_min_value(value: Float, next: fn() -> Verifier(Float)) {
  Verifier(fn(data) {
    let is_float_min_value = data >=. value
    case is_float_min_value {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let min_value_string = float.to_string(value)
        ["must be at least " <> min_value_string, ..errors]
      }
    }
  })
}

/// Verifies that a float is at most a given value.
pub fn float_max_value(value: Float, next: fn() -> Verifier(Float)) {
  Verifier(fn(data) {
    let is_float_max_value = data <=. value
    case is_float_max_value {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let max_value_string = float.to_string(value)
        ["must be at most " <> max_value_string, ..errors]
      }
    }
  })
}

/// Verifies that a float has a value that falls within a given inclusive range of values.
pub fn float_value_range(
  min_value: Float,
  max_value: Float,
  next: fn() -> Verifier(Float),
) {
  Verifier(fn(data) {
    let is_data_within_range = data >=. min_value && data <=. max_value
    case is_data_within_range {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let min_value_string = float.to_string(min_value)
        let max_value_string = float.to_string(max_value)
        [
          "must be at least "
            <> min_value_string
            <> " and at most "
            <> max_value_string,
          ..errors
        ]
      }
    }
  })
}

/// Verifies that a float is equal to a given value.
pub fn float_equal_to(compare_to: Float, next: fn() -> Verifier(Float)) {
  Verifier(fn(data) {
    let is_float_equal_to = data == compare_to
    case is_float_equal_to {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let compare_to_string = float.to_string(compare_to)
        ["must be equal to: " <> compare_to_string, ..errors]
      }
    }
  })
}

/// Verifies that a float is not equal to a given value.
pub fn float_not_equal_to(compare_to: Float, next: fn() -> Verifier(Float)) {
  Verifier(fn(data) {
    let is_float_not_equal_to = data != compare_to
    case is_float_not_equal_to {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let compare_to_string = float.to_string(compare_to)
        ["must not be equal to: " <> compare_to_string, ..errors]
      }
    }
  })
}

/// Verifies that a float is divisible by a given divisor. May not always work
/// as expected, due to floating point inaccuracies, use at your own discretion.
pub fn float_divisible_by(divisor: Float, next: fn() -> Verifier(Float)) {
  Verifier(fn(data) {
    let remainder = result.unwrap(float.modulo(data, divisor), -1.0)
    let is_float_divisible_by = remainder == 0.0
    case is_float_divisible_by {
      True -> {
        next().function(data)
      }
      False -> {
        let errors = next().function(data)
        let divisor_string = float.to_string(divisor)
        ["must be divisible by: " <> divisor_string, ..errors]
      }
    }
  })
}
