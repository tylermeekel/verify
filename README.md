# verify
Ergonomic data validation library inspired by decode!

[![Package Version](https://img.shields.io/hexpm/v/verify)](https://hex.pm/packages/verify)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/verify/)

```sh
gleam add verify
```
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

Further documentation can be found at <https://hexdocs.pm/verify>.
