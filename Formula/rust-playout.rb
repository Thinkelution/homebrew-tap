class RustPlayout < Formula
  desc "API-controlled live playout with an embedded web control room"
  homepage "https://github.com/Thinkelution/rust-playout"
  url "https://github.com/Thinkelution/rust-playout/releases/download/v0.0.1-alpha/rust-playout-0.0.1-alpha-macos-arm64.tar.gz"
  version "0.0.1-alpha"
  sha256 "51d1b2b1b47547b9ed4ce60dbc3dc26dfa175a443b5832b66d5c567e69f971de"
  license "GPL-3.0-or-later"

  depends_on arch: :arm64
  depends_on :macos
  depends_on macos: :tahoe
  depends_on "ffmpeg"

  def install
    odie "This binary requires Homebrew at /opt/homebrew." unless HOMEBREW_PREFIX.to_s == "/opt/homebrew"
    odie "This alpha requires FFmpeg 9; a new binary is needed for other major versions." unless Formula["ffmpeg"].version.major == 9

    bin.install "rust-playout"
    doc.install "INSTALL.md", "THIRD-PARTY.md", "DEPENDENCY-LICENSES.txt", "Cargo.lock"
    prefix.install "LICENSE"
  end

  def caveats
    <<~EOS
      Start the control room:
        rust-playout --demo
      Then open http://127.0.0.1:8787

      To keep media in a stable location:
        PLAYOUT_DATA="$HOME/Library/Application Support/Rust Playout" rust-playout --demo

      This alpha supports Apple Silicon on macOS 26 (Tahoe) or newer.
      The embedded UI needs no Node.js or Rust installation.
      FFmpeg 9 is required; a future FFmpeg major upgrade needs a new binary.
      The control API has no authentication and must remain local.
      Press Ctrl-C to exit. No background service is started automatically.
    EOS
  end

  test do
    require "json"
    require "net/http"

    assert_match "rust-playout 0.0.1-alpha", shell_output("#{bin}/rust-playout --version")
    port = free_port
    pid = spawn({ "PLAYOUT_PORT" => port.to_s, "PLAYOUT_DATA" => (testpath/"data").to_s },
                bin/"rust-playout", "--demo", out: testpath/"server.log", err: [:child, :out])
    begin
      base = "http://127.0.0.1:#{port}"
      state = nil
      120.times do
        begin
          state = JSON.parse(Net::HTTP.get(URI("#{base}/api/state")))
          break if state["status"] == "live" && state["program_ms"] >= 2500
        rescue Errno::ECONNREFUSED, EOFError
          # Demo creation and initial encoder startup may take a few seconds.
        end
        sleep 0.25
      end
      assert_equal "live", state&.fetch("status")
      assert_operator state["program_ms"], :>=, 2500
      assert_equal 3, state["assets"].length
      assert_match "root", Net::HTTP.get(URI("#{base}/"))
      media = state["output_url"].sub("master.m3u8", "media.m3u8")
      assert_match "#EXTINF", Net::HTTP.get(URI("#{base}#{media}"))
    ensure
      Process.kill("INT", pid)
      Process.wait(pid)
    end
  end
end
