class Dtop < Formula
  desc "Terminal-based Docker monitoring tool"
  homepage "https://dtop.dev/"
  url "https://github.com/amir20/dtop/archive/refs/tags/v0.7.6.tar.gz"
  sha256 "580e28ceae6a58051f795e638294c5aefa1a0e35708c07a5a2f1de35a8e9cc7c"
  license "MIT"
  head "https://github.com/amir20/dtop.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b51d7cfe5630f45270f7c0fe7f4ffa334c92e17578a17cb04d5bce30b6dbfdee"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e50341156a31e53ada800cc90dc342cbef312e153243c12ab434c362b9b75702"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "968676e6fd872727affd34d29b5ad5092f6ebdfb5ed48448c88acec1c9d17e98"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "fd5e51a28803d457fcc21792e6bdc5152fd7826f0a59a2c35da367dea6676540"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "c49b9d1f6bee40fc0f99fcb19439283ba45706afe76607fa8b5dd4d561140860"
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
