class Socktainer < Formula
  desc "Docker-compatible REST API on top of Apple container"
  homepage "https://github.com/socktainer/socktainer"
  url "https://github.com/socktainer/socktainer.git",
      tag:      "v0.12.0",
      revision: "5e8e4f2acbd83b4213d3c50f172220d9e2c839e7"
  license "Apache-2.0"
  head "https://github.com/socktainer/socktainer.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "17deb5ada50e5c803585e8b3a90a85388415bb38d006c5caf4befc183104fe5b"
  end

  depends_on xcode: ["26.0", :build]
  depends_on arch: :arm64
  depends_on "homebrew/core/container"
  depends_on macos: :tahoe
  depends_on :macos

  # https://github.com/socktainer/socktainer/pull/167
  patch :DATA

  def install
    ENV["BUILD_GIT_COMMIT"] = Utils.git_short_head
    ENV["BUILD_VERSION"] = version
    ENV["BUILD_TIME"] = time.iso8601
    ENV["DOCKER_ENGINE_API_MIN_VERSION"] = "v1.32"
    ENV["DOCKER_ENGINE_API_MAX_VERSION"] = "v1.51"

    system "swift", "build", "--disable-sandbox", "--configuration", "release"

    release_dir = buildpath/".build/release"

    bin.install release_dir/"socktainer"
  end

  service do
    run [opt_bin/"socktainer"]
    keep_alive true
    environment_variables PATH: std_service_path_env
    log_path var/"log/socktainer.log"
    error_log_path var/"log/socktainer.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/socktainer --version")
  end
end

__END__
From a8fcb0be681ab2299cd1f405f55b1b727e8d900e Mon Sep 17 00:00:00 2001
From: Pieter van der Weel <pieter@Metervanderweel.com>
Date: Fri, 2 Jan 2026 17:45:03 +0100
Subject: [PATCH] Check for exising volume with the same name and return it

---
 .../Clients/ClientVolumeService.swift         | 21 +++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/Sources/socktainer/Clients/ClientVolumeService.swift b/Sources/socktainer/Clients/ClientVolumeService.swift
index 5b31af563bb8ffcb9a69655b3411214c22c2df78..8af415a29cbfe6ed81527ebc5267a3d9372a87c5 100644
--- a/Sources/socktainer/Clients/ClientVolumeService.swift
+++ b/Sources/socktainer/Clients/ClientVolumeService.swift
@@ -12,12 +12,21 @@ protocol ClientVolumeProtocol: Sendable {
 
 struct ClientVolumeService: ClientVolumeProtocol {
     func create(request: RESTVolumeCreate) async throws -> Volume {
-        let result = try await ClientVolume.create(
-            name: request.Name,
-            driver: request.Driver,
-            driverOpts: request.Options,
-            labels: request.Labels ?? [:]
-        )
+        let existingVolumes = try await ClientVolume.list()
+        let existingVolume = existingVolumes.first { $0.name == request.Name }
+
+        let result: ContainerResource.Volume
+        if let existing = existingVolume {
+            // Volume exists, use it
+            result = existing
+        } else {
+            result = try await ClientVolume.create(
+                name: request.Name,
+                driver: request.Driver,
+                driverOpts: request.Options,
+                labels: request.Labels ?? [:]
+            )
+        }
         return Self.convert(result)
     }
 
