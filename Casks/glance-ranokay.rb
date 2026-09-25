cask "glance-ranokay" do
  version "1.6.1"
  sha256 "475b4a7c0efe91487d6749e4928b778371ebee6674446fd30dfb5fa8eb33b533"

  url "https://github.com/ranokay/glance/releases/download/v#{version}/Glance-#{version}.dmg"
  name "Glance"
  desc "All-in-one Quick Look plugin (ranokay fork)"
  homepage "https://github.com/ranokay/glance"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Releases are ad-hoc signed and not notarized, so there is no Developer ID to
  # verify. The pinned sha256 above is the integrity check.
  auto_updates false
  conflicts_with cask: "glance-chamburr"
  depends_on arch: :arm64
  depends_on macos: :tahoe

  app "Glance.app"

  postflight_steps do
    # Ad-hoc signed build: strip the download quarantine so Gatekeeper does not
    # block the Quick Look extension on install and on every upgrade.
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Glance.app"],
        must_succeed: false
    # Register the extension so previews work without launching the app first.
    run "/usr/bin/pluginkit",
        args:         ["-a", "{{appdir}}/Glance.app/Contents/PlugIns/QLPlugin.appex"],
        must_succeed: false
    run "/usr/bin/qlmanage", args: ["-r"], must_succeed: false
    run "/usr/bin/qlmanage", args: ["-r", "cache"], must_succeed: false
  end

  uninstall quit: "com.chamburr.Glance"

  zap trash: [
    "~/Library/Application Scripts/com.chamburr.Glance",
    "~/Library/Application Scripts/com.chamburr.Glance.QLPlugin",
    "~/Library/Containers/com.chamburr.Glance",
    "~/Library/Containers/com.chamburr.Glance.QLPlugin",
    "~/Library/Preferences/com.chamburr.Glance.plist",
  ]
end
