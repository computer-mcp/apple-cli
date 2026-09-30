import Foundation
import PhotosCLI
import Testing
import Utility

@Suite
struct PhotosHookTests {
  @Test func photosHookBackendRunsSwiftEvalWithJSONWire() throws {
    let backend = PhotosHookBackend()
    let source = """
      import Foundation

      struct Output: Codable {
        var accepted: Bool
        var values: [String: String]
        var messages: [String]
      }

      let input = FileHandle.standardInput.readDataToEndOfFile()
      let values = ["input_bytes": "\\(input.count)", "runtime": "swift-eval"]
      let output = Output(accepted: true, values: values, messages: [])
      FileHandle.standardOutput.write(try JSONEncoder().encode(output))
      """
    let hookInput = PhotoHookInput(
      category: "query",
      photos: [
        PhotosMediaItemRecord(
          id: "asset:1",
          uuid: "asset-1",
          filename: "IMG_0001.JPG"
        )
      ]
    )

    let output = try backend.runHook(
      kind: "query",
      source: source,
      input: hookInput,
      timeoutSeconds: 10,
      outputCap: 4096
    )

    #expect(output.accepted == true)
    #expect(output.values["runtime"] == "swift-eval")
    #expect(Int(output.values["input_bytes"] ?? "0") ?? 0 > 0)
  }

  @Test func photosHookBackendRejectsInvalidJSONOutput() throws {
    let backend = PhotosHookBackend()
    let source = #"print("not-json")"#
    let hookInput = PhotoHookInput(category: "query", photos: [])

    do {
      _ = try backend.runHook(
        kind: "query",
        source: source,
        input: hookInput,
        timeoutSeconds: 10,
        outputCap: 4096
      )
      Issue.record("Expected invalid hook output JSON to fail.")
    } catch {
      #expect(String(describing: error).contains("PhotoHookOutput"))
    }
  }

