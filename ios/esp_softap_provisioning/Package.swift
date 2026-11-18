// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "esp_softap_provisioning",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "esp-softap-provisioning", targets: ["esp_softap_provisioning"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "esp_softap_provisioning",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
