class Dtop < Formula
  desc "Terminal-based Docker monitoring tool"
  homepage "https://dtop.dev/"
  url "https://github.com/amir20/dtop/archive/refs/tags/v0.7.2.tar.gz"
  sha256 "e3a21fde14497c97f98721ae24c8334148f48bd3eb5f08b6a688bc018a360cea"
  license "MIT"
  head "https://github.com/amir20/dtop.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "1cd8ffaff11b1c3491d82c59b2a2c3ccb071c64176ae841d5c7e42098cecc7e7"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "158abcd927efdbe965fa3b3a016ba60dcbb97199bb8ef363fce811d14f7cc615"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "9d505b96442af36a6ea68f5c18783c7916df8103fac7d3fb00db3f62ef60b473"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "fce8b93e3e9769f9337f7d778041fbcae7f6bdc370d5f35fa9d328235042fad0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "f9dd7a8058abc3c495a9be2e6e52615a9a3f6570698818b35c3a9e243f6630c1"
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
