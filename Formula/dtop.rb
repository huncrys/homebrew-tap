class Dtop < Formula
  desc "Terminal-based Docker monitoring tool"
  homepage "https://dtop.dev/"
  url "https://github.com/amir20/dtop/archive/refs/tags/v0.6.14.tar.gz"
  sha256 "d9612d24008944e66d68b5565a48e2acd1be25b165039dfa6056f45c769781c9"
  license "MIT"
  head "https://github.com/amir20/dtop.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "2a851de66654f1b203cd80407b96a4b91afb5904567752ab744836201d943705"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ad4b2e35cca5186a02cea8e4698b1c89b15c1aa00797689d2bf7d063c288b02b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2dc7b72bfd19c86e436427cf1accdb111bdb30ee1b94b02732b68c1dd13b72d6"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "a80065143d057e2db97ad2ae46d4ee7af110cecd850e09c1c27c8e6f73d88682"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7c37d91e1ef1008bd8efc564e145409a6cea4b78c06db7c0fe5e5805d9730b10"
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
