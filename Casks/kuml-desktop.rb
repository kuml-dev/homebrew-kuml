cask "kuml-desktop" do
  version "0.23.2"
  sha256 "351a3ff7a09bebba718760db8bdf4afbae347974aebe1372ebed6586093e1e41"

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
