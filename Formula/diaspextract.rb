# Homebrew formula for DIAspeXtract: the prebuilt, self-contained release bundles from
# https://github.com/okohlbacher/diaspextract/releases. The tap's release workflow (.github/workflows/release.yml)
# rewrites the version, the URLs and the sha256 values on every release; do not edit them by hand.
#
# The placeholder sha256 values below are replaced on the first release dispatched to the tap.
class Diaspextract < Formula
  desc "Pseudo-MS/MS spectra from DIA data (diaPASEF, Orbitrap) for DDA search engines"
  homepage "https://github.com/okohlbacher/diaspextract"
  version "1.9.4"
  license "BSD-3-Clause"
  # The bundled libraries' install names are @rpath/<name>; this keeps Homebrew from rewriting them, which would break
  # their Developer ID signatures on macOS and with them the tool's start.
  preserve_rpath

  on_macos do
    on_arm do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.4/DIAspeXtract-macos-arm64.tar.gz"
      sha256 "c0395b0f173d33aed292c65bc9d71129ffc1b478cd69ed0ca4cc80bd2afcbf1e"
    end
    on_intel do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.4/DIAspeXtract-macos-x64.tar.gz"
      sha256 "0f88fac18a2f0d32a2b537927f9c08336dc3caf3a1a025c4257335695a3ee591"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.4/DIAspeXtract-linux-arm64.tar.gz"
      sha256 "427ce7166a3698d60762531fd31e167e604b806754741565a87edf41ae8f444d"
    end
    on_intel do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.4/DIAspeXtract-linux-x64.tar.gz"
      sha256 "5068d11488d7d4d11911e52b410b55aa5ae019b29dca938f012a5cacd63fea2e"
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
