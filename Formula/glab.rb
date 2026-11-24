class Glab < Formula
  desc "Open-source GitLab command-line tool"
  homepage "https://gitlab.com/gitlab-org/cli"
  url "https://gitlab.com/gitlab-org/cli.git",
    tag:      "v1.132.0",
    revision: "00f5b8fe102e1a07471aadd5a2e44f6ff1befeeb"
  license "MIT"
  head "https://gitlab.com/gitlab-org/cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    manifest_sha256 "8bbba28f51e0070afb394f8ad84d19877c42d1fa259eefe4d7ba53444e090b86"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "09c5db77a238b527499451d42cb8b51865a7d219f9de8236eb97c8841576add4"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "92860266eac6a8202b84ff4f77e78b7d1583676365f3d08b64247f5292427436"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d9365516dc0629305b135b5aae890dacc2e99418e4fcd4ea162672464b9bc01b"
  end

  depends_on "go" => :build

  # https://oaklab.hu/oaklab/glab-patches
  resource "patches" do
    url "https://oaklab.hu/oaklab/glab-patches.git",
        revision: "97b0f6e43633deb04c35d015ff2f29c1fa8c329d"
  end

  def install
    resource("patches").stage do
      patchdir = Dir.pwd
      Dir.chdir(buildpath) do
        Dir["#{patchdir}/*.patch"].each { |patch| system "patch", "-p1", "-i", patch }
      end
    end

    ENV["CGO_ENABLED"] = "1" if OS.mac?
    system "make"
    bin.install "bin/glab"
    generate_completions_from_executable(bin/"glab", "completion", "--shell")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/glab --version")

    # no-telemetry.patch: the telemetry hook setup must be compiled out
    # entirely, not merely disabled at runtime.
    refute_match "setupTelemetryHook", shell_output("strings #{bin}/glab")

    # A `host` set in config.yml must not hide a repo's real remote when it
    # points at a different, self-hosted GitLab instance; only an explicit
    # override (e.g. GITLAB_HOST) should. Fixed upstream in 1.125.0 (was
    # fix-host-override-hides-remotes.patch); kept as a regression check.
    # Using gitlab.com as the configured default would not exercise the bug,
    # since it is also glinstance's hardcoded default -- use a third host.
    (testpath/"repo").mkpath
    cd testpath/"repo" do
      system "git", "init", "-q"
      system "git", "remote", "add", "origin", "https://gitlab.selfhosted.invalid/foo/bar.git"
    end

    host_config = testpath/"host-config"
    host_config.mkpath
    (host_config/"config.yml").write "host: gitlab.otherdefault.invalid\n"
    (host_config/"config.yml").chmod 0600
    ENV["GLAB_CONFIG_DIR"] = host_config

    output = cd(testpath/"repo") { shell_output("#{bin}/glab issue list 2>&1", 1) }
    assert_match "Configured remotes: gitlab.selfhosted.invalid", output
    refute_match "gitlab.otherdefault.invalid", output
  end
end
