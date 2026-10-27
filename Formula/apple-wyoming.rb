class AppleWyoming < Formula
  desc "Local Wyoming speech-to-text server using Apple's on-device dictation"
  homepage "https://github.com/JulienDeveaux/apple-wyoming"
  url "https://github.com/JulienDeveaux/apple-wyoming/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "5ea0e426a12a99e65a8b5cedb987618f373de47daff482545cc63d488bd7281f"

  livecheck do
    url :stable
    strategy :github_latest
  end

  # SpeechAnalyzer / DictationTranscriber ship with macOS 26; the package needs the Swift 6.2 toolchain.
  depends_on xcode: ["26.0", :build]
  depends_on macos: :tahoe

  def install
    system "swift", "build", "--disable-sandbox", "--configuration", "release"
    bin.install ".build/release/apple-wyoming"
  end

  # A LaunchAgent (brew services as the logged-in user): the Speech framework needs a GUI session.
  service do
    run [opt_bin/"apple-wyoming", "--host", "0.0.0.0", "--port", "10300"]
    keep_alive true
    # A background agent is throttled by the system, which would add latency to every utterance.
    process_type :interactive
    log_path var/"log/apple-wyoming.log"
    error_log_path var/"log/apple-wyoming.log"
  end

  test do
    assert_match "usage: apple-wyoming", shell_output("#{bin}/apple-wyoming --help")
  end
end
