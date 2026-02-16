class Chglog < Formula
  desc "Changelog management library and tool"
  homepage "https://github.com/goreleaser/chglog"
  url "https://github.com/goreleaser/chglog/archive/refs/tags/v0.7.4.tar.gz"
  sha256 "07942438f6a4329a86ded3f5048f43bc2f9d07cdf26ecbcf247e78e7ec75005c"
  license "MIT"
  head "https://github.com/goreleaser/chglog.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "a03a2c12c35d9249f8e66259aa5451df13ca837e43ba5ab8ce804c87eca0f531"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f318f144be13a6c026c731359dc9e28a32334e489fbe5296c7449f1e8caf6c05"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "c49601d4d2d9b1cf2418a4a084e0537d5c150f2a9fb9f7316ecf3821f0b59ab2"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "9ea0cb818bbbd6d75084d7ed303c8e7bf1ea48a3595672dbed85654e41bfb83c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "0e5f20286a0de372918d41932e70a1e7472bf9c5753d53739587a25a63f0b531"
  end

  depends_on "go" => :build

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
