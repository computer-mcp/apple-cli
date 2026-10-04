// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let argumentParser: Target.Dependency = .product(
  name: "ArgumentParser",
  package: "swift-argument-parser"
)
let subprocess: Target.Dependency = .product(
  name: "Subprocess",
  package: "swift-subprocess"
)
let mcp: Target.Dependency = .product(
  name: "MCP",
  package: "swift-sdk"
)
let hummingbird: Target.Dependency = .product(
  name: "Hummingbird",
  package: "hummingbird"
)
let httpTypes: Target.Dependency = .product(
  name: "HTTPTypes",
  package: "swift-http-types"
)

let defaultNotesFrameworkStubPath = ".build/notes-private-framework-link-stubs/current"
let notesFrameworkStubPath =
  Context.environment["APPLE_CLI_NOTES_PRIVATE_FRAMEWORK_STUBS"] ?? defaultNotesFrameworkStubPath
let notesFrameworkModuleNames = [
  "NotesSupport",
  "NotesHTML",
  "NotesShared",
  "NotesUI",
  "NotesEditor",
  "NotesPreviewKit",
]
let notesFrameworkSwiftSettings: [SwiftSetting] = [.define("APPLE_CLI_NOTES_FRAMEWORKS_LINKED")]
let notesFrameworkLinkerSettings: [LinkerSetting] = {
  let patchedTBDs = notesFrameworkModuleNames.map {
    "\(notesFrameworkStubPath)/\($0).framework/\($0).tbd"
  }
  return [.unsafeFlags(["-F\(notesFrameworkStubPath)"] + patchedTBDs)]
}()

