class Scrollapp < Formula
  desc "Lightweight utility that adds smooth auto-scrolling"
  homepage "https://scrollapp.app"
  license "GPL-3.0-or-later"
  head "https://github.com/fromis-9/scrollapp.git", branch: "main"

  stable do
    url "https://github.com/fromis-9/scrollapp/archive/refs/tags/v1.2.tar.gz"
    sha256 "cc2afb9d0b3728e5c33e7656b50ae3b7e7fc99874cb736f22d97ae062ed67128"

    patch do
      url "https://github.com/fromis-9/scrollapp/commit/ccb21a47daada11d8cca060adf0df9e7edc01830.patch?full_index=1"
      sha256 "833b9c29505378e78b8f4a09285ba20919c1c9beccdad64505a4f9700cb63c9b"
    end
  end

  bottle do
    root_url "https://ghcr.io/v2/huncrys/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "36cff5b3184c639d28dcf854a93ed4820942afefb83b7d8a63e668146282553d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0dd6e372ee1ff63fcf243c59ee19f75afbd33e90301c591b0ed121d3865c3b28"
    sha256 cellar: :any_skip_relocation, sequoia:       "8f0f4d861d534e6c767e2ce9371d85b16de5935519fa2f3e50c9a35761aa01f7"
  end

  depends_on xcode: ["16.0", :build] # for xcodebuild
  depends_on macos: :sequoia
  depends_on :macos

  # https://github.com/fromis-9/scrollapp/pull/10
  patch :DATA

  def install
    xcodebuild "-arch", Hardware::CPU.arch,
      "OTHER_SWIFT_FLAGS='-disable-sandbox'",
      "-configuration", "Release",
      "-project", "Scrollapp.xcodeproj",
      "SYMROOT=build",
      "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"
    prefix.install "build/Release/Scrollapp.app"
    bin.write_exec_script prefix/"Scrollapp.app/Contents/MacOS/Scrollapp"
  end

  # No test is possible, no --help or --version
  test do
    assert_path_exists prefix/"Scrollapp.app"
  end
end

__END__
From 0dd143e0094d2adb4d208b63916b8877b9218177 Mon Sep 17 00:00:00 2001
From: Hadar Shamir <hadars@saver.one>
Date: Wed, 19 Nov 2025 06:41:18 +0200
Subject: [PATCH 1/2] Add Middle Click (Hold) mode, UI enhancements, and
 trackpad toggle

## New Features
- **Middle Click (Hold)**: New activation method that stops scrolling when you release the middle mouse button
- **Scroll Speed Menu**: Replaced slider with dropdown menu offering 6 preset speeds (0.5x to 3.0x)
- **Faster Scrolling**: Increased maximum scroll speed from 30px to 60px and acceleration from 2.5x to 4.0x
- **Hide from Dock**: App now only appears in menu bar (using NSApp.setActivationPolicy(.accessory) and LSUIElement)
- **Trackpad Activation Toggle**: Added menu option to enable/disable Option+Scroll trackpad activation

## Improvements
- Removed unused 'Activation Methods' info menu
- Fixed trackpad mode to stop on any mouse click (not just middle click)
- Ensured click monitor is active for trackpad/manual activation modes
- Updated About dialog with clearer activation method descriptions

