# Odyssey's temporary SwiftPM manifest

This fork changes only `Package.swift` and this document. Its baseline is
[`permission_handler_apple` 9.6.1](https://github.com/Baseflow/flutter-permission-handler/tree/permission_handler_apple_v9.6.1),
upstream commit `5c989b1be9abbbb325424ad96e5be4efdc0987c2`. The native sources,
privacy manifest, Dart API and other platform implementations remain upstream's.
Odyssey pins the fork to an immutable commit in its workspace dependency override.

[SPRK-1975 tracks removal](https://linear.app/sparkli/issue/SPRK-1975/remove-odysseys-permission-handler-apple-swiftpm-manifest-fork),
including the upstream reports and acceptance criteria below.

## Why it exists

Upstream's manifest discovers the consuming app, reads its permission settings
and produces compiler definitions. That discovery can fail when Xcode evaluates
the manifest outside the app directory: the package lives in Pub's cache, and
neither its own path nor Xcode's working directory identifies the consuming app.
Microphone support can consequently compile out, leaving permission requests
unable to show the system prompt.

Environment overrides can work around this, but require developers and CI to
carry project-specific configuration outside version control. Xcode's inherited
environment and cached manifest evaluation also make this difficult to operate.
A scheme build pre-action runs too late to configure package resolution reliably.

Odyssey already uses the same `PERMISSION_MICROPHONE=1` setting in every flavor's
CocoaPods build. This manifest makes that existing choice explicit and independent
of the launch directory, machine environment, app-plist discovery and manifest
caches. It does not need flavor discovery or a configuration parser.

## What the manifest contains

| Declaration | Why it remains |
| --- | --- |
| Swift tools 5.9 | Preserves the upstream manifest's supported tools version. |
| Package, library and target names | Preserves the identities expected by Flutter's generated plugin package. |
| iOS 12 minimum | Preserves this plugin's minimum; Odyssey independently requires iOS 15. |
| `FlutterFramework` package and product | Uses Flutter 3.47.4's standard plugin template to expose Flutter's framework to this target. Flutter generates the sibling package. |
| `PrivacyInfo.xcprivacy` resource | Retains upstream's privacy manifest in the built product. |
| Header search path `.` | Strategy and utility headers import root-level `PermissionHandlerEnums.h`. |
| Header search path `strategies` | `PermissionManager.h` imports strategy headers without a directory prefix. |
| Header search path `util` | `PermissionManager.h` imports `Codec.h` without a directory prefix. |
| `PERMISSION_MICROPHONE=1` | Compiles the microphone implementation used by Odyssey. |

The C-setting API gives `.define("PERMISSION_MICROPHONE")` the value `1`; no
explicit value is needed. SwiftPM derives the local Flutter package identity from
its directory name.

SwiftPM already finds this target under `Sources/permission_handler_apple` and
exports public headers from `include`, so neither default is repeated. No extra
public-header search path, explicit source list, framework linker list, library
type or permission-discovery helper is needed.

Upstream's `PermissionHandlerEnums.h` defaults the other opt-in permission macros
to zero, matching Odyssey's previous Podfile. This includes notifications, which
upstream's dynamic SwiftPM manifest otherwise enables by default. The fork does
not remove source files or change the always-available strategies. Other plugins,
such as Firebase Messaging and the camera scanner, retain their own permissions.
Odyssey must still supply `NSMicrophoneUsageDescription` in its app Info.plist.

This is intentionally an app-specific configuration, not a general replacement
manifest for permission_handler users. Adding another permission through this
plugin, another iOS app to the workspace, or different permission requirements
between flavors requires reviewing this setting and the corresponding app usage
descriptions. Environment variables no longer change this manifest's selection.

## Updating or removing the fork

Track [Baseflow #1544](https://github.com/Baseflow/flutter-permission-handler/issues/1544),
especially the [request for project-scoped Xcode configuration](https://github.com/Baseflow/flutter-permission-handler/issues/1544#issuecomment-5654036486).
[PR #1553](https://github.com/Baseflow/flutter-permission-handler/pull/1553) and
[PR #1554](https://github.com/Baseflow/flutter-permission-handler/pull/1554) are
already in the baseline; their discovery/flavor improvements do not eliminate
this requirement. Issue closure alone is not sufficient evidence to remove it.

When taking a new upstream release, compare the entire Apple package, especially
its native permission defaults, source/header layout, privacy resource and Flutter
framework integration. Reapply only this manifest and documentation, then pin the
new fork commit and commit Odyssey's resulting `pubspec.lock`. Do not edit Pub's
global cache or use a moving branch as the application's dependency reference.

Remove the fork when a published upstream version supports deterministic,
project-owned microphone-only selection from both Xcode and Flutter CLI without
session-wide environment variables, working-directory assumptions or manual
manifest-cache clearing. The replacement must preserve the current permission
footprint in development, staging, preview and production.

Validate the replacement with fresh package resolution from outside the app,
Flutter CLI and Xcode builds, all flavor configurations, microphone first request,
deny/retry, grant and Settings recheck, plus a signed Shorebird archive/export.
Check restricted access on a suitable device and the minimum supported iOS version.
Then remove the workspace Git override, resolve the published package, update the
lockfile, remove Odyssey's workaround documentation/TODO and close its tracking
issue. The fork can remain archived as provenance for older pinned builds.

References: [Flutter's SwiftPM migration guide](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)
and [SwiftPM manifest API](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html).
