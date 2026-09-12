cask "kuml-desktop" do
  version "0.54.1"
  sha256 "62a2657780ea964808970e3a96e1d8ecb5b65013fe38c11b815265bcf3b0d2db"

  # The kuml-desktop-<version>.dmg is built by the `desktop-dmg` job in
  # kuml-dev/kuml's release.yml (V3.2.14) via the Compose Multiplatform
  # `packageDmg` task, then signed (Developer ID, hardened runtime) and
  # notarized (V3.2.25/27) before upload — verified in the v0.24.0 release run
  # (notarization status: Accepted). The `version`/`url`/`sha256` fields below
  # are rewritten automatically by update-cask.yml in this tap, triggered by a
  # repository_dispatch event (type "kuml-desktop-release") from
  # kuml-dev/kuml's release workflow on every `v*.*.*` tag.
  url "https://github.com/kuml-dev/kUML/releases/download/v#{version}/kuml-desktop-#{version}.dmg"
  name "kUML Desktop"
  desc "Kotlin-based UML/SysML2/C4/BPMN modelling desktop app (Compose Multiplatform)"
  homepage "https://github.com/kuml-dev/kUML"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates false
  depends_on macos: :big_sur

  app "kuml-desktop.app"

  zap trash: [
    "~/Library/Application Support/kuml-desktop",
    "~/Library/Preferences/dev.kuml.desktop.plist",
    "~/Library/Saved Application State/dev.kuml.desktop.savedState",
  ]
end
