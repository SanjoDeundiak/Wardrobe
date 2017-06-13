import PackageDescription

let package = Package(
    name: "Hello",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2, minor: 1),
        .Package(url: "https://github.com/vapor/mongo-provider.git", majorVersion: 2, minor: 0)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

