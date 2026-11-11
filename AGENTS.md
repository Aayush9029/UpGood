# UpGood

A small macOS menu bar app that uploads a file and copies its URL. Temporary uploads go to Litterbox (1h to 72h, up to 1 GB). Permanent uploads go to Catbox (up to 200 MB). Stack: SwiftUI and AppKit in an Xcode project, with the Point-Free packages `swift-case-paths`, `swift-identified-collections`, and `swift-sharing`. Status: shipped, no active work.

## Commands

| Task | Command |
|------|---------|
| Build | `xcodebuild -project UpGood.xcodeproj -scheme UpGood -destination 'platform=macOS' build` |
| Dead code scan | `periphery scan` (uses `.periphery.yml`) |

There is no test target.

## Layout

- `UpGood/UpGoodApp.swift`: the `AppDelegate` with the `NSStatusItem`, file drop on the status item, and the macOS Services menu provider (`NSServices` in `Info.plist`).
- `UpGood/ViewModels/FileUploader.swift`: the size check and the multipart upload to the Catbox and Litterbox APIs.
- `UpGood/ViewModels/UpGoodViewModel.swift`: upload state and the copy of the result URL.
- `UpGood/Models/Constants.swift`: endpoints and limits.
- `UpGood/Views/`: the upload screens and small button views.

## Rules

- The app needs no account and no API key. Do not add a sign-in.
- Keep the size check (`UploadMode.maxBytes`) before each upload, so a file over the limit fails fast.
- The deployment target is macOS 14.0. The README says macOS 13+, so update both when you change one.
- The project still uses the old personal team. Before you sign a build for distribution, change the team to the Developer ID team of the other macOS apps.