let package = Package(
  name: "apple-cli",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .executable(name: "apple", targets: ["AppleCLI"]),
    .executable(name: "apple-cli-mcp", targets: ["AppleMCPServer"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", exact: "1.8.2"),
    .package(
      url: "https://github.com/hummingbird-project/hummingbird.git", .upToNextMinor(from: "2.23.0")),
    .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", exact: "0.12.1"),
    .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
    .package(
      url: "https://github.com/swiftlang/swift-subprocess.git", .upToNextMinor(from: "0.4.0")),
  ],
  targets: [
    .target(
      name: "Utility",
      dependencies: [argumentParser, subprocess]
    ),
    .target(
      name: "ReminderKit",
      path: "Sources/ReminderKit",
      publicHeadersPath: "include"
    ),
    .target(
      name: "ReminderKitInternal",
      dependencies: ["ReminderKit"],
      path: "Sources/ReminderKitInternal",
      publicHeadersPath: "include"
    ),
    .target(
      name: "NotesSupport",
      path: "Sources/NotesSupport",
      publicHeadersPath: "include"
    ),
    .target(
      name: "NotesHTML",
      dependencies: ["NotesSupport"],
      path: "Sources/NotesHTML",
      publicHeadersPath: "include"
    ),
    .target(
      name: "NotesShared",
      dependencies: ["NotesSupport", "NotesHTML"],
      path: "Sources/NotesShared",
      publicHeadersPath: "include"
    ),
    .target(
      name: "NotesUI",
      dependencies: ["NotesSupport", "NotesHTML", "NotesShared"],
      path: "Sources/NotesUI",
      publicHeadersPath: "include"
    ),
    .target(
      name: "NotesEditor",
      dependencies: ["NotesSupport", "NotesHTML", "NotesShared", "NotesUI"],
      path: "Sources/NotesEditor",
      publicHeadersPath: "include"
    ),
    .target(
      name: "NotesPreviewKit",
      dependencies: ["NotesSupport", "NotesShared"],
      path: "Sources/NotesPreviewKit",
      publicHeadersPath: "include"
    ),
    .target(
      name: "CalendarCLI",
      dependencies: ["Utility", argumentParser]
    ),
    .target(
      name: "RemindersCLI",
      dependencies: ["Utility", "ReminderKit", "ReminderKitInternal", argumentParser],
      linkerSettings: [
        .unsafeFlags(["-F/System/Library/PrivateFrameworks"]),
        .linkedFramework("ReminderKit"),
        .linkedFramework("ReminderKitInternal"),
      ]
    ),
    .target(
      name: "ContactsCLI",
      dependencies: ["Utility", argumentParser]
    ),
    .target(
      name: "ClipboardCLI",
      dependencies: ["Utility", argumentParser]
    ),
    .target(
      name: "NotificationsCLI",
      dependencies: ["Utility", argumentParser]
    ),
    .target(
      name: "IntelligenceCLI",
      dependencies: ["Utility", argumentParser]
    ),
    .target(
      name: "NotesCLI",
      dependencies: [
        "Utility",
        "NotesSupport",
        "NotesHTML",
        "NotesShared",
        "NotesUI",
        "NotesEditor",
        "NotesPreviewKit",
        argumentParser,
      ],
      swiftSettings: notesFrameworkSwiftSettings,
      linkerSettings: notesFrameworkLinkerSettings
    ),
    .target(
      name: "MailCLI",
      dependencies: ["Utility", argumentParser]
    ),
    .target(
      name: "MessagesCLI",
      dependencies: ["Utility", argumentParser, subprocess]
    ),
    .target(
      name: "NumbersCLI",
      dependencies: ["Utility", argumentParser]
    ),
    .target(
      name: "PagesCLI",
      dependencies: ["Utility", argumentParser]
    ),
    .target(
      name: "KeynoteCLI",
      dependencies: ["Utility", argumentParser]
    ),
    .target(
      name: "FinderCLI",
      dependencies: ["Utility", argumentParser]
    ),
    .target(
      name: "FaceTimeCLI",
      dependencies: ["Utility", argumentParser]
    ),
    .target(
      name: "MapsCLI",
      dependencies: ["Utility", argumentParser]
    ),
    .target(
      name: "SafariCLI",
      dependencies: ["Utility", argumentParser]
    ),
    .target(
      name: "PhotosCLI",
      dependencies: ["Utility", argumentParser]
    ),
    .target(
      name: "PrintCLI",
      dependencies: ["Utility", argumentParser, subprocess]
    ),
    .target(
      name: "TCCCLI",
      dependencies: ["Utility", argumentParser, subprocess]
    ),
    .target(
      name: "AppleMCPAdapter",
      dependencies: ["Utility", mcp, subprocess]
    ),
    .executableTarget(
      name: "AppleCLI",
      dependencies: [
        "Utility",
        "CalendarCLI",
        "RemindersCLI",
        "ContactsCLI",
        "ClipboardCLI",
        "NotificationsCLI",
        "IntelligenceCLI",
        "NotesCLI",
        "MailCLI",
        "MessagesCLI",
        "NumbersCLI",
        "PagesCLI",
        "KeynoteCLI",
        "FinderCLI",
        "FaceTimeCLI",
        "MapsCLI",
        "SafariCLI",
        "PhotosCLI",
        "PrintCLI",
        "TCCCLI",
        argumentParser,
      ]
    ),
    .executableTarget(
      name: "AppleMCPServer",
      dependencies: ["Utility", "AppleMCPAdapter", argumentParser, hummingbird, httpTypes, mcp]
    ),
    .testTarget(
      name: "AppleCLITests",
      dependencies: [
        "Utility",
        "AppleMCPAdapter",
        "CalendarCLI",
        "RemindersCLI",
        "ContactsCLI",
        "ClipboardCLI",
        "NotificationsCLI",
        "IntelligenceCLI",
        "NotesCLI",
        "MailCLI",
        "MessagesCLI",
        "NumbersCLI",
        "PagesCLI",
        "KeynoteCLI",
        "FinderCLI",
        "FaceTimeCLI",
        "MapsCLI",
        "SafariCLI",
        "PhotosCLI",
        "PrintCLI",
        "TCCCLI",
        mcp,
        argumentParser,
      ],
      resources: [
        .copy("Fixtures")
      ],
      swiftSettings: notesFrameworkSwiftSettings,
      linkerSettings: notesFrameworkLinkerSettings
    ),
  ],
  swiftLanguageModes: [.v6]
)
