class Kuml < Formula
  desc "Kotlin-based UML/C4 modelling and rendering tool"
  homepage "https://github.com/kuml-dev/kuml"
  version "0.22.0"
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
      url "https://github.com/kuml-dev/kUML/releases/download/v0.22.0/kuml-runtime-0.22.0-darwin-x86_64.zip"
      sha256 "dc5d7b400bb201d3b7cb6df842cf80e4e5a176a3d9c2b013e4ed6b0199f1804b"
    end
    on_arm do
      url "https://github.com/kuml-dev/kUML/releases/download/v0.22.0/kuml-runtime-0.22.0-darwin-arm64.zip"
      sha256 "16599644ddf14d64aa0639b46114006973c97d2a4a5cf0d054dc826ce12e35b2"
    end
  end

  on_linux do
    url "https://github.com/kuml-dev/kUML/releases/download/v0.22.0/kuml-runtime-0.22.0-linux-x86_64.zip"
    sha256 "8284b5758e4144e6975861134263605cf0fee676a5c134ada4a039916a997fa9"
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
