import Foundation
import CryptoKit
import Darwin
import Testing
import Utility

@Suite(.serialized)
struct FrameworkNormalizationTests {
  @Test(arguments: NormalizationProfile.allCases)
  func duplicateClassesMergeMembersAcrossHeaders(_ profile: NormalizationProfile) throws {
    let fixture = try NormalizationFixture(profile)
    defer { fixture.remove() }
    try fixture.header("A.h", text: "@interface FNExample : NSObject\n- (NSInteger)first;\n@end\n")
    try fixture.header("B.h", text: "@interface FNExample : NSObject\n- (NSString *)second;\n@end\n")
    let result = try fixture.run()
    #expect(result.exitCode == 0)
    let text = try fixture.outputHeader()
    #expect(text.contains("first;"))
    #expect(text.contains("second;"))
    #expect(text.components(separatedBy: "@interface FNExample :").count == 2)
  }

  @Test(arguments: NormalizationProfile.allCases)
  func conflictingReturnTypesRefuseGeneration(_ profile: NormalizationProfile) throws {
    let fixture = try NormalizationFixture(profile)
    defer { fixture.remove() }
    try fixture.header("A.h", text: "@interface FNExample : NSObject\n- (NSInteger)value;\n@end\n")
    try fixture.header("B.h", text: "@interface FNExample : NSObject\n- (double)value;\n@end\n")
    let original = try fixture.seedOutputs()
    let result = try fixture.run()
    #expect(result.exitCode != 0)
    #expect(try fixture.outputBytes() == original)
  }

  @Test(arguments: NormalizationProfile.allCases)
  func missingLaterModulePreservesEntireOutputGroup(_ profile: NormalizationProfile) throws {
    let fixture = try NormalizationFixture(profile)
    defer { fixture.remove() }
    let original = try fixture.seedOutputs()
    try FileManager.default.removeItem(at: fixture.dump.appendingPathComponent(profile.modules.last!))
    let result = try fixture.run()
    #expect(result.exitCode != 0)
    #expect(try fixture.outputBytes() == original)
  }

  @Test(arguments: NormalizationProfile.allCases)
  func manifestsMergeVersionsWithOrderIndependentObservedAvailability(_ profile: NormalizationProfile) throws {
    let fixture = try NormalizationFixture(profile)
    defer { fixture.remove() }
    try fixture.header("Variant.h", text: "@interface FNExample : NSObject\n- (NSInteger)first;\n@end\n")
    let second = fixture.root.appendingPathComponent("second")
    try FileManager.default.copyItem(at: fixture.dump, to: second)
    let module = profile.modules[0]
    try "@interface FNExample : NSObject\n- (NSInteger)first;\n- (NSString *)second;\n@end\n".write(
      to: second.appendingPathComponent("\(module)/\(module)/Variant.h"), atomically: true, encoding: .utf8)
    let manifest = try fixture.manifest([(fixture.dump, "older", "15.0"), (second, "newer", "27.0")])
    let diagnostic = fixture.root.appendingPathComponent("report.json")
    let result = try fixture.run(inputManifest: manifest, extra: ["--report", diagnostic.path])
    #expect(result.exitCode == 0)
    let text = try fixture.outputHeader()
    #expect(text.contains("first;"))
    #expect(text.contains("second;"))
    let bytes = try fixture.outputBytes()
    let report = try fixture.report(diagnostic)
    #expect(report["availability_basis"] as? String == "observed_input_presence")
    #expect(report["runtime_compatibility"] as? String == "unverified")
    let declarations = try #require(report["declarations"] as? [[String: Any]])
    let example = try #require(declarations.first { $0["identity"] as? String == "class:FNExample:" })
    let members = try #require(example["members"] as? [[String: Any]])
    let added = try #require(members.first { $0["identity"] as? String == "method:-:second" })
    #expect(added["observed_in"] as? [String] == ["newer"])
    let imports = try #require(report["import_validation"] as? [[String: Any]])
    #expect(Set(imports.compactMap { $0["module"] as? String }) == Set(profile.modules))
    let reversed = try fixture.manifest([(second, "newer", "27.0"), (fixture.dump, "older", "15.0")])
    let reversedResult = try fixture.run(inputManifest: reversed)
    #expect(reversedResult.exitCode == 0, Comment(rawValue: reversedResult.stderr))
    #expect(try fixture.outputBytes() == bytes)
  }

