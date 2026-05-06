class Dtop < Formula
  desc "Terminal-based Docker monitoring tool"
  homepage "https://dtop.dev/"
  url "https://github.com/amir20/dtop/archive/refs/tags/v0.7.6.tar.gz"
  sha256 "580e28ceae6a58051f795e638294c5aefa1a0e35708c07a5a2f1de35a8e9cc7c"
  license "MIT"
  head "https://github.com/amir20/dtop.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "2419c0a71be4687255f37c139d958b76a611381e49da3f00010ea787857e7b10"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "7f0c6e328de161b5c97b626ca6b6d2c5c2306630badf7dd004cb498d9cdba962"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "eb76b423720bb3620fefa204629e5d0f359585e2a14c539c6e0b7abc88cd1a97"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "7a74a4f96f1e6368dc9c9e13c8b17390645fc60e6f7f67c203cc6e6f13f91d20"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "f54e95ebc58cca5693886803d3f7403307b3c92e2df081db362822f3157bcb97"
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
