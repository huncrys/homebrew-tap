class Chglog < Formula
  desc "Changelog management library and tool"
  homepage "https://github.com/goreleaser/chglog"
  url "https://github.com/goreleaser/chglog/archive/refs/tags/v0.7.5.tar.gz"
  sha256 "4cdb8ba7f91bba2e21f28958f94dc7d8ed16bcdfd01942714e4f29f6a9de84e6"
  license "MIT"
  head "https://github.com/goreleaser/chglog.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "c01858e3e98983d1e17daa5810f8e590f4ac2b3fdc4cdeaec053535c5577614f"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "7112e943904a85ef5c96d6b7dc1c0f634e04312dc0c4402598b84ea0bf5fdcdf"
    sha256 cellar: :any,                 x86_64_linux: "e016b553e39bf5de7822750bdd4a40bf018032684064f7eafba6d281d1a218b4"
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