  @Test func photosQueryHookFiltersCandidateItemsBehindStrongGate() throws {
    let fixture = try makePhotosBackendFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())
    let source = """
      import Foundation

      struct Photo: Codable {
        var uuid: String
      }

      struct Input: Codable {
        var photos: [Photo]
      }

      struct Output: Codable {
        var accepted: Bool
        var values: [String: String]
        var messages: [String]
      }

      let input = try JSONDecoder().decode(
        Input.self,
        from: FileHandle.standardInput.readDataToEndOfFile()
      )
      let uuid = input.photos.first?.uuid ?? ""
      let output = Output(
        accepted: uuid == "asset-2",
        values: ["uuid": uuid],
        messages: []
      )
      FileHandle.standardOutput.write(try JSONEncoder().encode(output))
      """

    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "hooks", "query",
          "--library", fixture.library.path,
          "--album", "album-travel",
          "--source", source,
          "--allow-eval",
          "--timeout-seconds", "10",
          "--output-cap", "4096",
          "--dry-run",
          "--json",
        ])))

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "hooks", "query",
          "--library", fixture.library.path,
          "--album", "album-travel",
          "--source", source,
          "--allow-eval",
          "--timeout-seconds", "10",
          "--output-cap", "4096",
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let items = try #require(data?["items"] as? [[String: Any]])

    #expect(items.map { $0["uuid"] as? String } == ["asset-2"])
  }

  @Test func photosTemplateRenderUsesStrongGatedHookValues() throws {
    let fixture = try makePhotosBackendFixture()
    let command = PhotosCommand(backend: PhotosCompositeBackend())
    let source = """
      import Foundation

      struct Photo: Codable {
        var uuid: String
      }

      struct Input: Codable {
        var photos: [Photo]
      }

      struct Output: Codable {
        var accepted: Bool
        var values: [String: String]
        var messages: [String]
      }

      let input = try JSONDecoder().decode(
        Input.self,
        from: FileHandle.standardInput.readDataToEndOfFile()
      )
      let uuid = input.photos.first?.uuid ?? ""
      let output = Output(
        accepted: true,
        values: ["dynamic": "hook-\\(uuid)", "rating": "5"],
        messages: []
      )
      FileHandle.standardOutput.write(try JSONEncoder().encode(output))
      """

    #expect(throws: CLIError.self) {
      try command.run(
        options: CLIOptionsFixture.parse([
          "templates", "render",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--template", "{title}:{hook.dynamic}:{hook.rating}",
          "--source", source,
          "--dry-run",
          "--json",
        ]))
    }

    let dryRun = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "templates", "render",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--template", "{title}:{hook.dynamic}:{hook.rating}",
          "--source", source,
          "--allow-eval",
          "--timeout-seconds", "10",
          "--output-cap", "4096",
          "--dry-run",
          "--json",
        ])))
    let dryRunObject = try photosTestJSONObject(dryRun.stdout ?? "")
    let dryRunData = dryRunObject["data"] as? [String: Any]
    let summary = dryRunData?["normalizedArguments"] as? [String: Any]
    #expect(summary?["gate"] as? String == "strong-gate")
    #expect((summary?["source_sha256"] as? String)?.isEmpty == false)
    #expect((summary?["template_sha256"] as? String)?.isEmpty == false)
    #expect(summary?["timeout_seconds"] as? String == "10")
    #expect(summary?["output_cap"] as? String == "4096")

    let changed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "templates", "render",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--template", "{title}:{hook.dynamic}:{hook.rating}",
          "--source", source + "\n",
          "--allow-eval",
          "--timeout-seconds", "10",
          "--output-cap", "4096",
          "--allow-external-dispatch", "--json",
        ])))
    let changedObject = try photosTestJSONObject(changed.stdout ?? "")
    let changedData = changedObject["data"] as? [String: Any]
    #expect(changedData?["rendered"] as? [String] == ["Beach:hook-asset-1:5"])

    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "templates", "render",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--template", "{title}:{hook.dynamic}:{hook.rating}",
          "--source", source,
          "--allow-eval",
          "--timeout-seconds", "10",
          "--output-cap", "4096",
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let rendered = data?["rendered"] as? [String]
    #expect(rendered == ["Beach:hook-asset-1:5"])
  }

  @Test func photosTemplateRenderSourceFileDryRunBindsFileContents() throws {
    let fixture = try makePhotosBackendFixture()
    let sourceFile = fixture.root.appendingPathComponent("template-hook.swift")
    let originalSource = """
      import Foundation

      struct Output: Codable {
        var accepted: Bool
        var values: [String: String]
        var messages: [String]
      }

      let output = Output(
        accepted: true,
        values: ["dynamic": "file-original"],
        messages: []
      )
      FileHandle.standardOutput.write(try JSONEncoder().encode(output))
      """
    let changedSource = originalSource.replacingOccurrences(
      of: "file-original",
      with: "file-changed"
    )
    try originalSource.write(to: sourceFile, atomically: true, encoding: .utf8)

    let command = PhotosCommand(backend: PhotosCompositeBackend())
    _ = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "templates", "render",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--template", "{title}:{hook.dynamic}",
          "--source-file", sourceFile.path,
          "--allow-eval",
          "--timeout-seconds", "10",
          "--output-cap", "4096",
          "--dry-run",
          "--json",
        ])))

    try changedSource.write(to: sourceFile, atomically: true, encoding: .utf8)
    let changed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "templates", "render",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--template", "{title}:{hook.dynamic}",
          "--source-file", sourceFile.path,
          "--allow-eval",
          "--timeout-seconds", "10",
          "--output-cap", "4096",
          "--allow-external-dispatch", "--json",
        ])))
    let changedObject = try photosTestJSONObject(changed.stdout ?? "")
    let changedData = changedObject["data"] as? [String: Any]
    #expect(changedData?["rendered"] as? [String] == ["Beach:file-changed"])

    try originalSource.write(to: sourceFile, atomically: true, encoding: .utf8)
    let executed = try #require(
      try command.run(
        options: CLIOptionsFixture.parse([
          "templates", "render",
          "--library", fixture.library.path,
          "--uuid", "asset-1",
          "--template", "{title}:{hook.dynamic}",
          "--source-file", sourceFile.path,
          "--allow-eval",
          "--timeout-seconds", "10",
          "--output-cap", "4096",
          "--allow-external-dispatch", "--json",
        ])))
    let object = try photosTestJSONObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let rendered = data?["rendered"] as? [String]
    #expect(rendered == ["Beach:file-original"])
  }
}




