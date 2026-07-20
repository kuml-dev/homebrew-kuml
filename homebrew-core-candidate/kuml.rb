class Kuml < Formula
  desc "Kotlin-native UML/SysML/C4 DSL — render, transform, generate diagrams"
  homepage "https://kuml.dev"
  url "https://github.com/kuml-dev/kUML/releases/download/v0.37.0/kuml-0.37.0.zip"
  sha256 "dee298c29a123778286b177267b4b102aff534b472469b5c75d16ac39a644ab2"
  license "Apache-2.0"

  depends_on "openjdk@21"

  def install
    # .bat launchers are meaningless on macOS/Linux, where Homebrew runs.
    rm(Dir["bin/*.bat"])
    libexec.install Dir["*"]
    # Wraps the existing Gradle-generated launcher (bin/kuml, looks for
    # JAVA_HOME or `java` on PATH) with an explicit JAVA_HOME pointing at
    # the openjdk@21 keg, while still honouring HOMEBREW_JAVA_HOME if the
    # user overrides it — the same idiom homebrew-core's own `gradle`
    # formula uses for its Gradle-application-plugin bin/lib layout.
    env = Language::Java.overridable_java_home_env("21")
    (bin/"kuml").write_env_script libexec/"bin/kuml", env
  end

  test do
    assert_match "Compiles kUML scripts", shell_output("#{bin}/kuml --help")
  end
end
