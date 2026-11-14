# Homebrew formula for DIAspeXtract: the prebuilt, self-contained release bundles from
# https://github.com/okohlbacher/diaspextract/releases. The tap's release workflow (.github/workflows/release.yml)
# rewrites the version, the URLs and the sha256 values on every release; do not edit them by hand.
#
# The placeholder sha256 values below are replaced on the first release dispatched to the tap.
class Diaspextract < Formula
  desc "Pseudo-MS/MS spectra from DIA data (diaPASEF, Orbitrap) for DDA search engines"
  homepage "https://github.com/okohlbacher/diaspextract"
  version "1.9.5"
  license "BSD-3-Clause"
  # The bundled libraries' install names are @rpath/<name>; this keeps Homebrew from rewriting them, which would break
  # their Developer ID signatures on macOS and with them the tool's start.
  preserve_rpath

  on_macos do
    on_arm do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.5/DIAspeXtract-macos-arm64.tar.gz"
      sha256 "dc07614854dfc2e2f5e7c296e8949600da9dfabb3b1cc5561a61b01cae2933ad"
    end
    on_intel do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.5/DIAspeXtract-macos-x64.tar.gz"
      sha256 "f5a095d4f372035b7f17f2ea96cfa31ba2b217eaaeba88b4931844c5502e1ff4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.5/DIAspeXtract-linux-arm64.tar.gz"
      sha256 "9c82c96c88a054242200d058125c8ac6fedeb7c4f68874e046941bb3b01f2c45"
    end
    on_intel do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.5/DIAspeXtract-linux-x64.tar.gz"
      sha256 "b594cd50db03c04012ae98e0840f1cfbb0300f5cad4b6ddf8bb25530fbfcbeb9"
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
