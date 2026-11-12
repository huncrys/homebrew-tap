class Chglog < Formula
  desc "Changelog management library and tool"
  homepage "https://github.com/goreleaser/chglog"
  url "https://github.com/goreleaser/chglog/archive/refs/tags/v0.7.5.tar.gz"
  sha256 "4cdb8ba7f91bba2e21f28958f94dc7d8ed16bcdfd01942714e4f29f6a9de84e6"
  license "MIT"
  head "https://github.com/goreleaser/chglog.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "2f4dd06ed57717dfdbfec516b2257438d37bd37453adee396bd61513abd8a2eb"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a375b3cb60e6d2f1181f924c0bdd872745de59b57fa19d7f4f4a155263d5f9ab"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "b1dd0d83640e4446698147c4654a933621cb27149a7331cd20eba50fc7881651"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "c8b18533acc2616799b7c45b2c8801f7c601e75ee8ee8b8018fbf1eb93f3aa45"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "cb65493088a036cfb90345cfcf410ee6e2de04e5b5aebb7fb3b6333184d8252c"
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
