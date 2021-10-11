// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SMosquitto",
    products: [
        .library(
            name: "SMosquitto",
            type: .dynamic,
            targets: ["SMosquitto"]
        )
    ],
    targets: [
        .systemLibrary(
            name: "cmosquitto",
            path: "Sources/cmosquitto",
            pkgConfig: "libmosquitto",
            providers: [
                .brew(["mosquitto"]),
                .apt(["libmosquitto-dev"])
            ]
        ),
        .target(
            name: "SMosquitto",
            dependencies: ["cmosquitto"],
            path: "Sources/SMosquitto"
        ),
        .testTarget(
            name: "SMosquittoTests",
            dependencies: ["SMosquitto"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