## Bug Fixes
- **Added missing project.pbxproj file** (closes #8) - Project can now be built from source

## Technical Details
- Added middleClickHold enum case with usesHoldBehavior property
- Split click monitor setup into separate function for dynamic behavior switching
- Monitor is properly recreated when changing activation methods
- Trackpad toggle persists via UserDefaults (defaults to enabled)

All changes maintain backward compatibility with existing functionality.
---
 Scrollapp.xcodeproj/project.pbxproj | 330 ++++++++++++++++++++++++++++
 Scrollapp/Info.plist                |   3 +
 Scrollapp/ScrollappApp.swift        | 244 ++++++++++++--------
 3 files changed, 488 insertions(+), 89 deletions(-)
 create mode 100644 Scrollapp.xcodeproj/project.pbxproj

diff --git a/Scrollapp.xcodeproj/project.pbxproj b/Scrollapp.xcodeproj/project.pbxproj
new file mode 100644
index 0000000000000000000000000000000000000000..52d083c3b3bef18b3db1c703026c12ff6937ecb1
--- /dev/null
+++ b/Scrollapp.xcodeproj/project.pbxproj
@@ -0,0 +1,330 @@
+// !$*UTF8*$!
+{
+	archiveVersion = 1;
+	classes = {
+	};
+	objectVersion = 77;
+	objects = {
+
+/* Begin PBXFileReference section */
+		1A331E6A2ECCD7A600A55FB0 /* Scrollapp.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Scrollapp.app; sourceTree = BUILT_PRODUCTS_DIR; };
+/* End PBXFileReference section */
+
+/* Begin PBXFileSystemSynchronizedRootGroup section */
+		1A331E6C2ECCD7A600A55FB0 /* Scrollapp */ = {
+			isa = PBXFileSystemSynchronizedRootGroup;
+			path = Scrollapp;
+			sourceTree = "<group>";
+		};
+/* End PBXFileSystemSynchronizedRootGroup section */
+
+/* Begin PBXFrameworksBuildPhase section */
+		1A331E672ECCD7A600A55FB0 /* Frameworks */ = {
+			isa = PBXFrameworksBuildPhase;
+			buildActionMask = 2147483647;
+			files = (
+			);
+			runOnlyForDeploymentPostprocessing = 0;
+		};
+/* End PBXFrameworksBuildPhase section */
+
+/* Begin PBXGroup section */
+		1A331E612ECCD7A600A55FB0 = {
+			isa = PBXGroup;
+			children = (
+				1A331E6C2ECCD7A600A55FB0 /* Scrollapp */,
+				1A331E6B2ECCD7A600A55FB0 /* Products */,
+			);
+			sourceTree = "<group>";
+		};
+		1A331E6B2ECCD7A600A55FB0 /* Products */ = {
+			isa = PBXGroup;
+			children = (
+				1A331E6A2ECCD7A600A55FB0 /* Scrollapp.app */,
+			);
+			name = Products;
+			sourceTree = "<group>";
+		};
+/* End PBXGroup section */
+
+/* Begin PBXNativeTarget section */
+		1A331E692ECCD7A600A55FB0 /* Scrollapp */ = {
+			isa = PBXNativeTarget;
+			buildConfigurationList = 1A331E752ECCD7A700A55FB0 /* Build configuration list for PBXNativeTarget "Scrollapp" */;
+			buildPhases = (
+				1A331E662ECCD7A600A55FB0 /* Sources */,
+				1A331E672ECCD7A600A55FB0 /* Frameworks */,
+				1A331E682ECCD7A600A55FB0 /* Resources */,
+			);
+			buildRules = (
+			);
+			dependencies = (
+			);
+			fileSystemSynchronizedGroups = (
+				1A331E6C2ECCD7A600A55FB0 /* Scrollapp */,
+			);
+			name = Scrollapp;
+			packageProductDependencies = (
+			);
+			productName = Scrollapp;
+			productReference = 1A331E6A2ECCD7A600A55FB0 /* Scrollapp.app */;
+			productType = "com.apple.product-type.application";
+		};
+/* End PBXNativeTarget section */
+
+/* Begin PBXProject section */
+		1A331E622ECCD7A600A55FB0 /* Project object */ = {
+			isa = PBXProject;
+			attributes = {
+				BuildIndependentTargetsInParallel = 1;
+				LastSwiftUpdateCheck = 2610;
+				LastUpgradeCheck = 2610;
+				TargetAttributes = {
+					1A331E692ECCD7A600A55FB0 = {
+						CreatedOnToolsVersion = 26.1.1;
+					};
+				};
+			};
+			buildConfigurationList = 1A331E652ECCD7A600A55FB0 /* Build configuration list for PBXProject "Scrollapp" */;
+			developmentRegion = en;
+			hasScannedForEncodings = 0;
+			knownRegions = (
+				en,
+				Base,
+			);
+			mainGroup = 1A331E612ECCD7A600A55FB0;
+			minimizedProjectReferenceProxies = 1;
+			preferredProjectObjectVersion = 77;
+			productRefGroup = 1A331E6B2ECCD7A600A55FB0 /* Products */;
+			projectDirPath = "";
+			projectRoot = "";
+			targets = (
+				1A331E692ECCD7A600A55FB0 /* Scrollapp */,
+			);
+		};
+/* End PBXProject section */
+
+/* Begin PBXResourcesBuildPhase section */
+		1A331E682ECCD7A600A55FB0 /* Resources */ = {
+			isa = PBXResourcesBuildPhase;
+			buildActionMask = 2147483647;
+			files = (
+			);
+			runOnlyForDeploymentPostprocessing = 0;
+		};
+/* End PBXResourcesBuildPhase section */
+
+/* Begin PBXSourcesBuildPhase section */
+		1A331E662ECCD7A600A55FB0 /* Sources */ = {
+			isa = PBXSourcesBuildPhase;
+			buildActionMask = 2147483647;
+			files = (
+			);
+			runOnlyForDeploymentPostprocessing = 0;
+		};
+/* End PBXSourcesBuildPhase section */
+
+/* Begin XCBuildConfiguration section */
+		1A331E732ECCD7A700A55FB0 /* Debug */ = {
+			isa = XCBuildConfiguration;
+			buildSettings = {
+				ALWAYS_SEARCH_USER_PATHS = NO;
+				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
+				CLANG_ANALYZER_NONNULL = YES;
+				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
+				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
+				CLANG_ENABLE_MODULES = YES;
+				CLANG_ENABLE_OBJC_ARC = YES;
+				CLANG_ENABLE_OBJC_WEAK = YES;
+				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
+				CLANG_WARN_BOOL_CONVERSION = YES;
+				CLANG_WARN_COMMA = YES;
+				CLANG_WARN_CONSTANT_CONVERSION = YES;
+				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
+				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
+				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
+				CLANG_WARN_EMPTY_BODY = YES;
+				CLANG_WARN_ENUM_CONVERSION = YES;
+				CLANG_WARN_INFINITE_RECURSION = YES;
+				CLANG_WARN_INT_CONVERSION = YES;
+				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
+				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
+				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
+				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
+				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
+				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
+				CLANG_WARN_STRICT_PROTOTYPES = YES;
+				CLANG_WARN_SUSPICIOUS_MOVE = YES;
+				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
+				CLANG_WARN_UNREACHABLE_CODE = YES;
+				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
+				COPY_PHASE_STRIP = NO;
+				DEBUG_INFORMATION_FORMAT = dwarf;
+				ENABLE_STRICT_OBJC_MSGSEND = YES;
+				ENABLE_TESTABILITY = YES;
+				ENABLE_USER_SCRIPT_SANDBOXING = YES;
+				GCC_C_LANGUAGE_STANDARD = gnu17;
+				GCC_DYNAMIC_NO_PIC = NO;
+				GCC_NO_COMMON_BLOCKS = YES;
+				GCC_OPTIMIZATION_LEVEL = 0;
+				GCC_PREPROCESSOR_DEFINITIONS = (
+					"DEBUG=1",
+					"$(inherited)",
+				);
+				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
+				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
+				GCC_WARN_UNDECLARED_SELECTOR = YES;
+				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
+				GCC_WARN_UNUSED_FUNCTION = YES;
+				GCC_WARN_UNUSED_VARIABLE = YES;
+				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
+				MACOSX_DEPLOYMENT_TARGET = 26.1;
+				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
+				MTL_FAST_MATH = YES;
+				ONLY_ACTIVE_ARCH = YES;
+				SDKROOT = macosx;
+				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
+				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
+			};
+			name = Debug;
+		};
+		1A331E742ECCD7A700A55FB0 /* Release */ = {
+			isa = XCBuildConfiguration;
+			buildSettings = {
+				ALWAYS_SEARCH_USER_PATHS = NO;
+				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
+				CLANG_ANALYZER_NONNULL = YES;
+				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
+				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
+				CLANG_ENABLE_MODULES = YES;
+				CLANG_ENABLE_OBJC_ARC = YES;
+				CLANG_ENABLE_OBJC_WEAK = YES;
+				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
+				CLANG_WARN_BOOL_CONVERSION = YES;
+				CLANG_WARN_COMMA = YES;
+				CLANG_WARN_CONSTANT_CONVERSION = YES;
+				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
+				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
+				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
+				CLANG_WARN_EMPTY_BODY = YES;
+				CLANG_WARN_ENUM_CONVERSION = YES;
+				CLANG_WARN_INFINITE_RECURSION = YES;
+				CLANG_WARN_INT_CONVERSION = YES;
+				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
+				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
+				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
+				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
+				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
+				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
+				CLANG_WARN_STRICT_PROTOTYPES = YES;
+				CLANG_WARN_SUSPICIOUS_MOVE = YES;
+				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
+				CLANG_WARN_UNREACHABLE_CODE = YES;
+				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
+				COPY_PHASE_STRIP = NO;
+				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
+				ENABLE_NS_ASSERTIONS = NO;
+				ENABLE_STRICT_OBJC_MSGSEND = YES;
+				ENABLE_USER_SCRIPT_SANDBOXING = YES;
+				GCC_C_LANGUAGE_STANDARD = gnu17;
+				GCC_NO_COMMON_BLOCKS = YES;
+				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
+				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
+				GCC_WARN_UNDECLARED_SELECTOR = YES;
+				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
+				GCC_WARN_UNUSED_FUNCTION = YES;
+				GCC_WARN_UNUSED_VARIABLE = YES;
+				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
+				MACOSX_DEPLOYMENT_TARGET = 26.1;
+				MTL_ENABLE_DEBUG_INFO = NO;
+				MTL_FAST_MATH = YES;
+				SDKROOT = macosx;
+				SWIFT_COMPILATION_MODE = wholemodule;
+			};
+			name = Release;
+		};
+		1A331E762ECCD7A700A55FB0 /* Debug */ = {
+			isa = XCBuildConfiguration;
+			buildSettings = {
+				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
+				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
+				CODE_SIGN_STYLE = Automatic;
+				COMBINE_HIDPI_IMAGES = YES;
+				CURRENT_PROJECT_VERSION = 1;
+				ENABLE_APP_SANDBOX = YES;
+				ENABLE_PREVIEWS = YES;
+				ENABLE_USER_SELECTED_FILES = readonly;
+				GENERATE_INFOPLIST_FILE = YES;
+				INFOPLIST_KEY_NSHumanReadableCopyright = "";
+				LD_RUNPATH_SEARCH_PATHS = (
+					"$(inherited)",
+					"@executable_path/../Frameworks",
+				);
+				MARKETING_VERSION = 1.0;
+				PRODUCT_BUNDLE_IDENTIFIER = com.Scrollapp;
+				PRODUCT_NAME = "$(TARGET_NAME)";
+				REGISTER_APP_GROUPS = YES;
+				STRING_CATALOG_GENERATE_SYMBOLS = YES;
+				SWIFT_APPROACHABLE_CONCURRENCY = YES;
+				SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
+				SWIFT_EMIT_LOC_STRINGS = YES;
+				SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES;
+				SWIFT_VERSION = 5.0;
+			};
+			name = Debug;
+		};
+		1A331E772ECCD7A700A55FB0 /* Release */ = {
+			isa = XCBuildConfiguration;
+			buildSettings = {
+				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
+				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
+				CODE_SIGN_STYLE = Automatic;
+				COMBINE_HIDPI_IMAGES = YES;
+				CURRENT_PROJECT_VERSION = 1;
+				ENABLE_APP_SANDBOX = YES;
+				ENABLE_PREVIEWS = YES;
+				ENABLE_USER_SELECTED_FILES = readonly;
+				GENERATE_INFOPLIST_FILE = YES;
+				INFOPLIST_KEY_NSHumanReadableCopyright = "";
+				LD_RUNPATH_SEARCH_PATHS = (
+					"$(inherited)",
+					"@executable_path/../Frameworks",
+				);
+				MARKETING_VERSION = 1.0;
+				PRODUCT_BUNDLE_IDENTIFIER = com.Scrollapp;
+				PRODUCT_NAME = "$(TARGET_NAME)";
+				REGISTER_APP_GROUPS = YES;
+				STRING_CATALOG_GENERATE_SYMBOLS = YES;
+				SWIFT_APPROACHABLE_CONCURRENCY = YES;
+				SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
+				SWIFT_EMIT_LOC_STRINGS = YES;
+				SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES;
+				SWIFT_VERSION = 5.0;
+			};
+			name = Release;
+		};
+/* End XCBuildConfiguration section */
+
+/* Begin XCConfigurationList section */
+		1A331E652ECCD7A600A55FB0 /* Build configuration list for PBXProject "Scrollapp" */ = {
+			isa = XCConfigurationList;
+			buildConfigurations = (
+				1A331E732ECCD7A700A55FB0 /* Debug */,
+				1A331E742ECCD7A700A55FB0 /* Release */,
+			);
+			defaultConfigurationIsVisible = 0;
+			defaultConfigurationName = Release;
+		};
+		1A331E752ECCD7A700A55FB0 /* Build configuration list for PBXNativeTarget "Scrollapp" */ = {
+			isa = XCConfigurationList;
+			buildConfigurations = (
+				1A331E762ECCD7A700A55FB0 /* Debug */,
+				1A331E772ECCD7A700A55FB0 /* Release */,
+			);
+			defaultConfigurationIsVisible = 0;
+			defaultConfigurationName = Release;
+		};
+/* End XCConfigurationList section */
+	};
+	rootObject = 1A331E622ECCD7A600A55FB0 /* Project object */;
+}
diff --git a/Scrollapp/Info.plist b/Scrollapp/Info.plist
index 7695008945fc872471bdc429a8f1b24cc97c895e..d3a90d245f18f0822f2ae92d8461225dfbb56d8d 100644
--- a/Scrollapp/Info.plist
+++ b/Scrollapp/Info.plist
@@ -14,5 +14,8 @@
 	
 	<key>LSRequiresNativeExecution</key>
 	<true/>
+
+	<key>LSUIElement</key>
+	<true/>
 </dict>
 </plist>
diff --git a/Scrollapp/ScrollappApp.swift b/Scrollapp/ScrollappApp.swift
index e8dcd1ae96daf8c2ea5df954aecb9e3df38564ff..721b4b26834eabcde1c55a683040f82ffe7cc856 100644
--- a/Scrollapp/ScrollappApp.swift
+++ b/Scrollapp/ScrollappApp.swift
@@ -39,19 +39,21 @@ class AppDelegate: NSObject, NSApplicationDelegate {
     var launchAtLogin = false        // Track launch at login state
     var scrollSensitivity: Double = 1.0  // Default sensitivity multiplier
     var activationMethod: ActivationMethod = .middleClick  // Default activation method
+    var enableTrackpadActivation = true  // Enable/disable Option+Scroll trackpad activation
     
     enum ActivationMethod: String, CaseIterable {
         case middleClick = "Middle Click"
+        case middleClickHold = "Middle Click (Hold)"
         case shiftMiddleClick = "Shift + Middle Click"
         case cmdMiddleClick = "Cmd + Middle Click"
         case optionMiddleClick = "Option + Middle Click"
         case button4 = "Mouse Button 4"
         case button5 = "Mouse Button 5"
         case doubleMiddleClick = "Double Middle Click"
-        
+
         var buttonNumber: Int? {
             switch self {
-            case .middleClick, .shiftMiddleClick, .cmdMiddleClick, .optionMiddleClick, .doubleMiddleClick:
+            case .middleClick, .middleClickHold, .shiftMiddleClick, .cmdMiddleClick, .optionMiddleClick, .doubleMiddleClick:
                 return 2
             case .button4:
                 return 3
@@ -59,7 +61,7 @@ class AppDelegate: NSObject, NSApplicationDelegate {
                 return 4
             }
         }
-        
+
         var requiresModifier: Bool {
             switch self {
             case .shiftMiddleClick, .cmdMiddleClick, .optionMiddleClick:
@@ -68,7 +70,7 @@ class AppDelegate: NSObject, NSApplicationDelegate {
                 return false
             }
         }
-        
+
         var modifierFlags: NSEvent.ModifierFlags? {
             switch self {
             case .shiftMiddleClick:
@@ -81,31 +83,45 @@ class AppDelegate: NSObject, NSApplicationDelegate {
                 return nil
             }
         }
+
+        var usesHoldBehavior: Bool {
+            return self == .middleClickHold
+        }
     }
 
     func applicationDidFinishLaunching(_ notification: Notification) {
+        // Hide from Dock - menu bar only app
+        NSApp.setActivationPolicy(.accessory)
+
         // Load user preferences
         isDirectionInverted = UserDefaults.standard.bool(forKey: "invertScrollDirection")
         launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")
         scrollSensitivity = UserDefaults.standard.double(forKey: "scrollSensitivity")
         if scrollSensitivity == 0 { scrollSensitivity = 1.0 } // Default if not set
-        
+
+        // Load trackpad activation preference (default to true if not set)
+        if UserDefaults.standard.object(forKey: "enableTrackpadActivation") != nil {
+            enableTrackpadActivation = UserDefaults.standard.bool(forKey: "enableTrackpadActivation")
+        }
+
         // Load activation method
         if let savedMethod = UserDefaults.standard.string(forKey: "activationMethod"),
            let method = ActivationMethod(rawValue: savedMethod) {
             activationMethod = method
         }
-        
+
         // Set initial launch at login state based on saved preference
         updateLoginItemState()
-        
+
         // Check and request Accessibility permissions
         checkAccessibilityPermissions()
-        
+
         setupMenuBar()
         createScrollCursor()
         setupMiddleClickListeners()
-        setupTrackpadActivation()
+        if enableTrackpadActivation {
+            setupTrackpadActivation()
+        }
         
         // Request notification permission
         UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
@@ -124,69 +140,64 @@ class AppDelegate: NSObject, NSApplicationDelegate {
         let menu = NSMenu()
         menu.addItem(NSMenuItem(title: "Start/Stop Auto-Scroll", action: #selector(toggleTrackpadMode), keyEquivalent: ""))
         menu.addItem(NSMenuItem.separator())
-        
-        // Add sensitivity slider
-        let sensitivityItem = NSMenuItem(title: String(format: "Scroll Speed: %.1fx", scrollSensitivity), action: nil, keyEquivalent: "")
-        let sensitivityView = NSView(frame: NSRect(x: 0, y: 0, width: 250, height: 30))
-        
-        let slider = NSSlider(frame: NSRect(x: 20, y: 5, width: 150, height: 20))
-        slider.minValue = 0.2
-        slider.maxValue = 3.0
-        slider.doubleValue = scrollSensitivity
-        slider.target = self
-        slider.action = #selector(sensitivityChanged(_:))
-        slider.isContinuous = true
-        
-        let label = NSTextField(labelWithString: String(format: "%.1fx", scrollSensitivity))
-        label.frame = NSRect(x: 180, y: 5, width: 50, height: 20)
-        label.alignment = .center
-        label.tag = 100 // Tag to find it later
-        
-        sensitivityView.addSubview(slider)
-        sensitivityView.addSubview(label)
-        sensitivityItem.view = sensitivityView
-        menu.addItem(sensitivityItem)
-        
+
+        // Add scroll speed submenu
+        let speedMenu = NSMenu()
+        let speedItem = NSMenuItem(title: "Scroll Speed", action: nil, keyEquivalent: "")
+        speedItem.submenu = speedMenu
+
+        let speeds: [(String, Double)] = [
+            ("Very Slow (0.5x)", 0.5),
+            ("Slow (0.75x)", 0.75),
+            ("Normal (1.0x)", 1.0),
+            ("Fast (1.5x)", 1.5),
+            ("Very Fast (2.0x)", 2.0),
+            ("Ultra Fast (3.0x)", 3.0)
+        ]
+
+        for (title, speed) in speeds {
+            let speedMenuItem = NSMenuItem(title: title, action: #selector(setScrollSpeed(_:)), keyEquivalent: "")
+            speedMenuItem.representedObject = speed
+            speedMenuItem.state = (abs(scrollSensitivity - speed) < 0.01) ? .on : .off
+            speedMenu.addItem(speedMenuItem)
+        }
+
+        menu.addItem(speedItem)
         menu.addItem(NSMenuItem.separator())
-        
+
         // Add activation method submenu
         let activationMenu = NSMenu()
         let activationItem = NSMenuItem(title: "Activation Method", action: nil, keyEquivalent: "")
         activationItem.submenu = activationMenu
-        
+
         for method in ActivationMethod.allCases {
             let methodItem = NSMenuItem(title: method.rawValue, action: #selector(selectActivationMethod(_:)), keyEquivalent: "")
             methodItem.representedObject = method
             methodItem.state = (method == activationMethod) ? .on : .off
             activationMenu.addItem(methodItem)
         }
-        
+
         menu.addItem(activationItem)
-        
-        // Add inverted direction toggle option - reworded to match new default
+        menu.addItem(NSMenuItem.separator())
+
+        // Add inverted direction toggle option
         let invertItem = NSMenuItem(title: "Invert Scrolling Direction", action: #selector(toggleDirectionInversion), keyEquivalent: "")
         invertItem.state = isDirectionInverted ? .on : .off
         menu.addItem(invertItem)
-        
+
+        // Add trackpad activation toggle
+        let trackpadItem = NSMenuItem(title: "Enable Trackpad Activation", action: #selector(toggleTrackpadActivation), keyEquivalent: "")
+        trackpadItem.state = enableTrackpadActivation ? .on : .off
+        menu.addItem(trackpadItem)
+
         // Add launch at login toggle
         let launchItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
         launchItem.state = launchAtLogin ? .on : .off
         menu.addItem(launchItem)
-        
+
         menu.addItem(NSMenuItem.separator())
         menu.addItem(NSMenuItem(title: "About Scrollapp", action: #selector(showAbout), keyEquivalent: ""))
-        
-        let methodsMenu = NSMenu()
-        let methodsItem = NSMenuItem(title: "Activation Methods", action: nil, keyEquivalent: "")
-        methodsItem.submenu = methodsMenu
-        
-        methodsMenu.addItem(NSMenuItem(title: "Mouse - Configurable button/modifier (see Activation Method)", action: nil, keyEquivalent: ""))
-        methodsMenu.addItem(NSMenuItem(title: "Option + Scroll - Start auto-scroll (trackpad)", action: nil, keyEquivalent: ""))
-        methodsMenu.addItem(NSMenuItem(title: "Menu Bar - Use the menu option above", action: nil, keyEquivalent: ""))
-        methodsMenu.addItem(NSMenuItem(title: "Click - Stop auto-scroll", action: nil, keyEquivalent: ""))
-        
-        menu.addItem(methodsItem)
-        
+
         menu.addItem(NSMenuItem.separator())
         menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
         statusItem.menu = menu
@@ -314,8 +325,8 @@ class AppDelegate: NSObject, NSApplicationDelegate {
 
         // Quadratic acceleration: scrollSpeed grows faster as distance increases
         let acceleration = pow(distance / 50, 2.0) // scale distance into a nice curve
-        let maxScrollSpeed: CGFloat = 30.00
-        let scrollSpeed = min(acceleration * 2.5, maxScrollSpeed) // scaled + capped
+        let maxScrollSpeed: CGFloat = 60.00
+        let scrollSpeed = min(acceleration * 4.0, maxScrollSpeed) // scaled + capped
 
         // Apply sensitivity multiplier with exponential scaling for values < 1.0
         // This makes slower speeds MUCH slower but still usable
@@ -358,11 +369,18 @@ class AppDelegate: NSObject, NSApplicationDelegate {
 
     func startTrackpadAutoScroll() {
         stopAutoScroll() // Clear any existing state
-        
+
         isTrackpadMode = true
         originalPoint = NSEvent.mouseLocation
         isAutoScrolling = true
-        
+
+        // Ensure click monitor is active for trackpad mode
+        if clickMonitor == nil {
+            clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { [weak self] _ in
+                self?.stopAutoScroll()
+            }
+        }
+
         // Show custom cursor
         NSCursor.hide()
         scrollCursor?.set()
@@ -397,27 +415,29 @@ class AppDelegate: NSObject, NSApplicationDelegate {
         }
     }
 
-    @objc func sensitivityChanged(_ sender: NSSlider) {
-        scrollSensitivity = sender.doubleValue
+    @objc func setScrollSpeed(_ sender: NSMenuItem) {
+        guard let speed = sender.representedObject as? Double else { return }
+
+        scrollSensitivity = speed
         UserDefaults.standard.set(scrollSensitivity, forKey: "scrollSensitivity")
-        
-        // Update the label and menu item title
-        if let sensitivityItem = statusItem.menu?.items.first(where: { $0.title.starts(with: "Scroll Speed") }) {
-            sensitivityItem.title = String(format: "Scroll Speed: %.1fx", scrollSensitivity)
-            
-            if let view = sensitivityItem.view,
-               let label = view.viewWithTag(100) as? NSTextField {
-                label.stringValue = String(format: "%.1fx", scrollSensitivity)
+
+        // Update menu item states
+        if let speedItem = statusItem.menu?.items.first(where: { $0.title == "Scroll Speed" }),
+           let submenu = speedItem.submenu {
+            for item in submenu.items {
+                if let itemSpeed = item.representedObject as? Double {
+                    item.state = (abs(itemSpeed - speed) < 0.01) ? .on : .off
+                }
             }
         }
     }
-    
+
     @objc func selectActivationMethod(_ sender: NSMenuItem) {
         guard let method = sender.representedObject as? ActivationMethod else { return }
-        
+
         activationMethod = method
         UserDefaults.standard.set(method.rawValue, forKey: "activationMethod")
-        
+
         // Update menu item states
         if let activationItem = statusItem.menu?.items.first(where: { $0.title == "Activation Method" }),
            let submenu = activationItem.submenu {
@@ -425,16 +445,23 @@ class AppDelegate: NSObject, NSApplicationDelegate {
                 item.state = (item.representedObject as? ActivationMethod == method) ? .on : .off
             }
         }
-        
+
         // Restart mouse listeners with new configuration
         setupMiddleClickListeners()
+
+        // Restart click monitor with new behavior
+        if let monitor = clickMonitor {
+            NSEvent.removeMonitor(monitor)
+            clickMonitor = nil
+        }
+        setupClickMonitor()
     }
 
     @objc func showAbout() {
         let alert = NSAlert()
         alert.messageText = "About Scrollapp"
         
-        alert.informativeText = "Scrollapp enables auto-scrolling on macOS.\n\nHow to activate:\n• Mouse: Configurable button/modifier (see Activation Method in menu)\n• Trackpad: Hold Option key and scroll with two fingers\n• Menu: Use the menu bar icon and select 'Start/Stop Auto-Scroll'\n\nHow to stop:\n• Click anywhere to exit auto-scroll mode\n• Use your configured activation method again\n\nWhile active, move your cursor to control scroll speed and direction.\n\nAdjust scroll speed using the slider in the menu bar (0.2x - 3.0x).\nSpeeds below 1.0x are exponentially slower for fine control.\n\nConfigure your preferred activation method in the 'Activation Method' submenu to avoid conflicts with browser link opening."
+        alert.informativeText = "Scrollapp enables auto-scrolling on macOS.\n\nActivation methods:\n• Mouse: Select your preference in 'Activation Method' menu\n• Trackpad: Option + Scroll (can be toggled on/off in menu)\n• Manual: Click 'Start/Stop Auto-Scroll' in menu\n\nHow to stop:\n• Middle Click (Hold): Release the button\n• Other methods: Click any mouse button\n\nWhile active, move your cursor to control scroll speed and direction.\n\nAdjust scroll speed in the 'Scroll Speed' submenu."
         alert.alertStyle = .informational
         alert.addButton(withTitle: "OK")
         alert.runModal()
@@ -457,22 +484,22 @@ class AppDelegate: NSObject, NSApplicationDelegate {
         // Detect Option key via flagsChanged
         optionKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
             guard let self = self else { return }
-            
+
             // Detect Option key
             let optionKeyFlag = NSEvent.ModifierFlags.option
-            
+
             // If Option key is pressed and we're not already scrolling
             if event.modifierFlags.contains(optionKeyFlag) && !self.isAutoScrolling {
                 // Start a timer to detect if two-finger scroll happens while Option is pressed
                 self.lastScrollTime = Date()
-                
+
                 // If we detect a scroll within 1 second of Option press, activate auto-scroll
                 DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                     self?.lastScrollTime = nil
                 }
             }
         }
-        
+
         // Detect two-finger scroll while Option is pressed
         scrollMonitor = NSEvent.addGlobalMonitorForEvents(matching: .scrollWheel) { [weak self] event in
             guard let self = self,
@@ -480,24 +507,40 @@ class AppDelegate: NSObject, NSApplicationDelegate {
                   Date().timeIntervalSince(lastScrollTime) < 1.0,
                   !self.isAutoScrolling,
                   abs(event.deltaY) > 0.1 else { return }
-            
+
             // Option + scroll detected, activate auto-scroll
             self.startTrackpadAutoScroll()
         }
-        
-        // Monitor for clicks to exit auto-scroll mode
-        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { [weak self] event in
-            guard let self = self, self.isAutoScrolling else { return }
-            
-            // Don't stop auto-scroll for the configured activation button
-            if event.type == .otherMouseDown,
-               let activationButtonNumber = self.activationMethod.buttonNumber,
-               event.buttonNumber == activationButtonNumber {
-                return // Skip - let the activation method handler deal with it
+    }
+
+    func setupClickMonitor() {
+        // Monitor for clicks/releases to exit auto-scroll mode
+        if activationMethod.usesHoldBehavior {
+            // Hold behavior: stop on button release
+            clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.otherMouseUp]) { [weak self] event in
+                guard let self = self, self.isAutoScrolling else { return }
+
+                // Stop auto-scroll when releasing the activation button
+                if let activationButtonNumber = self.activationMethod.buttonNumber,
+                   event.buttonNumber == activationButtonNumber {
+                    self.stopAutoScroll()
+                }
+            }
+        } else {
+            // Original behavior: stop on any click
+            clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { [weak self] event in
+                guard let self = self, self.isAutoScrolling else { return }
+
+                // Don't stop auto-scroll for the configured activation button
+                if event.type == .otherMouseDown,
+                   let activationButtonNumber = self.activationMethod.buttonNumber,
+                   event.buttonNumber == activationButtonNumber {
+                    return // Skip - let the activation method handler deal with it
+                }
+
+                // For all other clicks, stop auto-scroll
+                self.stopAutoScroll()
             }
-            
-            // For all other clicks, stop auto-scroll
-            self.stopAutoScroll()
         }
     }
 
@@ -517,11 +560,34 @@ class AppDelegate: NSObject, NSApplicationDelegate {
         // No notification - removed
     }
 
+    @objc func toggleTrackpadActivation() {
+        enableTrackpadActivation = !enableTrackpadActivation
+        UserDefaults.standard.set(enableTrackpadActivation, forKey: "enableTrackpadActivation")
+
+        // Update menu item state
+        if let trackpadItem = statusItem.menu?.items.first(where: { $0.title == "Enable Trackpad Activation" }) {
+            trackpadItem.state = enableTrackpadActivation ? .on : .off
+        }
+
+        // Restart trackpad listeners
+        if let monitor = optionKeyMonitor {
+            NSEvent.removeMonitor(monitor)
+            optionKeyMonitor = nil
+        }
+        if let monitor = scrollMonitor {
+            NSEvent.removeMonitor(monitor)
+            scrollMonitor = nil
+        }
+        if enableTrackpadActivation {
+            setupTrackpadActivation()
+        }
+    }
+
     @objc func toggleLaunchAtLogin() {
         launchAtLogin = !launchAtLogin
         UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
         updateLoginItemState()
-        
+
         // Update menu item state
         if let launchItem = statusItem.menu?.items.first(where: { $0.title == "Launch at Login" }) {
             launchItem.state = launchAtLogin ? .on : .off

From e1af9d7c9bf1fac2548941bd89072a3194b9596b Mon Sep 17 00:00:00 2001
From: Hadar Shamir <hadars@saver.one>
Date: Wed, 3 Dec 2025 19:08:38 +0200
Subject: [PATCH 2/2] Fix: Initialize click monitor on app launch

setupClickMonitor() was only called when manually selecting an activation
method, causing hold-behavior modes like "Middle Click (Hold)" to not work
after app restart.
---
 Scrollapp/ScrollappApp.swift | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Scrollapp/ScrollappApp.swift b/Scrollapp/ScrollappApp.swift
index 721b4b26834eabcde1c55a683040f82ffe7cc856..6644d47ac93edc09d4eaf459f596da2a96eb3a77 100644
--- a/Scrollapp/ScrollappApp.swift
+++ b/Scrollapp/ScrollappApp.swift
@@ -119,6 +119,7 @@ class AppDelegate: NSObject, NSApplicationDelegate {
         setupMenuBar()
         createScrollCursor()
         setupMiddleClickListeners()
+        setupClickMonitor()
         if enableTrackpadActivation {
             setupTrackpadActivation()
         }
