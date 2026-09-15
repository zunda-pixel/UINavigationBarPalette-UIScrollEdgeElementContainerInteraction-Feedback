// swift-tools-version: 6.4

import PackageDescription

let package = Package(
  name: "UINavigationBarPaletteFeedback",
  platforms: [
    .iOS(.v26),
  ],
  products: [
    .library(
      name: "UIKitCorePrivate",
      targets: ["UIKitCorePrivate"]
    ),
    .library(
      name: "Comparison",
      targets: ["Comparison"]
    ),
  ],
  targets: [
    .target(
      name: "UIKitCorePrivate"
    ),
    .target(
      name: "Comparison",
      dependencies: ["UIKitCorePrivate"]
    ),
  ]
)
