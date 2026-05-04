class Dtop < Formula
  desc "Terminal-based Docker monitoring tool"
  homepage "https://dtop.dev/"
  url "https://github.com/amir20/dtop/archive/refs/tags/v0.7.4.tar.gz"
  sha256 "9557fe2425266c5820250f6cbe3421744b58d54bca792bcc9f4f7c68b76e30e1"
  license "MIT"
  head "https://github.com/amir20/dtop.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "25b4a7035711c4e8f1a305ced5ee6f3fb1a90e46f2b0b717cdf2165709630676"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "8afc217ad8afbfc186784cf00a1435aad28cc2c174441ec4a0e359b15d03ee60"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "eb1e6a6231670ac22318cf613860a300ffb3adc3ae5b913114097cbe68290564"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "dcbc54483f40f8526c2a2733ac9af5fc15b977d90d27b9f5acd6d2946c9fca82"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "24ed4ba3a41503ff3f291000d9a6ec52e6ea8876be898fc4b228aab1d8d8fd0b"
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
