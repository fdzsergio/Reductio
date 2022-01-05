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
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Reductio",
            targets: ["Reductio"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Reductio",
            dependencies: [],
            path: "Source"
        ),
        .testTarget(
            name: "ReductioTests",
            dependencies: ["Reductio"],
            path: "Tests"
        ),
    ]
)
