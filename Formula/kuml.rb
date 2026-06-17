class Kuml < Formula
  desc "Kotlin-based UML/C4 modelling and rendering tool"
  homepage "https://github.com/kuml-dev/kuml"
  version "0.13.0"
  license "Apache-2.0"

  # The kuml-runtime-<version>-<os>-<arch>.zip is a self-contained bundle:
  # app jars + a jlink-built Java 21 runtime. No external JDK dependency.
  #
  # jlink produces a JRE for the host platform it's invoked on, so we must
  # ship one zip per target. Older releases (≤ 0.1.1) shipped a single
  # zip built on a Linux runner — that zip is broken on macOS. The 0.1.1
  # placeholders below are kept only to document the layout; they MUST
  # be overwritten by a re-release of 0.1.1 (or the next tag) that runs
  # the matrixed release.yml in kuml-dev/kuml.
  #
  # url/sha256 blocks are rewritten automatically by update-formula.yml
  # in this tap, triggered by a repository_dispatch event from
  # kuml-dev/kuml's release workflow on every `v*.*.*` tag.

  on_macos do
    on_intel do
      url "https://github.com/kuml-dev/kUML/releases/download/v0.13.0/kuml-runtime-0.13.0-darwin-x86_64.zip"
      sha256 "d769f4b6edacc62385544373dd3e2fc7faddc7d7aa8628612ce70d026e042c06"
    end
    on_arm do
      url "https://github.com/kuml-dev/kUML/releases/download/v0.13.0/kuml-runtime-0.13.0-darwin-arm64.zip"
      sha256 "428855f0d29856f610ddd69b41570a27a7189b2116fa7cb0e9c68beebb7f3712"
    end
  end

  on_linux do
    url "https://github.com/kuml-dev/kUML/releases/download/v0.13.0/kuml-runtime-0.13.0-linux-x86_64.zip"
    sha256 "94df0c14b3637c8d39732a26244be027d668474843e1e74d5e7c2b7232d650b9"
  end

  def install
    # The zip extracts as kuml-<version>/{bin,lib,runtime}/, but Homebrew's
    # extract step already CDs into that single top-level directory before
    # running this method — so the bin/lib/runtime tree is right here in `.`.
    libexec.install Dir["*"]
    # Defensive chmod: pre-v0.2.0 release artefacts shipped without exec
    # bits inside the zip. Newer builds set 0755 on bin/kuml and the
    # runtime/bin/* binaries already, so this is a no-op for them.
    chmod 0755, libexec/"bin/kuml"
    Dir[libexec/"runtime/bin/*"].each { |f| chmod 0755, f }
    chmod 0755, libexec/"runtime/lib/jspawnhelper" if File.exist?(libexec/"runtime/lib/jspawnhelper")
    bin.install_symlink libexec/"bin/kuml"
  end

  test do
    assert_match "Compiles kUML scripts", shell_output("#{bin}/kuml --help")
  end
end
