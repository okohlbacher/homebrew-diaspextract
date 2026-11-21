# Homebrew formula for DIAspeXtract: the prebuilt, self-contained release bundles from
# https://github.com/okohlbacher/diaspextract/releases. The tap's release workflow (.github/workflows/release.yml)
# rewrites the version, the URLs and the sha256 values on every release; do not edit them by hand.
#
# The placeholder sha256 values below are replaced on the first release dispatched to the tap.
class Diaspextract < Formula
  desc "Pseudo-MS/MS spectra from DIA data (diaPASEF, Orbitrap) for DDA search engines"
  homepage "https://github.com/okohlbacher/diaspextract"
  version "1.9.8"
  license "BSD-3-Clause"
  # The bundled libraries' install names are @rpath/<name>; this keeps Homebrew from rewriting them, which would break
  # their Developer ID signatures on macOS and with them the tool's start.
  preserve_rpath

  on_macos do
    on_arm do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.8/DIAspeXtract-macos-arm64.tar.gz"
      sha256 "af454c1fc94b7d69fd6ca9340fb64b8b59ba1d847e409dd0055e1eebc75470f7"
    end
    on_intel do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.8/DIAspeXtract-macos-x64.tar.gz"
      sha256 "e8d5e0d176ec04f1fc9f99ddea2eebff704dbf6cb24ad529fb90ce3a2325cf7b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.8/DIAspeXtract-linux-arm64.tar.gz"
      sha256 "9c2f22081445c4f52c17dbed6d6d2fbbb05250ef3acd36578bff5dfd0b285de5"
    end
    on_intel do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.8/DIAspeXtract-linux-x64.tar.gz"
      sha256 "752f9ab8a0146428fb88135ceac84acde4c209c792a372a04b78a7577c84eed1"
    end
  end

  def install
    # The bundle stays together under libexec: bin/ finds lib/ through its RPATH and OpenMS finds share/OpenMS next
    # to bin/. A wrapper, not a symlink: on macOS OpenMS takes the executable's path without resolving symlinks, so a
    # symlinked bin/diaspextract would look for share/OpenMS under the Homebrew prefix. OPENMS_DATA_PATH is set too,
    # so another OpenMS on the machine can never supply the shared data.
    libexec.install Dir["*"]
    (bin/"diaspextract").write_env_script libexec/"bin/diaspextract",
                                          OPENMS_DATA_PATH: libexec/"share/OpenMS"
  end

  test do
    # TOPPBase writes --help to stderr.
    out = shell_output("#{bin}/diaspextract --help 2>&1")
    assert_match(/^Version: #{Regexp.escape(version.to_s)} \(OpenMS /, out)
  end
end
