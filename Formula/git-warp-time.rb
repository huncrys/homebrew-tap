class GitWarpTime < Formula
  desc "Resets timestamps of repository files to the time of the last modifying commit"
  homepage "https://github.com/alerque/git-warp-time"
  url "https://github.com/alerque/git-warp-time/releases/download/v1.0.0/git-warp-time-1.0.0.tar.zst"
  sha256 "16ad1f6f61199011c9bdcc0e17dc5122f7e1eb2008090e9ca6f9052c9b7117bf"
  license "GPL-3.0-only"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    rebuild 1
    sha256 cellar: :any,                 arm64_tahoe:   "bed8b02b2a6c73b0ac346689139967d08741c57a30db22bbaf06e67da1bbaed3"
    sha256 cellar: :any,                 arm64_sequoia: "555325b8a8cf1dd2640c8fabcb5198129316cc6cf12d8a25443b56cd8900d68a"
    sha256 cellar: :any,                 arm64_sonoma:  "b20265a0aa381ecd8cb90ba5c0f0bfd01c73ae5eac37f5e7ee390f20407be25e"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "34ba3e6d180f65da73dc0f0b7e7c7d52da0cb508c72b1fd40e34b14cee15c3a6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "852d40d054638db93aef20ef1ccd85ff455a75a2c146c905fa31490586bf7be4"
  end

  head do
    url "https://github.com/alerque/git-warp-time.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "jq" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "libgit2"

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
