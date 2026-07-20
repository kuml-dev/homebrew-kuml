# homebrew-core submission candidate

This directory is **not** part of the `kuml-dev/kuml` tap — it's a staging area for the
formula intended to eventually be submitted as a pull request to
[`Homebrew/homebrew-core`](https://github.com/Homebrew/homebrew-core), so `kuml` becomes
installable with a plain `brew install kuml`, no `brew tap` required.

## Why this can't just be the existing tap formula

`Formula/kuml.rb` in this tap downloads `kuml-runtime-<version>-<os>-<arch>.zip` — a
self-contained bundle with a jlink-trimmed JRE baked in, so users don't need a system
JDK. homebrew-core requires formulae to either build from source or ship "portable,
platform-independent output such as Java bytecode" — a platform/arch-specific bundled
runtime satisfies neither. Building kUML from source inside Homebrew's network-sandboxed
build environment isn't realistic either: Gradle needs to resolve its full dependency
graph (Kotlin compiler-embeddable, Batik, ELK, LSP4J, AI provider SDKs, ...) from Maven
Central, and there's no clean way to pre-vendor that as `resource` blocks the way e.g.
Python formulae do.

## The actual approach: `kuml-<version>.zip`

kUML's release pipeline already builds and publishes a second, plain artifact on every
tag: `kuml-<version>.zip` (`:kuml-cli:distZip` in `kuml-cli/build.gradle.kts`) — the
unmodified Gradle `application` plugin output (`bin/kuml` + `lib/*.jar`, ~330 jars, no
bundled JRE). Its launcher does the standard `JAVA_HOME` → `PATH` java lookup, exactly
what a `depends_on "openjdk@21"` formula needs. This is the artifact `kuml.rb` here
points at.

The formula mirrors homebrew-core's own `gradle` formula (same Gradle-application-plugin
bin/lib layout, same problem): `libexec.install` the whole tree, then
`Language::Java.overridable_java_home_env("21")` + `write_env_script` to wrap the
existing launcher with an explicit `JAVA_HOME` pointing at the `openjdk@21` keg
(user-overridable via `HOMEBREW_JAVA_HOME`/`JAVA_HOME`).

## Validated locally (2026-07-20, against v0.38.0)

- `ruby -c kuml.rb` — syntax OK
- Installed via a temporarily-renamed copy in the tap (`kuml-core-candidate`, to avoid
  colliding with the real `kuml` formula during testing)
- `HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source` — succeeds (per
  homebrew-core's own PR template, not just the API-cached `brew install`)
- `brew audit --strict --new` — clean, no findings
- `brew style` — clean, no offenses
- `brew test` — passes (`kuml --help` runs successfully via the `openjdk@21`-wrapped
  launcher)
- Manually confirmed the generated wrapper resolves `JAVA_HOME` to
  `$(brew --prefix openjdk@21)/libexec/openjdk.jdk/Contents/Home`, not a stray default
  `openjdk` — the version argument to `overridable_java_home_env` matters for this,
  Homebrew's own docs call out reproducibility as the reason to pass it explicitly

## Known concern, flagged proactively in the PR description

The zip is ~150 MB / ~330 jars — kUML's CLI dependency tree includes things a pure
diagram-rendering use case doesn't need (Compose Multiplatform pieces, AI provider SDKs,
several blockchain chain adapters). Not a documented hard blocker in
`docs.brew.sh/Acceptable-Formulae`, but unusually large for a CLI formula and a
plausible point of reviewer pushback.

## Status: PR closed — notability threshold, not a code issue

**[Homebrew/homebrew-core#294156](https://github.com/Homebrew/homebrew-core/pull/294156)**
— "kuml 0.38.0 (new formula)", opened and closed same day, 2026-07-20. A maintainer
closed it citing `docs.brew.sh/Package-Acceptance-Policy`'s notability thresholds — a
GitHub project needs 30 forks, 30 watchers, or 75 stars (third-party submission) / 90
forks, 90 watchers, or 225 stars (self-submission by the project's own author). kUML had
14 stars, 0 forks, 0 watchers at the time — under every threshold, third-party or
self-submission.

The formula itself was never criticized: audit/style/test/build-from-source all passed.
This is purely a project-popularity gate, unrelated to the `distZip` + `openjdk@21` +
`write_env_script` approach documented above, which remains the correct path *if/when*
kUML clears the notability bar.

**Until then, `kuml-dev/homebrew-kuml` (this tap) is the only Homebrew channel.** Revisit
this candidate once kUML's GitHub stats clear the third-party threshold (75+ stars, 30+
forks, or 30+ watchers) — re-validate against whatever version is current at that point
(url/sha256 change every release) before resubmitting.

See [[03 Bereiche/kUML/Distribution und Packaging#Weg zu offiziellem Homebrew Core (Homebrew/homebrew-core)]]
and the 2026-07-20 daily note for full context, including the correction to an earlier
(incomplete) research pass that missed the Package-Acceptance-Policy page.
