# Homebrew formula for DIAspeXtract: the prebuilt, self-contained release bundles from
# https://github.com/okohlbacher/diaspextract/releases. The tap's release workflow (.github/workflows/release.yml)
# rewrites the version, the URLs and the sha256 values on every release; do not edit them by hand.
#
# The placeholder sha256 values below are replaced on the first release dispatched to the tap.
class Diaspextract < Formula
  desc "Pseudo-MS/MS spectra from DIA data (diaPASEF, Orbitrap) for DDA search engines"
  homepage "https://github.com/okohlbacher/diaspextract"
  version "1.8.3"
  license "BSD-3-Clause"
  # The bundled libraries' install names are @rpath/<name>; this keeps Homebrew from rewriting them, which would break
  # their Developer ID signatures on macOS and with them the tool's start.
  preserve_rpath

  on_macos do
    on_arm do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.8.3/DIAspeXtract-macos-arm64.tar.gz"
      sha256 "541bbfdb7b556c66392ae2ac6f86d8e3e491dc4801edc853b1b0041222a02c78"
    end
    on_intel do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.8.3/DIAspeXtract-macos-x64.tar.gz"
      sha256 "eeeddc5035b24c0e2829311e15da5a3ae3c10a025a9ce65f3d98f041c0bdfc96"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.8.3/DIAspeXtract-linux-arm64.tar.gz"
      sha256 "352000859296d47956f2088b7ddf58814ca2e5cf1340eddc2ced4cd1a3a6f796"
    end
    on_intel do
      url "https://github.com/okohlbacher/diaspextract/releases/download/v1.8.3/DIAspeXtract-linux-x64.tar.gz"
      sha256 "493748c9a71f7992ab377f86d361cfe828b1804126520beb18e886174f66825d"
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
