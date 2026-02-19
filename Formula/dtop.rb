class Dtop < Formula
  desc "Terminal-based Docker monitoring tool"
  homepage "https://dtop.dev/"
  url "https://github.com/amir20/dtop/archive/refs/tags/v0.6.12.tar.gz"
  sha256 "4de635e34996cbace24e1111231a59e34cc7222f4042e69f82eef373f2cc3f39"
  license "MIT"
  head "https://github.com/amir20/dtop.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d8e1a8783308b6b2f1350e30166eb9faf5e013ec9630e4e8989291811b99a42f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "461920204212dc3cd5ad4bb5d7fc4b3586ce778001ba5ec4d2f2600f89f10a68"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "061e6cb19173ea02179b8ff943de255a7aa98fe8229c956a9c50bfafbdc55c26"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "770177b5a2e236866439780d59dc67422af9e5eee7b300393fb98b0490c0b72a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ae7936c93b32bb2fee49c6b7a7df7ef55c657a68959691d334c53c8763707301"
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
