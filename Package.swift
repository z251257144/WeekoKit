// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "WeekoKit",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(name: "WeekoKit", targets: ["WeekoKit"]),
  ],
  targets: [
    .target(
      name: "WeekoKit",
      path: "Sources",
      resources: [
        .process("Localization/Resources"),
      ]
    ),
    .testTarget(
      name: "WeekoKitTests",
      dependencies: ["WeekoKit"],
      path: "Tests"
    ),
  ]
)
