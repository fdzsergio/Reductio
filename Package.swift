// swift-tools-version:5.5
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
        .iOS(.v8),
        .macOS(.v10_10),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(name: "Reductio", targets: ["Reductio"])
    ],
    targets: [
        .target(name: "Reductio", path: "Source"),
        .testTarget(name: "ReductioTests", path: "Tests")
    ],
    swiftLanguageVersions: [.v5]
)
