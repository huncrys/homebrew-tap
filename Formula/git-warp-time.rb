class GitWarpTime < Formula
  desc "Resets timestamps of repository files to the time of the last modifying commit"
  homepage "https://github.com/alerque/git-warp-time"
  url "https://github.com/alerque/git-warp-time/releases/download/v1.0.0/git-warp-time-1.0.0.tar.zst"
  sha256 "16ad1f6f61199011c9bdcc0e17dc5122f7e1eb2008090e9ca6f9052c9b7117bf"
  license "GPL-3.0-only"

  head do
    url "https://github.com/alerque/git-warp-time.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "jq" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "libgit2"

  # Additional dependency
  # resource "" do
  #   url ""
  #   sha256 ""
  # end

  def install
    ENV["LIBGIT2_NO_VENDOR"] = "1"

    system "./bootstrap.sh" if build.head?

    system "./configure", *std_configure_args

    system "make",
      "BASH_COMPLETION_DIR=#{bash_completion}",
      "FISH_COMPLETION_DIR=#{fish_completion}",
      "ZSH_COMPLETION_DIR=#{zsh_completion}",
      "install-strip"
  end

  test do
    system "git", "init", "--initial-branch=main"
    system "git", "config", "user.name", "BrewTestBot"
    system "git", "config", "user.email", "BrewTestBot@test.com"

    (testpath/"test").write "foo"
    system "git", "add", "test"
    ENV["GIT_AUTHOR_DATE"] = "2000-01-01T00:00:00Z"
    ENV["GIT_COMMITTER_DATE"] = "2000-01-01T00:00:00Z"
    system "git", "commit", "-m", "Initial commit"

    system bin/"git-warp-time", "-q", "test"
    assert_equal "2000-01-01T00:00:00Z", File.mtime(testpath/"test").utc.iso8601
  end
end
