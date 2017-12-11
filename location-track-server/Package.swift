// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "LocationTrack",
    dependencies: [
        // 💧 A server-side Swift web framework. 
        .package(url: "https://github.com/vapor/vapor.git", .branch("ssl-server")),// .revision("9e32101")) //.branch("ssl-server")),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: ["Routing", "Service", "Vapor"]
        ),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

