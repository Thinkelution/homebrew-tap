class StreamPlayer < Formula
  desc "Open-source M3U8/IPTV player with EPG support"
  homepage "https://github.com/Thinkelution/stream-player"
  url "https://github.com/Thinkelution/stream-player/releases/download/v0.1.0/StreamPlayer-0.1.0-arm64.dmg"
  version "0.1.0"
  sha256 "6b6971bf55d11e33e802eaeca8423756d196eb93cbad2057ab1ba9f86b9d2c45"
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

      To configure your IPTV source:
        1. Set environment variables (optional):
           export REACT_APP_M3U_URL="http://your-service.com/get.php?username=USER&password=PASS&type=m3u_plus&output=mpegts"
           export REACT_APP_EPG_URL="http://your-service.com/xmltv.php?username=USER&password=PASS"
        2. Launch StreamPlayer
        3. Channels will load from the M3U playlist

      This is an open-source IPTV player. Ensure you have rights to access streams.
    EOS
  end

  test do
    assert_predicate app/"StreamPlayer.app/Contents/MacOS/StreamPlayer", :exist?
  end
end
