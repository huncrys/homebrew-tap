class Glab < Formula
  desc "Open-source GitLab command-line tool"
  homepage "https://gitlab.com/gitlab-org/cli"
  url "https://gitlab.com/gitlab-org/cli.git",
    tag:      "v1.109.0",
    revision: "757294c01143360b466a70daf3fbef869fc3a41b"
  license "MIT"
  head "https://gitlab.com/gitlab-org/cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "a3cd264e5ed448d0790ab218606268f0ec80d2036db4f0efa6833aa69d23d63c"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "565b5a8859a3927da03763214a8b7a636a8a91669e425bb6b030764aec60f038"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "164f83799b2bb06ae0d0642956f61524774ab5533ce719e0f432f97767e42dae"
  end

  depends_on "go" => :build

  # https://oaklab.hu/oaklab/glab-patches
  resource "patches" do
    url "https://oaklab.hu/oaklab/glab-patches.git",
        revision: "c1437dd7b749f599343e11bab6d0e0b200e95db4"
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
