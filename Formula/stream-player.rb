class StreamPlayer < Formula
  desc "Open-source M3U8/IPTV player with EPG support"
  homepage "https://github.com/Thinkelution/stream-player"
  url "https://github.com/Thinkelution/stream-player/releases/download/v0.1.0/StreamPlayer-0.1.0.dmg"
  version "0.1.0"
  sha256 "REPLACE_WITH_ACTUAL_SHA256_AFTER_FIRST_BUILD"
  license "MIT"

  depends_on arch: :arm64
  depends_on :macos

  def install
    app.install "StreamPlayer.app"
  end

  def caveats
    <<~EOS
      StreamPlayer has been installed to Applications folder.

      Launch from Applications or use Spotlight search.

      To load your IPTV stream:
        1. Create ~/.streamplayer-config with:
           REACT_APP_M3U_URL=your_m3u_url
           REACT_APP_EPG_URL=your_epg_url
        2. Restart StreamPlayer

      This is an open-source IPTV player. Ensure you have rights to access streams.
    EOS
  end

  test do
    assert_predicate app/"StreamPlayer.app/Contents/MacOS/StreamPlayer", :exist?
  end
end
