# Thinkelution Homebrew tap

## Rust Playout — Apple Silicon

```sh
brew install thinkelution/tap/rust-playout
rust-playout --demo
```

Open **http://127.0.0.1:8787**. FFmpeg is installed as a dependency; no Rust,
Node.js or source checkout is needed. This installs the official 0.0.1-alpha
release archive with its SHA-256 verified by Homebrew.

**Requirements:** Apple Silicon, macOS 26 (Tahoe) or newer, Homebrew in
`/opt/homebrew`, and FFmpeg 9. This release was tested on macOS 26.5.1.
An FFmpeg major upgrade requires a compatible Rust Playout release.

The server stays in your terminal; Ctrl-C exits. No background service is started.
To retain media independently of the current directory:

```sh
PLAYOUT_DATA="$HOME/Library/Application Support/Rust Playout" rust-playout --demo
```

The control room includes start/stop, a live rundown, HLS, timed L-shaped ads,
captions and RTMP publishing. Keep the unauthenticated API local.
See the [project README and screenshots](https://github.com/Thinkelution/rust-playout)
and [release notes](https://github.com/Thinkelution/rust-playout/releases/tag/v0.0.1-alpha).

## Update or remove

```sh
brew update
brew upgrade thinkelution/tap/rust-playout
brew uninstall rust-playout
```

Uninstalling leaves your media and HLS data in the directory you selected.
This is a third-party tap, not a homebrew/core package. Homebrew may request trust
for this formula; the direct install above scopes that trust to this formula.
The executable is ad-hoc signed, not notarized; no Gatekeeper settings are modified.

## Maintainers

Update the release URL, version, checksum and supported FFmpeg ABI together.
Before publishing a formula update, run `brew test thinkelution/tap/rust-playout`.
Do not silently repoint an existing version at a different binary.

GPL-3.0-or-later. See [LICENSE](LICENSE).
