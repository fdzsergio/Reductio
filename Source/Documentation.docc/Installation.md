# Installation

Add Reductio to your Swift project using Swift Package Manager.

## Requirements

- **Swift**: 6.0+
- **Xcode**: 15.0+
- **Platforms**:
  - iOS 13.0+
  - macOS 12.0+
  - tvOS 13.0+
  - watchOS 6.0+

## Swift Package Manager

### Using Xcode

1. Open your project in Xcode
2. Select **File → Add Package Dependencies...**
3. Enter the repository URL: `https://github.com/fdzsergio/Reductio.git`
4. Select version: **Up to Next Major Version** from `1.6.0`
5. Click **Add Package**
6. Select **Reductio** and click **Add Package**

### Using Package.swift

Add Reductio to your `Package.swift` dependencies:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "YourApp",
  platforms: [
    .iOS(.v13),
    .macOS(.v12),
    .tvOS(.v13),
    .watchOS(.v6)
  ],
  dependencies: [
    .package(url: "https://github.com/fdzsergio/Reductio.git", from: "1.6.0")
  ],
  targets: [
    .target(
      name: "YourApp",
      dependencies: ["Reductio"]
    ),
    .testTarget(
      name: "YourAppTests",
      dependencies: ["YourApp", "Reductio"]
    )
  ]
)
```

## Verify Installation

After installation, verify everything is working:

```swift
import Reductio

// Test keyword extraction
let testText = "Swift is a powerful and intuitive programming language."
let keywords = await Reductio.keywords(from: testText, count: 3)
print("Keywords: \(keywords)")
// Expected output: Keywords: ["swift", "programming", "language"]
```

## Platform-Specific Notes

### iOS
No additional configuration required. The library uses the built-in NaturalLanguage framework.

### macOS
Ensure your app has the necessary entitlements if sandboxed. No special permissions are required for text processing.

### watchOS
Due to memory constraints, it's recommended to:
- Process smaller text segments (under 1000 words)
- Use higher compression ratios (0.8-0.9)

### tvOS
Works identically to iOS. Consider UI constraints when displaying summaries.

## Troubleshooting

### Module Not Found
If you get "No such module 'Reductio'" error:
1. Clean build folder: **Product → Clean Build Folder**
2. Reset package caches: **File → Packages → Reset Package Caches**
3. Rebuild the project

### Minimum Deployment Target
Ensure your deployment target meets the minimum requirements:
- iOS 13.0+
- macOS 12.0+

### Swift Version
Reductio requires Swift 6.0. Update your toolchain if needed:
- Download latest Xcode from the App Store
- Or use [swift.org](https://swift.org/download/) for command-line tools

## Next Steps

Ready to start using Reductio? Head to <doc:GettingStarted> for a quick tutorial.