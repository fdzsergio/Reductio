// swift-tools-version:5.7
import PackageDescription

/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */


let package = Package(
    name: "Reductio",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Reductio",
            targets: ["Reductio"]),
    ],
    dependencies: [
        // Add any dependencies here
    ],
    targets: [
        .target(
            name: "Reductio",
            path: "Source"  // Set custom path to source files
        ),
        .testTarget(
            name: "ReductioTests",
            dependencies: ["Reductio"],
            path: "Tests"
        ),
    ]
)
