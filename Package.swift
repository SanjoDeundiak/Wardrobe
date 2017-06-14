import PackageDescription

let package = Package(
    name: "Hello",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", "1.5.15"),
        .Package(url: "https://github.com/vapor/mongo-provider.git", "1.1.0")
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