  @Test(arguments: NormalizationProfile.allCases)
  func manifestDigestMismatchPreservesExistingFiles(_ profile: NormalizationProfile) throws {
    let fixture = try NormalizationFixture(profile)
    defer { fixture.remove() }
    let manifest = try fixture.manifest([(fixture.dump, "source", "27.0")])
    try fixture.header("Root.h", text: "@interface FNChanged : NSObject\n@end\n")
    let before = try fixture.seedOutputs()
    #expect(try fixture.run(inputManifest: manifest).exitCode != 0)
    #expect(try fixture.outputBytes() == before)
  }

  @Test(arguments: NormalizationConflict.allCases)
  func semanticConflictsReportBothSourcesAndPreserveOutput(_ kind: NormalizationConflict) throws {
    let fixture = try NormalizationFixture(.reminders)
    defer { fixture.remove() }
    let declarations = kind.declarations
    try fixture.header("A.h", text: declarations.0)
    try fixture.header("B.h", text: declarations.1)
    let before = try fixture.seedOutputs()
    let diagnostic = fixture.root.appendingPathComponent("conflicts.json")
    let result = try fixture.run(extra: ["--report", diagnostic.path])
    #expect(result.exitCode != 0)
    #expect(try fixture.outputBytes() == before)
    let conflicts = try #require(fixture.report(diagnostic)["conflicts"] as? [[String: Any]])
    #expect(!conflicts.isEmpty)
    let variants = conflicts.compactMap { $0["variants"] as? [[String: Any]] }.flatMap { $0 }
    let origins = variants.compactMap { $0["origin"] as? [String: Any] }
    #expect(Set(origins.compactMap { $0["header"] as? String }) == ["A.h", "B.h"])
  }

  @Test func categoryAndProtocolMembersMergeWithoutDroppingOptionals() throws {
    let fixture = try NormalizationFixture(.reminders)
    defer { fixture.remove() }
    try fixture.header("A.h", text: """
      @protocol FNProtocol <NSObject>
      /* declaration
         comments */
      @optional
      - (NSInteger)first;
      @end
      @interface FNExample : NSObject
      @end
      @interface FNExample (Extras)
      /* instance methods */
      - (NSInteger)first;
      @end
      """)
    try fixture.header("B.h", text: """
      @protocol FNProtocol <NSObject>
      @required
      - (NSInteger)second;
      @end
      @interface FNExample (Extras)
      - (NSInteger)second;
      @end
      """)
    #expect(try fixture.run().exitCode == 0)
    let text = try fixture.outputHeader()
    #expect(text.contains("@optional\n- (NSInteger)first;"))
    #expect(text.contains("@required\n- (NSInteger)second;"))
    #expect(text.components(separatedBy: "@interface FNExample (Extras)").count == 2)
  }

  @Test(arguments: NormalizationProfile.allCases)
  func compilerFailurePreservesOutputAndUnrelatedFiles(_ profile: NormalizationProfile) throws {
    let fixture = try NormalizationFixture(profile)
    defer { fixture.remove() }
    let beforeHeaders = try fixture.seedOutputs()
    let unrelated = fixture.output.appendingPathComponent("OtherOwner/data.txt")
    try FileManager.default.createDirectory(at: unrelated.deletingLastPathComponent(), withIntermediateDirectories: true)
    try Data("unrelated content".utf8).write(to: unrelated)
    let before = try fixture.outputBytes()
    #expect(before.count == beforeHeaders.count + 1)
    try fixture.header("Invalid.h", text: "@interface FNExample : NSObject\n- (FNUndefinedType)value;\n@end\n")
    #expect(try fixture.run().exitCode != 0)
    #expect(try fixture.outputBytes() == before)
  }

