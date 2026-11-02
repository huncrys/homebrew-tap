class Glab < Formula
  desc "Open-source GitLab command-line tool"
  homepage "https://gitlab.com/gitlab-org/cli"
  url "https://gitlab.com/gitlab-org/cli.git",
    tag:      "v1.126.0",
    revision: "4dd0d32d18361db6c1c668eb4ac691c0d6edf255"
  license "MIT"
  head "https://gitlab.com/gitlab-org/cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "f459bb2f8ecfe94ff11ca09389a9fae70dcea921a380ad73a68d8833afdb3a6d"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "3f98e0915c92f0052f47ac2d40d927df0e0f032e93f40faa458f9c7153274a04"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c64f1f640e40c92b07453a6d6f37e6f5bcc7219cfe70dd6eae066db81e5f6281"
  end

  depends_on "go" => :build

  # https://oaklab.hu/oaklab/glab-patches
  resource "patches" do
    url "https://oaklab.hu/oaklab/glab-patches.git",
        revision: "1d9c3a91fb25c74db1934cd7705cddb926a2089c"
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
