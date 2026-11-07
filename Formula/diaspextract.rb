# Homebrew formula for DIAspeXtract: the prebuilt, self-contained release bundles from
# https://github.com/okohlbacher/diaspextract/releases. The tap's release workflow (.github/workflows/release.yml)
# rewrites the version, the URLs and the sha256 values on every release; do not edit them by hand.
#
# The placeholder sha256 values below are replaced on the first release dispatched to the tap.
class Diaspextract < Formula
  desc "Pseudo-MS/MS spectra from DIA data (diaPASEF, Orbitrap) for DDA search engines"
  homepage "https://github.com/okohlbacher/diaspextract"
  version "1.9.2"
  license "BSD-3-Clause"
  # The bundled libraries' install names are @rpath/<name>; this keeps Homebrew from rewriting them, which would break
  # their Developer ID signatures on macOS and with them the tool's start.
  preserve_rpath

  on_macos do
    on_arm do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.2/DIAspeXtract-macos-arm64.tar.gz"
      sha256 "45d0f9d72a0bf429b5ca6aff516ed57d559018717a9279d0f07cf3864e252a59"
    end
    on_intel do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.2/DIAspeXtract-macos-x64.tar.gz"
      sha256 "ab7bf2aed22506f92f37a79b5ea36c4814f32f2bbe3bbbb395d95777f07508a0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.2/DIAspeXtract-linux-arm64.tar.gz"
      sha256 "449512a16d62e01cd659345a16519399ac424fe0f7b674d3ac9f9fd79271a512"
    end
    on_intel do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.9.2/DIAspeXtract-linux-x64.tar.gz"
      sha256 "ee89c8032a27b54df85720a03eb359bf4f34a2c88d5e4c0bbb8d34ffd3a4502d"
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