  @Test func crossArchitectureInputsCompileWithoutClaimingRuntimeSupport() throws {
    let fixture = try NormalizationFixture(.reminders)
    defer { fixture.remove() }
    let manifest = try fixture.manifest([(fixture.dump, "source", "27.0")])
    var object = try fixture.report(manifest)
    var sources = try #require(object["inputs"] as? [[String: Any]])
    var intel = sources[0]
    intel["id"] = "intel"
    intel["architecture"] = "x86_64"
    sources.append(intel)
    object["inputs"] = sources
    try JSONSerialization.data(withJSONObject: object).write(to: manifest)
    let unrelated = fixture.output.appendingPathComponent("OtherOwner/data.txt")
    try FileManager.default.createDirectory(at: unrelated.deletingLastPathComponent(), withIntermediateDirectories: true)
    let bytes = Data("another target's content".utf8)
    try bytes.write(to: unrelated)
    let diagnostic = fixture.root.appendingPathComponent("cross-architecture.json")
    let result = try fixture.run(inputManifest: manifest, extra: ["--report", diagnostic.path])
    #expect(result.exitCode == 0, Comment(rawValue: result.stderr))
    #expect(try Data(contentsOf: unrelated) == bytes)
    let report = try fixture.report(diagnostic)
    let checks = try #require(report["import_validation"] as? [[String: Any]])
    #expect(Set(checks.compactMap { $0["architecture"] as? String }) == ["arm64", "x86_64"])
    #expect(report["runtime_compatibility"] as? String == "unverified")
  }

  @Test(arguments: NormalizationLineEnding.allCases)
  func duplicatePropertyMetadataInOneDeclarationRequiresReconciliation(_ ending: NormalizationLineEnding) throws {
    let fixture = try NormalizationFixture(.reminders)
    defer { fixture.remove() }
    let declaration = """
      @protocol FNContent
      @property (readonly, copy, nonatomic) NSString *title;
      @end
      @interface FNExample : NSObject <FNContent>
      @property (readonly, copy, nonatomic) NSString *title;
      @property (retain, nonatomic) NSString *title;
      @end
      """
    try fixture.header("Conflicting.h", text: declaration.replacingOccurrences(of: "\n", with: ending.rawValue))
    let before = try fixture.seedOutputs()
    let diagnostic = fixture.root.appendingPathComponent("conflicts.json")
    let result = try fixture.run(extra: ["--report", diagnostic.path])
    #expect(result.exitCode != 0)
    #expect(try fixture.outputBytes() == before)
    let conflicts = try #require(fixture.report(diagnostic)["conflicts"] as? [[String: Any]])
    let property = try #require(conflicts.first { $0["identity"] as? String == "class:FNExample::property:title" })
    let variants = try #require(property["variants"] as? [[String: Any]])
    let origins = variants.compactMap { $0["origin"] as? [String: Any] }
    #expect(Set(origins.compactMap { $0["header"] as? String }) == ["Conflicting.h"])
    #expect(Set(origins.compactMap { $0["line"] as? Int }) == [5, 6])
    #expect(Set(variants.compactMap { $0["signature"] as? String }).count == 2)
  }

