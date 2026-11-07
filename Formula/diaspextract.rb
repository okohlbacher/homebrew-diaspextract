# Homebrew formula for DIAspeXtract: the prebuilt, self-contained release bundles from
# https://github.com/okohlbacher/diaspextract/releases. The tap's release workflow (.github/workflows/release.yml)
# rewrites the version, the URLs and the sha256 values on every release; do not edit them by hand.
#
# The placeholder sha256 values below are replaced on the first release dispatched to the tap.
class Diaspextract < Formula
  desc "Pseudo-MS/MS spectra from DIA data (diaPASEF, Orbitrap) for DDA search engines"
  homepage "https://github.com/okohlbacher/diaspextract"
  version "1.9.1"
  license "BSD-3-Clause"
  # The bundled libraries' install names are @rpath/<name>; this keeps Homebrew from rewriting them, which would break
  # their Developer ID signatures on macOS and with them the tool's start.
  preserve_rpath

  on_macos do
    on_arm do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.1/DIAspeXtract-macos-arm64.tar.gz"
      sha256 "06d08575f3213146e56117b56a9a5dca53ac9272c8a9e0b9693529489b573ab3"
    end
    on_intel do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.1/DIAspeXtract-macos-x64.tar.gz"
      sha256 "368379e555ebc4599d3b0282653c2b2bcb853adc09004d6de9fe086bd5c12eba"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.1/DIAspeXtract-linux-arm64.tar.gz"
      sha256 "76dec9d5b7d5e6457cccf9b9b962bef87912438b237e51abdf7cacce03b6f6e3"
    end
    on_intel do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.1/DIAspeXtract-linux-x64.tar.gz"
      sha256 "9426913335f9ca60b4ae159d0d3b1ebf007efc6dce0772788b499b0d012ab494"
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
