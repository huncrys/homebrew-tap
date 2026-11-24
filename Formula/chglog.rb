class Chglog < Formula
  desc "Changelog management library and tool"
  homepage "https://github.com/goreleaser/chglog"
  url "https://github.com/goreleaser/chglog/archive/refs/tags/v0.7.6.tar.gz"
  sha256 "b24213d168803977a0fdec0600385dfba6131c447b1df93da437101eb024c7b1"
  license "MIT"
  head "https://github.com/goreleaser/chglog.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    manifest_sha256 "74caf14b06e8b51a2a87ad54cd863c90801feca8fe02d138b62d11abe00eebbf"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "40765ada97c2ae29760732fe691d9d72b0eeaabfbf5830d346b59db5a24bef49"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "8a17a9f60f31006fafbf2f344fca7b0c2b4a48a29a25343b44382149151941be"
    sha256 cellar: :any,                 x86_64_linux: "6f40185e9d8514bcffce3d113c83723f513a5940d18dcafd1a19bb42476726d4"
  end

  depends_on "homebrew/core/go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=v#{version}"), "./cmd/chglog"

    pkgshare.install "testdata/gold-init-changelog.yml", "testdata/TestFormatChangelog-deb"

    generate_completions_from_executable(bin/"chglog", shell_parameter_format: :cobra)
  end

  test do
    system bin/"chglog", "format",
      "-i", pkgshare/"gold-init-changelog.yml",
      "-o", testpath/"TestFormatChangelog-deb",
      "-t", "deb",
      "-p", "TestFormatChangelog-deb"
    assert_equal (pkgshare/"TestFormatChangelog-deb").read, (testpath/"TestFormatChangelog-deb").read
  end
end