  @Test func equivalentOwnershipAndDefaultAccessorsMerge() throws {
    let fixture = try NormalizationFixture(.reminders)
    defer { fixture.remove() }
    try fixture.header("A.h", text: """
      @interface FNExample : NSObject
      @property (strong, nonatomic) NSString *title;
      @end
      """)
    try fixture.header("B.h", text: """
      @interface FNExample : NSObject
      @property (retain, nonatomic, readwrite, getter=title, setter=setTitle:) NSString *title;
      @end
      """)
    let diagnostic = fixture.root.appendingPathComponent("report.json")
    let result = try fixture.run(extra: ["--report", diagnostic.path])
    #expect(result.exitCode == 0, Comment(rawValue: result.stderr))
    guard result.exitCode == 0 else { return }
    let header = try fixture.outputHeader()
    #expect(header.components(separatedBy: "NSString *title;").count == 2)
    let declarations = try #require(fixture.report(diagnostic)["declarations"] as? [[String: Any]])
    let example = try #require(declarations.first { $0["identity"] as? String == "class:FNExample:" })
    let members = try #require(example["members"] as? [[String: Any]])
    let title = try #require(members.first { $0["identity"] as? String == "property:title" })
    #expect((title["signatures"] as? [String])?.count == 1)
    #expect((title["origins"] as? [[String: Any]])?.count == 2)
    let variants = try #require(title["variants"] as? [[String: Any]])
    #expect(Set(variants.compactMap { $0["declaration"] as? String }) == [
      "@property (strong, nonatomic) NSString *title;",
      "@property (retain, nonatomic, readwrite, getter=title, setter=setTitle:) NSString *title;"
    ])
  }

  @Test func redundantOwnershipCannotBeHiddenByEquivalence() throws {
    let fixture = try NormalizationFixture(.reminders)
    defer { fixture.remove() }
    try fixture.header("Invalid.h", text: """
      @interface FNExample : NSObject
      @property (strong, retain, nonatomic) NSString *title;
      @end
      """)
    let before = try fixture.seedOutputs()
    let result = try fixture.run()
    #expect(result.exitCode != 0)
    #expect(result.stderr.contains("property ownership"))
    #expect(try fixture.outputBytes() == before)
  }

  @Test func erasedMethodTypeDoesNotOverrideClassPropertyMetadata() throws {
    let fixture = try NormalizationFixture(.reminders)
    defer { fixture.remove() }
    try fixture.header("Conflicting.h", text: """
      @protocol FNCollection
      @property (class, readonly, copy, nonatomic) NSArray *items;
      + (id)items;
      @end
      """)
    let before = try fixture.seedOutputs()
    let diagnostic = fixture.root.appendingPathComponent("conflicts.json")
    #expect(try fixture.run(extra: ["--report", diagnostic.path]).exitCode != 0)
    #expect(try fixture.outputBytes() == before)
    let conflicts = try #require(fixture.report(diagnostic)["conflicts"] as? [[String: Any]])
    let selector = try #require(conflicts.first { $0["identity"] as? String == "protocol:FNCollection:method:+:items" })
    let variants = try #require(selector["variants"] as? [[String: Any]])
    #expect(Set(variants.compactMap { $0["signature"] as? String }) == ["NSArray *()", "id()"])
  }

  @Test(arguments: NormalizationInputReportDestination.allCases)
  func diagnosticReportCannotReplaceInputs(_ destination: NormalizationInputReportDestination) throws {
    let fixture = try NormalizationFixture(.reminders)
    defer { fixture.remove() }
    let header = fixture.dump.appendingPathComponent("ReminderKit/ReminderKit/Root.h")
    let headerBytes = try Data(contentsOf: header)
    let manifest = try fixture.manifest([(fixture.dump, "source", "27.0")])
    let manifestBytes = try Data(contentsOf: manifest)
    let before = try fixture.seedOutputs()
    let report: URL
    switch destination {
    case .header: report = header
    case .manifest: report = manifest
    case .newFileInDump: report = fixture.dump.appendingPathComponent("diagnostic.json")
    }
    let result = try fixture.run(inputManifest: manifest, extra: ["--report", report.path])
    #expect(result.exitCode != 0)
    #expect(try fixture.outputBytes() == before)
    #expect(try Data(contentsOf: header) == headerBytes)
    #expect(try Data(contentsOf: manifest) == manifestBytes)
    if destination == .newFileInDump { #expect(!FileManager.default.fileExists(atPath: report.path)) }
  }

  @Test func namedPipeHeadersAreRefusedBeforeReading() throws {
    let fixture = try NormalizationFixture(.reminders)
    defer { fixture.remove() }
    let pipe = fixture.dump.appendingPathComponent("ReminderKit/ReminderKit/Pipe.h")
    try #require(mkfifo(pipe.path, 0o600) == 0)
    let before = try fixture.seedOutputs()
    let result = try fixture.run()
    #expect(result.exitCode != 0)
    #expect(result.stderr.contains("regular file"))
    #expect(try fixture.outputBytes() == before)
  }

  @Test(arguments: NormalizationInputLinkDestination.allCases)
  func inputLinksCannotAliasOutputOrDiagnostic(_ destination: NormalizationInputLinkDestination) throws {
    let fixture = try NormalizationFixture(.reminders)
    defer { fixture.remove() }
    _ = try fixture.seedOutputs()
    let target: URL
    switch destination {
    case .output: target = fixture.output.appendingPathComponent("SharedInput.h")
    case .diagnostic: target = fixture.root.appendingPathComponent("SharedInput.h")
    }
    let bytes = Data("@interface FNShared : NSObject\n@end\n".utf8)
    try bytes.write(to: target)
    let header = fixture.dump.appendingPathComponent("ReminderKit/ReminderKit/Root.h")
    try FileManager.default.removeItem(at: header)
    try FileManager.default.createSymbolicLink(at: header, withDestinationURL: target)
    let before = try fixture.outputBytes()
    let report = destination == .diagnostic ? target : fixture.root.appendingPathComponent("report.json")
    let result = try fixture.run(extra: ["--report", report.path])
    #expect(result.exitCode != 0)
    #expect(try fixture.outputBytes() == before)
    #expect(try Data(contentsOf: target) == bytes)
    #expect(try FileManager.default.destinationOfSymbolicLink(atPath: header.path) == target.path)
  }

  @Test(arguments: NormalizationMissingLeafScope.allCases)
  func missingLeavesThroughLinksPreserveInputAndOutputBoundaries(_ scope: NormalizationMissingLeafScope) throws {
    let fixture = try NormalizationFixture(.reminders)
    defer { fixture.remove() }
    let before = try fixture.seedOutputs()
    let alias = fixture.root.appendingPathComponent("alias")
    let target = scope == .reportInOutput ? fixture.output : fixture.dump
    try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: target)
    let leaf = alias.appendingPathComponent("Nested/missing")
    let result = scope == .outputInDump
      ? try fixture.run(sourcesRoot: leaf)
      : try fixture.run(extra: ["--report", leaf.path])
    #expect(result.exitCode != 0)
    #expect(try fixture.outputBytes() == before)
    #expect(!FileManager.default.fileExists(atPath: target.appendingPathComponent("Nested").path))
    #expect(try FileManager.default.destinationOfSymbolicLink(atPath: alias.path) == target.path)
  }

  @Test func danglingGeneratedHeaderCannotBeReplaced() throws {
    let fixture = try NormalizationFixture(.reminders)
    defer { fixture.remove() }
    _ = try fixture.seedOutputs()
    let header = fixture.output.appendingPathComponent("ReminderKit/include/ReminderKit.h")
    let destination = fixture.root.appendingPathComponent("missing.h")
    try FileManager.default.removeItem(at: header)
    try FileManager.default.createSymbolicLink(at: header, withDestinationURL: destination)
    let result = try fixture.run()
    #expect(result.exitCode != 0)
    #expect(result.stderr.contains("symbolic links"))
    #expect(try FileManager.default.destinationOfSymbolicLink(atPath: header.path) == destination.path)
    let other = fixture.output.appendingPathComponent("ReminderKitInternal/include/ReminderKitInternal.h")
    #expect(try String(contentsOf: other, encoding: .utf8) == "original ReminderKitInternal")
    #expect(!FileManager.default.fileExists(atPath: destination.path))
  }
}

