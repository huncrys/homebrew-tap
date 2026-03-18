class Dtop < Formula
  desc "Terminal-based Docker monitoring tool"
  homepage "https://dtop.dev/"
  url "https://github.com/amir20/dtop/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "3286ea5a4d04134879a88b04332fa885f2228e0e1a15de2d9724b7f523448f5b"
  license "MIT"
  head "https://github.com/amir20/dtop.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d0585d8a272a19ed7a07bcf20fa7c7f3bf9047783367bfbfb4e527d8bf206416"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d127206521b460114c2a32a269c7a8159f1e59652b9b57da562f5cfa280b0936"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "7d2cdbd7f68a43e77e0faccc1d0b511eb67d624d4128ffe357a4272fe1aacf9f"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "9d90dd0dacfad9ee619ec3481a05026f813a523a822cb0beea14d5a8b50bd151"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "cc32846b7068fbf005d19d5ce9bd7870e8ed87e47fa17822709d71341c03415e"
  end

  depends_on "homebrew/core/rust" => :build

  def install
    system "cargo", "install", "--no-default-features", *std_cargo_args
  end

  test do
    ENV["DOCKER_HOST"] = "unix://#{testpath}/invalid.sock"

    assert_match "dtop #{version}", shell_output("#{bin}/dtop --version")

    output = shell_output("#{bin}/dtop 2>&1", 1)
    assert_match "Failed to connect to Docker host", output
  end
end
