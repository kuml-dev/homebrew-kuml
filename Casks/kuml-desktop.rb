cask "kuml-desktop" do
  version "0.24.0"
  sha256 "d369aa1f3455eed84cd41b590cbad875a0da7886c674f7e697cd6752e855dea9"

  # The kuml-desktop-<version>.dmg is built by the `desktop-dmg` job in
  # kuml-dev/kuml's release.yml (V3.2.14) via the Compose Multiplatform
  # `packageDmg` task (unsigned — Phase 2 adds Apple Developer signing /
  # notarisation). The `version`/`url`/`sha256` fields below are rewritten
  # automatically by update-cask.yml in this tap, triggered by a
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

  caveats do
    <<~EOS
      kuml-desktop is unsigned (no Apple Developer notarisation yet — Phase 2).
      On first launch, macOS Gatekeeper will block it. Allow it once via:
        System Settings → Privacy & Security → Open Anyway
      or clear the quarantine attribute manually:
        xattr -dr com.apple.quarantine "#{appdir}/kuml-desktop.app"
    EOS
  end
end