enum NormalizationInputReportDestination: CaseIterable, Sendable {
  case header, manifest, newFileInDump
}

enum NormalizationLineEnding: String, CaseIterable, Sendable {
  case lf = "\n", crlf = "\r\n"
}

enum NormalizationInputLinkDestination: CaseIterable, Sendable {
  case output, diagnostic
}

enum NormalizationMissingLeafScope: CaseIterable, Sendable {
  case reportInDump, reportInOutput, outputInDump
}

enum NormalizationConflict: CaseIterable, Sendable {
  case superclass, propertyType, getter, setter, ownership, readonly, protocolRequirement, categorySelector
  var declarations: (String, String) {
    let a: String
    let b: String
    switch self {
    case .superclass:
      return ("@interface FNExample : NSObject\n@end\n", "@interface FNExample : NSOperation\n@end\n")
    case .propertyType: a = "@property (nonatomic) NSInteger value;"; b = "@property (nonatomic) double value;"
    case .getter: a = "@property (readonly, getter=first) NSInteger value;"; b = "@property (readonly, getter=second) NSInteger value;"
    case .setter: a = "@property (setter=setFirst:) NSInteger value;"; b = "@property (setter=setSecond:) NSInteger value;"
    case .ownership: a = "@property (weak) NSObject *value;"; b = "@property (strong) NSObject *value;"
    case .readonly: a = "@property (readonly) NSInteger value;"; b = "@property (readwrite) NSInteger value;"
    case .protocolRequirement:
      return ("@protocol FNProtocol\n@optional\n- (NSInteger)value;\n@end\n", "@protocol FNProtocol\n@required\n- (NSInteger)value;\n@end\n")
    case .categorySelector:
      return ("@interface FNExample : NSObject\n- (NSInteger)value;\n@end\n", "@interface FNExample (Extra)\n- (double)value;\n@end\n")
    }
    return ("@interface FNExample : NSObject\n\(a)\n@end\n", "@interface FNExample : NSObject\n\(b)\n@end\n")
  }
}

