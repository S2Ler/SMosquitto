// swift-tools-version:4.2

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
      pkgConfig: "mosquitto"
      ),
    .target(
      name: "SMosquitto",
      dependencies: ["cmosquitto"],
      path: "Sources/SMosquitto"
    )
  ],
  swiftLanguageVersions: [.v4_2]
)
