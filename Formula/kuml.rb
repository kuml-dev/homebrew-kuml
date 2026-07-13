class Kuml < Formula
  desc "Kotlin-based UML/C4 modelling and rendering tool"
  homepage "https://github.com/kuml-dev/kuml"
  version "0.33.0"
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
      url "https://github.com/kuml-dev/kUML/releases/download/v0.33.0/kuml-runtime-0.33.0-darwin-x86_64.zip"
      sha256 "c0d606b4017ac0b5639a40750b77be8fcc739eb00431837636c033f47580c347"
    end
    on_arm do
      url "https://github.com/kuml-dev/kUML/releases/download/v0.33.0/kuml-runtime-0.33.0-darwin-arm64.zip"
      sha256 "28e40d5e420af45009e42cffa1e45249c11174a0290829f6515fc82dcb49f567"
    end
  end

  on_linux do
    url "https://github.com/kuml-dev/kUML/releases/download/v0.33.0/kuml-runtime-0.33.0-linux-x86_64.zip"
    sha256 "b61e9ba68ff9409031aac3428dc8ad6c1eecc1c19c997822efcdcfc83c4b4732"
  end

  # Without this, Homebrew's local install step (Keg#fix_dynamic_linkage) rewrites
  # every @rpath-based dylib ID to an absolute Cellar/opt path, which invalidates
  # our Developer-ID signature on runtime/lib/libjli.dylib. Homebrew then re-signs
  # it ad hoc since it has no access to the real cert, and dyld's library
  # validation subsequently refuses to load it into the (still correctly, real-
  # signed) java binary — "different Team IDs" crash on launch. preserve_rpath
  # tells Homebrew to leave @rpath dylib IDs alone, so our real signature survives
  # brew install/upgrade untouched. macOS-only concept; harmless no-op on Linux.
  preserve_rpath

  def install
    # The zip extracts as kuml-<version>/{bin,lib,runtime}/, but Homebrew's
    # extract step already CDs into that single top-level directory before
    # running this method — so the bin/lib/runtime tree is right here in `.`.
    #
    # V3.2.13: the zip now also ships an mcp/ subtree (a self-contained
    # kuml-mcp installDist, kept separate from bin/lib to avoid duplicate-jar
    # collisions with the CLI's own kuml-core-* jars) plus a thin bin/kuml-mcp
    # wrapper that execs into mcp/bin/kuml-mcp.
    libexec.install Dir["*"]
    # Defensive chmod: pre-v0.2.0 release artefacts shipped without exec
    # bits inside the zip. Newer builds set 0755 on bin/kuml, bin/kuml-mcp,
    # mcp/bin/kuml-mcp and the runtime/bin/* binaries already, so this is a
    # no-op for them.
    chmod 0755, libexec/"bin/kuml"
    chmod 0755, libexec/"bin/kuml-mcp" if File.exist?(libexec/"bin/kuml-mcp")
    chmod 0755, libexec/"mcp/bin/kuml-mcp" if File.exist?(libexec/"mcp/bin/kuml-mcp")
    Dir[libexec/"runtime/bin/*"].each { |f| chmod 0755, f }
    chmod 0755, libexec/"runtime/lib/jspawnhelper" if File.exist?(libexec/"runtime/lib/jspawnhelper")
    bin.install_symlink libexec/"bin/kuml"
    bin.install_symlink libexec/"bin/kuml-mcp" if File.exist?(libexec/"bin/kuml-mcp")
  end

  test do
    assert_match "Compiles kUML scripts", shell_output("#{bin}/kuml --help")
    # kuml-mcp has no --version/--help flag (it speaks MCP JSON-RPC over
    # stdio only), so the smoke test sends a minimal initialize request and
    # checks the server answers with its own serverInfo — this exercises the
    # bundled-JRE launcher path (mcp/bin/kuml-mcp) end to end.
    request = <<~JSON.delete("\n")
      {"jsonrpc":"2.0","id":1,"method":"initialize",
       "params":{"protocolVersion":"2024-11-05","capabilities":{},
       "clientInfo":{"name":"brew-test","version":"0"}}}
    JSON
    output = pipe_output("#{bin}/kuml-mcp", "#{request}\n", 0)
    assert_match "\"name\":\"kuml-mcp\"", output
  end
end