enum NormalizationProfile: String, CaseIterable, Sendable {
  case notes, reminders
  var modules: [String] {
    switch self {
    case .notes: ["NotesSupport", "NotesHTML", "NotesShared", "NotesUI", "NotesEditor", "NotesPreviewKit"]
    case .reminders: ["ReminderKit", "ReminderKitInternal"]
    }
  }
  var script: String {
    self == .notes ? "notes-private-framework-normalize-full-dump" : "reminderkit-normalize-full-dump"
  }
}

struct NormalizationFixture {
  let root: URL
  let dump: URL
  let output: URL
  let profile: NormalizationProfile

  init(_ profile: NormalizationProfile) throws {
    self.profile = profile
    self.root = FileManager.default.temporaryDirectory.appendingPathComponent("apple-framework-\(UUID().uuidString)")
    self.dump = root.appendingPathComponent("dump")
    self.output = root.appendingPathComponent("output")
    for module in profile.modules {
      let directory = dump.appendingPathComponent("\(module)/\(module)")
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      try "@interface FN\(module)Root : NSObject\n@end\n".write(
        to: directory.appendingPathComponent("Root.h"), atomically: true, encoding: .utf8)
    }
  }

  func header(_ name: String, text: String, module: String? = nil) throws {
    let module = module ?? profile.modules[0]
    try text.write(to: dump.appendingPathComponent("\(module)/\(module)/\(name)"), atomically: true, encoding: .utf8)
  }

  func run(inputManifest: URL? = nil, sourcesRoot: URL? = nil, extra: [String] = []) throws -> CLISubprocessResult {
    let repository = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
      .deletingLastPathComponent().deletingLastPathComponent()
    return try CLISubprocess.run(
      .path("/usr/bin/xcrun"),
      arguments: ["swift", repository.appendingPathComponent("Scripts/\(profile.script)").path,
        "--sources-root", (sourcesRoot ?? output).path] + (inputManifest.map { ["--input-manifest", $0.path] } ?? ["--dump-root", dump.path]) + extra,
      timeoutSeconds: 90)
  }

  func outputHeader() throws -> String {
    let module = profile.modules[0]
    return try String(contentsOf: output.appendingPathComponent("\(module)/include/\(module).h"), encoding: .utf8)
  }

  func manifest(_ inputs: [(URL, String, String)]) throws -> URL {
    var sources: [[String: Any]] = []
    for (dump, id, version) in inputs {
      var modules: [String: Any] = [:]
      for module in profile.modules {
        let directory = dump.appendingPathComponent("\(module)/\(module)")
        var hashes: [String: String] = [:]
        for file in try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        where file.pathExtension == "h" {
          hashes[file.lastPathComponent] = SHA256.hash(data: try Data(contentsOf: file))
            .map { String(format: "%02x", $0) }.joined()
        }
        modules[module] = ["presence": "present", "headers": hashes]
      }
      sources.append(["id": id, "dump_root": dump.lastPathComponent, "source_kind": "synthetic_fixture",
        "macos_version": version, "os_build": "fixture", "architecture": "arm64", "sdk_version": version,
        "app_version": "fixture", "modules": modules])
    }
    let path = root.appendingPathComponent("inputs-\(UUID().uuidString).json")
    try JSONSerialization.data(withJSONObject: ["schema_version": 1, "inputs": sources], options: [.sortedKeys])
      .write(to: path)
    return path
  }

  func report(_ path: URL) throws -> [String: Any] {
    try #require(JSONSerialization.jsonObject(with: Data(contentsOf: path)) as? [String: Any])
  }

  func seedOutputs() throws -> [String: Data] {
    for module in profile.modules {
      let directory = output.appendingPathComponent("\(module)/include")
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      try "original \(module)".write(
        to: directory.appendingPathComponent("\(module).h"), atomically: true, encoding: .utf8)
    }
    return try outputBytes()
  }

  func outputBytes() throws -> [String: Data] {
    var result: [String: Data] = [:]
    let enumerator = try #require(FileManager.default.enumerator(at: output, includingPropertiesForKeys: [.isRegularFileKey]))
    for case let file as URL in enumerator {
      if try file.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true {
        result[String(file.path.dropFirst(output.path.count + 1))] = try Data(contentsOf: file)
      }
    }
    return result
  }

  func remove() { try? FileManager.default.removeItem(at: root) }
}
