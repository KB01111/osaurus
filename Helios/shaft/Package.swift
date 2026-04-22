// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "HeliosShaft",
    products: [
        .executable(name: "heliosshaft", targets: ["HeliosShaftApp"])
    ],
    targets: [
        .executableTarget(name: "HeliosShaftApp")
    ]
)
