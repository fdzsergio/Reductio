// swift-tools-version:6.0
/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import PackageDescription

let package = Package(
  name: "Reductio",
  platforms: [
    .iOS(.v13),
    .macOS(.v12),
    .tvOS(.v13),
    .watchOS(.v6)
  ],
  products: [
    .library(
      name: "Reductio",
      targets: ["Reductio"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
  ],
  targets: [
    .target(
      name: "Reductio",
      path: "Source",
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .testTarget(
      name: "ReductioTests",
      dependencies: ["Reductio"],
      path: "Tests",
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    )
  ]
)
