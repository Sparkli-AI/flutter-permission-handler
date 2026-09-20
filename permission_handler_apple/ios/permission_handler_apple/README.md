# Odyssey's temporary SwiftPM manifest

This fork changes only `Package.swift` and this document from
[`permission_handler_apple` 9.6.1](https://github.com/Baseflow/flutter-permission-handler/tree/permission_handler_apple_v9.6.1),
commit `5c989b1be9abbbb325424ad96e5be4efdc0987c2`. Native sources, the privacy
manifest, Dart API and other platforms are unchanged. Odyssey's workspace
override pins an immutable commit.

## Why it exists

Upstream's host-app discovery can fail when Xcode evaluates the cached package
outside the app directory, compiling out microphone support. Every Odyssey
flavor needs only microphone access through this plugin, so the manifest defines
`PERMISSION_MICROPHONE=1` directly without consulting the environment or app plist.

## What the manifest contains

| Declaration | Why it remains |
| --- | --- |
| Swift tools 5.9 | Preserves the upstream manifest's supported tools version. |
| Package, library and target names | Preserves the identities expected by Flutter's generated plugin package. |
| iOS 12 minimum | Preserves this plugin's minimum; Odyssey independently requires iOS 15. |
| `FlutterFramework` package and product | Flutter generates this sibling dependency, which supplies Flutter headers and linking. |
| `PrivacyInfo.xcprivacy` resource | Retains upstream's privacy manifest in the built product. |
| Header search path `.` | Strategy and utility headers import root-level `PermissionHandlerEnums.h`. |
| Header search path `strategies` | `PermissionManager.h` imports strategy headers without a directory prefix. |
| Header search path `util` | `PermissionManager.h` imports `Codec.h` without a directory prefix. |
| `.define("PERMISSION_MICROPHONE")` | Compiles microphone support; the C-setting API defaults the value to `1`. |

SwiftPM infers the local package identity from its directory name, finds sources
under `Sources/permission_handler_apple` and public headers under `include`.
The manifest relies on these defaults.

Other opt-in permission macros, including notifications, retain their native
zero defaults. Always-available strategies and other plugins are unchanged.
Odyssey must supply `NSMicrophoneUsageDescription` in its Info.plist. Review the
compiler definitions and usage descriptions before adding another permission,
iOS app or differing flavor requirements to the workspace.

## Updating or removing the fork

The manifest's TODO is tracked in [SPRK-1975](https://linear.app/sparkli/issue/SPRK-1975/remove-odysseys-permission-handler-apple-swiftpm-manifest-fork).
Follow [Baseflow #1544's project-configuration request](https://github.com/Baseflow/flutter-permission-handler/issues/1544#issuecomment-5654036486).

When rebasing, recheck native permission defaults, header layout, privacy resources
and Flutter integration; update the immutable override and Odyssey's lockfile.

Remove the fork when a published release supports project-owned microphone-only
selection in Xcode and Flutter CLI without session-wide environment variables,
working-directory assumptions or manual manifest-cache clearing.

Verify fresh resolution from outside the app, CLI and Xcode builds, all four
flavors, microphone first request, deny/retry, grant, Settings recheck and a signed
Shorebird archive/export. Test restricted access on a suitable device and the
minimum supported iOS version. Then remove the override, resolve the published
package, update the lockfile, remove the workaround notes/TODO and close SPRK-1975.

References: [Flutter's SwiftPM migration guide](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)
and [SwiftPM manifest API](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html).
