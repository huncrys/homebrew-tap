class Dtop < Formula
  desc "Terminal-based Docker monitoring tool"
  homepage "https://dtop.dev/"
  url "https://github.com/amir20/dtop/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "3286ea5a4d04134879a88b04332fa885f2228e0e1a15de2d9724b7f523448f5b"
  license "MIT"
  head "https://github.com/amir20/dtop.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e31e5c3fe7233ce12861135360d8568431f5352043c0fa1d4b84a4fa8b497bf3"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b60bd79348269b05e67793d3dc8f7b7c0ef5c4728510b470b867d7c57be0ed0b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "be7898913ac2bd86cfa2f69aea3513776c3d0a586a8d49761a8dd9806c62a25d"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "0496d0ad9c8d09772431c208cc347582b65d419de2763696bcb56c527279afb7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "83a75de50546cdf385098f8c3f3323ae1890750abf510e0cefd0443df3ff2e99"
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
