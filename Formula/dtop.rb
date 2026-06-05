class Dtop < Formula
  desc "Terminal-based Docker monitoring tool"
  homepage "https://dtop.dev/"
  url "https://github.com/amir20/dtop/archive/refs/tags/v0.7.7.tar.gz"
  sha256 "504eb5f81e04cfb40b80cf1893c73e0c3f3bffa85e28d459ee158166b9e12731"
  license "MIT"
  head "https://github.com/amir20/dtop.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "296433d41194c9385a4864f5b9838a62460775b86cdfed000caca42fc7017768"
    sha256 cellar: :any,                 arm64_linux:  "e83519fd71d38b9820bc5c3651f5f6ff0f07f44a6a31db53a25033b84b1d0ee3"
    sha256 cellar: :any,                 x86_64_linux: "4c937f486de414ffa2d97811d86d92096a6a6283542407df392d6e370621ad61"
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
