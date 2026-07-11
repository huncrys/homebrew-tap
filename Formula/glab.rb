class Glab < Formula
  desc "Open-source GitLab command-line tool"
  homepage "https://gitlab.com/gitlab-org/cli"
  url "https://gitlab.com/gitlab-org/cli.git",
    tag:      "v1.107.0",
    revision: "85b59ceb77434c988fead857a372691868aba6d7"
  license "MIT"
  head "https://gitlab.com/gitlab-org/cli.git", branch: "main"

  depends_on "go" => :build

  # https://oaklab.hu/oaklab/glab-patches
  resource "patches" do
    url "https://oaklab.hu/oaklab/glab-patches.git",
        revision: "21304d784b62560ea8c0c72b8a02b10e30b17036"
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

    ENV.delete("GITLAB_TOKEN")

    # fix-unauthenticated-header-error.patch: with no credentials configured
    # for the host at all, the request must still reach the server (which
    # replies 401) instead of erroring out client-side before it is sent.
    unauth_config = testpath/"unauth-config"
    unauth_config.mkpath
    ENV["GLAB_CONFIG_DIR"] = unauth_config
    output = shell_output("#{bin}/glab api version --hostname gitlab.com 2>&1", 1)
    refute_match "Unauthenticated.", output
    assert_match "401 Unauthorized", output

    # fix-host-override-hides-remotes.patch: a `host` set in config.yml must
    # not hide a repo's real remote when it points at a different, self-hosted
    # GitLab instance; only an explicit override (e.g. GITLAB_HOST) should.
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
