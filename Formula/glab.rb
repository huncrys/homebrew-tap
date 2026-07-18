class Glab < Formula
  desc "Open-source GitLab command-line tool"
  homepage "https://gitlab.com/gitlab-org/cli"
  url "https://gitlab.com/gitlab-org/cli.git",
    tag:      "v1.108.0",
    revision: "5de20850a43cbcacf3768f846eee3dae06731ef3"
  license "MIT"
  head "https://gitlab.com/gitlab-org/cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "66371223dd336ffdd49f080c994e7b6b8b227fd2da3b65afa041ee2aed4287f7"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "e865d1e6b40526fe773e2164bc5b529c4d69e7c054951980aaa274816c637976"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ff70ba5076803bbc79767c1af21ecbb9e2c16e58ed5f6bf45fce32925c8f7f25"
  end

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
