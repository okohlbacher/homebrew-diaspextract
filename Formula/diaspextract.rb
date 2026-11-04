# Homebrew formula for DIAspeXtract: the prebuilt, self-contained release bundles from
# https://github.com/okohlbacher/diaspextract/releases. The tap's release workflow (.github/workflows/release.yml)
# rewrites the version, the URLs and the sha256 values on every release; do not edit them by hand.
#
# The placeholder sha256 values below are replaced on the first release dispatched to the tap.
class Diaspextract < Formula
  desc "Pseudo-MS/MS spectra from DIA data (diaPASEF, Orbitrap) for DDA search engines"
  homepage "https://github.com/okohlbacher/diaspextract"
  version "1.8.4"
  license "BSD-3-Clause"
  # The bundled libraries' install names are @rpath/<name>; this keeps Homebrew from rewriting them, which would break
  # their Developer ID signatures on macOS and with them the tool's start.
  preserve_rpath

  on_macos do
    on_arm do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.8.4/DIAspeXtract-macos-arm64.tar.gz"
      sha256 "7a0de7a9bc6641d320b4ed78ef0cc6b67c121732e54128ee598f700731bcd76b"
    end
    on_intel do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.8.4/DIAspeXtract-macos-x64.tar.gz"
      sha256 "f086254f8a52198e1af6e5feed108748a1b80373125f501e2eddf1495af32bf7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.8.4/DIAspeXtract-linux-arm64.tar.gz"
      sha256 "f2bb87a4a2ecffdb018b9d2ec757b3230f0b7fd829c9559fd61ce3790dde1577"
    end
    on_intel do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.8.4/DIAspeXtract-linux-x64.tar.gz"
      sha256 "05cb6654ca6387b43701371f27d9d90652ee969c4f80909499041c0930c025c0"
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
