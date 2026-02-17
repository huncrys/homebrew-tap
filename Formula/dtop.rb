class Dtop < Formula
  desc "Terminal-based Docker monitoring tool"
  homepage "https://dtop.dev/"
  url "https://github.com/amir20/dtop/archive/refs/tags/v0.6.10.tar.gz"
  sha256 "4b40b354374aa39e97ef3724610c112cb38c687c8a2b6c6cbe2ce1f04d25cd0a"
  license "MIT"
  head "https://github.com/amir20/dtop.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "09481ffcd9add3e626a9905110efb4caf05d7ed76ae784ee084b74578b55ba31"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ffaa98566e9531db46c3a4747c47ab08f86a48b8eb90c27e870f893acd0283d7"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "fa6122aca5df46793244fdb43cdd02a2f97e3458815a3ad5d5f1376b1d666987"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "fe001a8801bf1cdf93a620bbaf8b4c81fe829f82ba3f6d335ed01f41c187378a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "84a9c558fadce335ab783d58c31807eb97ca5308fa52abf0f4f7aa7beaaa975f"
  end

  depends_on "rust" => :build

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
