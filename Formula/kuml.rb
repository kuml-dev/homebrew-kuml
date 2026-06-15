class Kuml < Formula
  desc "Kotlin-based UML/C4 modelling and rendering tool"
  homepage "https://github.com/kuml-dev/kuml"
  version "0.11.0"
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
      url "https://github.com/kuml-dev/kUML/releases/download/v0.11.0/kuml-runtime-0.11.0-darwin-x86_64.zip"
      sha256 "702f4a71b0f2d0aa5c3ed71cac43a28388c3a4ed628f43ed6443ac82952fb0fd"
    end
    on_arm do
      url "https://github.com/kuml-dev/kUML/releases/download/v0.11.0/kuml-runtime-0.11.0-darwin-arm64.zip"
      sha256 "56eb68937307bcc78dc48aeb4edf07fd1286085a74dfbc1987c3c810e96e78b8"
    end
  end

  on_linux do
    url "https://github.com/kuml-dev/kUML/releases/download/v0.11.0/kuml-runtime-0.11.0-linux-x86_64.zip"
    sha256 "02e1a078cad8f606d8e7735ceb245904ed9d0306da34915b6bc8c042e49bc0f7"
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
