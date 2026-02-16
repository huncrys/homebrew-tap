class Chglog < Formula
  desc "Changelog management library and tool"
  homepage "https://github.com/goreleaser/chglog"
  url "https://github.com/goreleaser/chglog/archive/refs/tags/v0.7.4.tar.gz"
  sha256 "07942438f6a4329a86ded3f5048f43bc2f9d07cdf26ecbcf247e78e7ec75005c"
  license "MIT"
  head "https://github.com/goreleaser/chglog.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=v#{version}"), "./cmd/chglog"

    generate_completions_from_executable(bin/"chglog", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/chglog version 2>&1")
  end
end
