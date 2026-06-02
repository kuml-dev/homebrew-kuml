# homebrew-kuml

[Homebrew](https://brew.sh) tap for [**kUML**](https://github.com/kuml-dev/kuml) —
a Kotlin-based UML/C4 modelling and rendering tool.

## Install

```bash
brew tap kuml-dev/kuml
brew install kuml
```

Then verify:

```bash
kuml --help
```

## Update

```bash
brew update
brew upgrade kuml
```

## How this tap is maintained

The formula `Formula/kuml.rb` is updated automatically by the main repo's
release workflow on every `v*.*.*` tag — see
[`.github/workflows/update-formula.yml`](./.github/workflows/update-formula.yml).

If you need to bump it manually:

```bash
brew bump-formula-pr --url=URL --sha256=SHA256 kuml
```

## License

The formula itself is Apache-2.0 (see [LICENSE](./LICENSE)). The kUML
project it installs is also Apache-2.0.
