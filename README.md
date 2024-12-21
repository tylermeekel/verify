# verify
Ergonomic data validation library inspired by decode!

[![Package Version](https://img.shields.io/hexpm/v/verify)](https://hex.pm/packages/verify)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/verify/)

```sh
gleam add verify
```
## Examples
### Simple Usage
```gleam
import verify

pub fn main() {
  let data = "hello, world"
  let verifier = {
    use <- verify.string_min_length(5)
    use <- verify.string_max_length(32)
    verify.finalize()
  }

  verify.run(data, verifier)
}
```
### Writing Your Own Custom Verifier
```gleam
import verify
import gleam/result
import gleam/list

pub type Item {
  Item(name: String, count: Int)
}

pub fn main() {
  let item = Item("bread", 20)
  let verifier = {
    use <- verify.custom(verify_item)
    verify.finalize()
  }

  verify.run(item, verifier)
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
```

Further documentation can be found at <https://hexdocs.pm/verify>.
