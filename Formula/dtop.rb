class Dtop < Formula
  desc "Terminal-based Docker monitoring tool"
  homepage "https://dtop.dev/"
  url "https://github.com/amir20/dtop/archive/refs/tags/v0.7.1.tar.gz"
  sha256 "3c7de485a14908edb280d55116c8ab82a08dcd65c327c839971db79d0e7800ad"
  license "MIT"
  head "https://github.com/amir20/dtop.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "34f69d932c465ec2debee15e311729f402f985d10c20f7203429da116f9ef59e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "3750cbd18420370a4445c0c07f06a1d16b25558fba5b9e987aa5912e42f2c5c4"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "748e813b9a1c493aca5e805a3723661ac49473a6945db9ffb8e43575add03b86"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "6ddd78e3acc69f4c82a4449c35cfe59f79e17a5ae669dda90d3b34f3dfd837b0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4c28dabfe72c8ac548b52b15e07eeb528ff368979a7f0a1a03fea1b7d4bda174"
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
