class Kuml < Formula
  desc "Kotlin-based UML/C4 modelling and rendering tool"
  homepage "https://github.com/kuml-dev/kuml"

  # url, sha256 and version are rewritten automatically by update-formula.yml
  # in this tap, triggered by a repository_dispatch event from kuml-dev/kuml's
  # release workflow on every `v*.*.*` tag.
  url "https://github.com/kuml-dev/kUML/releases/download/v0.1.1/kuml-runtime-0.1.1.zip"
  sha256 "772f9dc165836e0acd7357ecdbe9ce4e998be298ac214c3fa0fbcd31c2a0eab9"
  version "0.1.1"
  license "Apache-2.0"

  # The kuml-runtime-<version>.zip is a self-contained bundle: app jars +
  # a jlink-built Java 21 runtime. No external JDK dependency.

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
