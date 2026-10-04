import AppKit
import Foundation
import Testing
import UserNotifications
import Utility

@testable import ClipboardCLI
@testable import NotificationsCLI

@Suite
struct SystemDomainCommandTests {
  @Test(
    .enabled(
      if: ProcessInfo.processInfo.environment["APPLE_CLI_RUN_CLIPBOARD_INTEGRATION_TESTS"] == "1"))
  @MainActor func clipboardNativeReplacementPreservesItemsAndVerifiesChanges() throws {
    let pasteboard = NSPasteboard.withUniqueName()
    FileHandle.standardError.write(
      Data("[clipboard-native] board=\(pasteboard.name.rawValue)\n".utf8))
    defer {
      pasteboard.clearContents()
      let empty = (pasteboard.pasteboardItems ?? []).isEmpty && (pasteboard.types ?? []).isEmpty
      #expect(empty)
      pasteboard.releaseGlobally()
      FileHandle.standardError.write(
        Data(
          "[clipboard-native] cleanup=\(pasteboard.name.rawValue) empty=\(empty) release-requested=true\n"
            .utf8))
    }
    let backend = AppKitClipboardBackend(pasteboard: pasteboard)
    let text = "apple-cli-clipboard-\(UUID().uuidString) 中文 👩🏽‍💻"
    #expect(try backend.writeText(text).changed)
    let writtenCount = pasteboard.changeCount
    #expect(try backend.writeText(text).changed == false)
    #expect(pasteboard.changeCount == writtenCount)
    #expect(throws: CLIError.self) { try backend.readString(preferredType: nil, maxBytes: 1) }

    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: directory) }
    let file = directory.appendingPathComponent("fixture.txt")
    try Data(text.utf8).write(to: file)
    let rich = NSAttributedString(
      string: text, attributes: [.font: NSFont.boldSystemFont(ofSize: 14)])
    let rtf = try rich.data(
      from: NSRange(location: 0, length: rich.length),
      documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
    let bitmap = try #require(
      NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: 2, pixelsHigh: 1, bitsPerSample: 8,
        samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
        bytesPerRow: 0, bitsPerPixel: 0))
    let pixels = try #require(bitmap.bitmapData)
    for (index, value) in [UInt8(255), 0, 0, 255, 0, 0, 255, 255].enumerated() {
      pixels[index] = value
    }
    let png = try #require(bitmap.representation(using: .png, properties: [:]))
    let payload = [
      ClipboardItem(representations: [
        ClipboardRepresentation(
          type: NSPasteboard.PasteboardType.string.rawValue, data: Data(text.utf8)),
        ClipboardRepresentation(type: NSPasteboard.PasteboardType.rtf.rawValue, data: rtf),
        ClipboardRepresentation(
          type: NSPasteboard.PasteboardType.html.rawValue, data: Data("<b>\(text)</b>".utf8)),
      ]),
      ClipboardItem(representations: [
        ClipboardRepresentation(type: NSPasteboard.PasteboardType.png.rawValue, data: png)
      ]),
      ClipboardItem(representations: [
        ClipboardRepresentation(
          type: NSPasteboard.PasteboardType.fileURL.rawValue, data: Data(file.absoluteString.utf8))
      ]),
    ]
    let change = try backend.writeItems(payload, ifChangeCount: writtenCount)
    #expect(change.changed)
    let cold = NSPasteboard(name: pasteboard.name)
    let coldItems = try #require(cold.pasteboardItems)
    #expect(coldItems.count == payload.count)
    for (actual, expected) in zip(coldItems, payload) {
      #expect(
        Set(expected.representations.map(\.type)).isSubset(of: Set(actual.types.map(\.rawValue))))
      #expect(
        actual.types.map(\.rawValue).filter(Set(expected.representations.map(\.type)).contains)
          == expected.representations.map(\.type))
      for representation in expected.representations {
        #expect(actual.data(forType: .init(rawValue: representation.type)) == representation.data)
      }
    }
    let decodedRTF = try NSAttributedString(
      data: try #require(coldItems[0].data(forType: .rtf)),
      options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
    #expect(decodedRTF.string == text)
    #expect(
      String(
        data: try #require(
          coldItems[0].data(forType: .init(rawValue: "public.utf16-external-plain-text"))),
        encoding: .utf16) == text)
    let font = try #require(decodedRTF.attribute(.font, at: 0, effectiveRange: nil) as? NSFont)
    #expect(NSFontManager.shared.traits(of: font).contains(.boldFontMask))
    #expect(
      NSImage(data: try #require(coldItems[1].data(forType: .png)))?.size
        == NSSize(width: 2, height: 1))
    let urls = try #require(
      cold.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL]
    )
    #expect(urls == [file])

    let snapshot = try backend.readItems()
    #expect(snapshot.items.map(\.ordinal) == [1, 2, 3])
    #expect(
      snapshot.items.map { $0.representations.map(\.type) }
        == coldItems.map { $0.types.map(\.rawValue) })
    #expect(snapshot.totalItems == 3 && !snapshot.truncated && !snapshot.filtered)
    #expect(
      snapshot.totalBytes
        == coldItems.reduce(0) { count, item in
          count + item.types.reduce(0) { $0 + (item.data(forType: $1)?.count ?? 0) }
        })
    #expect(try backend.writeItems(payload, ifChangeCount: snapshot.changeCount).changed == false)
    #expect(
      try backend.writeItems(snapshot.items, ifChangeCount: snapshot.changeCount).changed == false)
    #expect(cold.changeCount == change.changeCount)
    #expect(try backend.readItems(limit: 1).truncated)
    #expect(try backend.readItems(preferredType: NSPasteboard.PasteboardType.png.rawValue).filtered)
    #expect(throws: CLIError.self) { try backend.readItems(maxBytes: 1) }
    #expect(throws: CLIError.self) {
      try backend.writeText("stale", ifChangeCount: change.changeCount - 1)
    }
    #expect(cold.changeCount == change.changeCount)
    #expect(try backend.readItems() == snapshot)

    let input = directory.appendingPathComponent("snapshot.json")
    try JSONEncoder().encode(CLISuccessEnvelope(data: snapshot, meta: ["target": "clipboard"]))
      .write(to: input)
    let command = ClipboardCommand(backend: backend)
    let replayOptions = try CLIOptionsFixture.parse([
      "clipboard", "items", "write", "--input", input.path,
      "--if-change-count", "\(snapshot.changeCount)", "--allow-persistent-action", "--json",
    ])
    let replay = try jsonObject(try #require(try command.run(options: replayOptions)).stdout ?? "")
    #expect((replay["data"] as? [String: Any])?["changed"] as? Bool == false)

    for behavior in ClipboardNativeProvider.Behavior.allCases {
      let provider = ClipboardNativeProvider(board: pasteboard.name, text: text, behavior: behavior)
      let promised = NSPasteboardItem()
      let type = NSPasteboard.PasteboardType("com.computer-mcp.apple-cli.clipboard-fixture")
      #expect(promised.setDataProvider(provider, forTypes: [type]))
      pasteboard.clearContents()
      #expect(pasteboard.writeObjects([promised]))
      try withExtendedLifetime(provider) {
        switch behavior {
        case .provide:
          #expect(
            try backend.readItems().items.first?.representations.first?.data == Data(text.utf8))
        case .unavailable:
          let unavailable = try backend.readItems()
          #expect(unavailable.items.first?.representations.first?.data == nil)
          #expect(throws: CLIError.self) { try backend.writeItems(unavailable.items) }
        case .replace:
          do {
            _ = try backend.readItems()
            Issue.record("Expected changed ownership to reject a mixed snapshot.")
          } catch let error as CLIError {
            #expect(error.code == .unsafeMutationRefused)
          }
          #expect(pasteboard.string(forType: .string) == text)
        }
      }
    }

    _ = try backend.writeItems(payload)
    let altered = try #require(pasteboard.pasteboardItems?.first)
    #expect(
      altered.setData(
        try #require("different derived text".data(using: .utf16)),
        forType: .init(rawValue: "public.utf16-external-plain-text")))
    #expect(try backend.writeItems(payload).changed)
    let beforeHostOnly = pasteboard.changeCount
    let hostOnly = try backend.writeItems(payload, currentHostOnly: true)
    #expect(hostOnly.changed && hostOnly.changeCount != beforeHostOnly)
    #expect(pasteboard.string(forType: .string) == text)
    let repeatedHostOnly = try backend.writeItems(payload, currentHostOnly: true)
    #expect(repeatedHostOnly.changed && repeatedHostOnly.changeCount != hostOnly.changeCount)
    #expect(try backend.writeItems(payload).changed == false)
    let hostTextOptions = try CLIOptionsFixture.parse([
      "clipboard", "write", "--text", text, "--current-host-only", "--allow-persistent-action",
      "--json",
    ])
    let hostText = try jsonObject(
      try #require(try command.run(options: hostTextOptions)).stdout ?? "")
    #expect((hostText["data"] as? [String: Any])?["changed"] as? Bool == true)
    #expect(pasteboard.string(forType: .string) == text)
    #expect(try backend.writeText("").changed)
    #expect(try backend.readString(preferredType: nil).item?.value == "")
    #expect(try backend.clear().changed)
    let clearedCount = pasteboard.changeCount
    #expect(try backend.clear().changed == false)
    #expect(pasteboard.changeCount == clearedCount)
  }

  @Test(
    arguments: [
      #"{"items":[]}"#,
      #"{"items":[{"representations":[{"type":"invalid type","dataBase64":"aA=="}]}]}"#,
      #"{"items":[{"representations":[{"type":"abc","dataBase64":"aA=="}]}]}"#,
      #"{"items":[{"representations":[{"type":"com.example_bad.type","dataBase64":"aA=="}]}]}"#,
      #"{"items":[{"representations":[]}]}"#,
      #"{"items":[{"representations":[{"type":"public.utf8-plain-text","dataBase64":"***"}]}]}"#,
      #"{"items":[{"representations":[{"type":"public.utf8-plain-text"}]}]}"#,
      #"{"items":[{"representations":[{"type":"public.utf8-plain-text","dataBase64":"aA=="},{"type":"public.utf8-plain-text","dataBase64":"aQ=="}]}]}"#,
      #"{"items":[{"representations":[{"type":"public.utf8-plain-text","dataBase64":"aGVsbG8="}]}],"truncated":true}"#,
      #"{"items":[{"representations":[{"type":"public.utf8-plain-text","dataBase64":"aGVsbG8="}]}],"filtered":true}"#,
      #"{"items":[{"representations":[{"type":"public.utf8-plain-text","dataBase64":"aGVsbG8="}]}]}"#,
    ].map { ($0, CLIErrorCode.validationError) }
      + NSFilePromiseReceiver.readableDraggedTypes.map { type in
        (
          "{\"items\":[{\"representations\":[{\"type\":\"\(type)\",\"dataBase64\":\"eA==\"}]}]}",
          CLIErrorCode.unsupportedOperation
        )
      })
  func clipboardReplacementRejectsInvalidOrPartialInputBeforeMutation(
    input: String, expectedCode: CLIErrorCode
  ) throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: directory) }
    let file = directory.appendingPathComponent("input.json")
    try Data(input.utf8).write(to: file)
    let backend = FakeClipboardBackend(text: "preserved")
    let command = ClipboardCommand(backend: backend)
    let options = try CLIOptionsFixture.parse([
      "clipboard", "items", "write", "--input", file.path, "--max-bytes", "4",
      "--allow-persistent-action", "--json",
    ])
    do {
      _ = try command.run(options: options)
      Issue.record("Expected invalid clipboard replacement to fail.")
    } catch let error as CLIError {
      #expect(error.code == expectedCode)
    }
    #expect(backend.currentText() == "preserved")
    #expect(try backend.types().changeCount == 1)
  }

  @Test func clipboardTypesReturnsJSONWithoutContent() throws {
    let backend = FakeClipboardBackend(text: "secret")
    let command = ClipboardCommand(backend: backend)
    let options = try CLIOptionsFixture.parse(["clipboard", "types", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(object["ok"] as? Bool == true)
    #expect(data?["types"] as? [String] == ["public.utf8-plain-text"])
    #expect(result.stderr == nil)
  }

  @Test func clipboardReadKeepsSensitiveContentInStdoutResultOnly() throws {
    let backend = FakeClipboardBackend(text: "private clipboard value")
    let command = ClipboardCommand(backend: backend)
    let options = try CLIOptionsFixture.parse(["clipboard", "read", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let item = data?["item"] as? [String: Any]

    #expect(data?["sensitive"] as? Bool == true)
    #expect(item?["value"] as? String == "private clipboard value")
    #expect(result.stderr == nil)
  }

  @Test func clipboardWriteRequiresAllowPersistentAction() throws {
    let command = ClipboardCommand(backend: FakeClipboardBackend(text: "old"))
    let options = try CLIOptionsFixture.parse(["clipboard", "write", "--text", "new", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected clipboard write execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func clipboardWriteDryRunAndAllowFlagExecutesWrite() throws {
    let backend = FakeClipboardBackend(text: "old")
    let command = ClipboardCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "clipboard",
      "write",
      "--text",
      "new",
      "--current-host-only",
      "--dry-run",
      "--json",
    ])

    let preview = try jsonObject(try #require(try command.run(options: dryRunOptions)).stdout ?? "")
    let previewData = preview["data"] as? [String: Any]
    #expect(
      (previewData?["normalizedArguments"] as? [String: String])?["current_host_only"] == "true")
    #expect(backend.currentText() == "old")

    let executeOptions = try CLIOptionsFixture.parse([
      "clipboard",
      "write",
      "--text",
      "new",
      "--current-host-only",
      "--allow-persistent-action",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let object = try jsonObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["changed"] as? Bool == true)
    #expect(backend.currentText() == "new")
    #expect(backend.usedCurrentHostOnly())
  }

  @Test func clipboardClearAllowExecutionClearsCurrentState() throws {
    let backend = FakeClipboardBackend(text: "old")
    let command = ClipboardCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse(["clipboard", "clear", "--dry-run", "--json"])
    _ = try #require(try command.run(options: dryRunOptions))

    _ = try backend.writeText("changed before execution")

    let executeOptions = try CLIOptionsFixture.parse([
      "clipboard",
      "clear",
      "--allow-persistent-action",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(backend.currentText() == "")
  }

  @Test func notificationPreviewReturnsJSONWithoutExternalAction() throws {
    let command = NotificationsCommand(backend: FakeNotificationBackend())
    let options = try CLIOptionsFixture.parse([
      "notifications",
      "preview",
      "--title",
      "Build",
      "--body",
      "Done",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let notification = data?["notification"] as? [String: Any]

    #expect(data?["externalAction"] as? Bool == false)
    #expect(notification?["title"] as? String == "Build")
    #expect(notification?["body"] as? String == "Done")
  }

  @Test func notificationSendRequiresAllowExternalDispatch() throws {
    let command = NotificationsCommand(backend: FakeNotificationBackend())
    let options = try CLIOptionsFixture.parse([
      "notifications",
      "send",
      "--title",
      "Build",
      "--body",
      "Done",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected notification send execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func notificationSendDryRunAndAllowFlagExecutesSend() throws {
    let backend = FakeNotificationBackend()
    let command = NotificationsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "notifications",
      "send",
      "--title",
      "Build",
      "--body",
      "Done",
      "--id",
      "stable-request",
      "--delay-seconds",
      "600",
      "--dry-run",
      "--json",
    ])

    let preview = try jsonObject(try #require(try command.run(options: dryRunOptions)).stdout ?? "")
    let arguments = (preview["data"] as? [String: Any])?["normalizedArguments"] as? [String: String]
    #expect(arguments?["identifier"] == "apple-cli:stable-request")
    #expect(arguments?["delay_seconds"] == "600")
    #expect(backend.sentRequests().isEmpty)

    let executeOptions = try CLIOptionsFixture.parse([
      "notifications",
      "send",
      "--title",
      "Build",
      "--body",
      "Done",
      "--id",
      "stable-request",
      "--delay-seconds",
      "600",
      "--allow-external-dispatch",
      "--json",
    ])

    let executed = try #require(try command.run(options: executeOptions))
    let object = try jsonObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["submitted"] as? Bool == true)
    #expect(data?["identifier"] as? String == "apple-cli:stable-request")
    #expect(
      backend.sentRequests() == [
        LocalNotificationRequest(
          title: "Build", body: "Done", identifier: "apple-cli:stable-request", delaySeconds: 600)
      ])
  }

  @Test func notificationCallbackPreservesNativeErrorsAndUnknownTimeout() throws {
    let native = NSError(domain: UNErrorDomain, code: UNError.Code.notificationsNotAllowed.rawValue)
    let mapped = notificationNativeError(native, phase: "add", identifier: "apple-cli:owned")
    #expect(mapped.code == .permissionDenied)
    #expect(mapped.details["error_domain"] == UNErrorDomain)
    #expect(mapped.details["identifier"] == "apple-cli:owned")
    #expect(!mapped.details.keys.contains("mutation_may_have_occurred"))
    let accepted: String = try notificationCallback(phase: "add") { finish in
      finish(.success("accepted"))
      finish(.failure(mapped))
    }
    #expect(accepted == "accepted")
    do {
      let _: Bool = try notificationCallback(
        phase: "add", identifier: "apple-cli:owned", mutation: true, timeoutSeconds: 0
      ) { _ in }
      Issue.record("Expected an unknown notification submission result.")
    } catch let error as CLIError {
      #expect(error.code == .timeout)
      #expect(error.details["mutation_may_have_occurred"] == "true")
      #expect(error.details["identifier"] == "apple-cli:owned")
    }
  }

  @Test func notificationAllowExecutionSendsCurrentPayload() throws {
    let backend = FakeNotificationBackend()
    let command = NotificationsCommand(backend: backend)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "notifications",
      "send",
      "--title",
      "Build",
      "--body",
      "Done",
      "--dry-run",
      "--json",
    ])
    _ = try #require(try command.run(options: dryRunOptions))

    let executeOptions = try CLIOptionsFixture.parse([
      "notifications",
      "send",
      "--title",
      "Build",
      "--body",
      "Changed",
      "--allow-external-dispatch",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(backend.sentRequests() == [LocalNotificationRequest(title: "Build", body: "Changed")])
  }

  @Test func notificationNativeRecordsPreserveContentTriggersAndNamespace() throws {
    let content = UNMutableNotificationContent()
    content.title = "Build 😀"
    content.body = "  Done e\u{301}\n\n"
    content.subtitle = "Result"
    let interval = UNNotificationRequest(
      identifier: "apple-cli:z", content: content,
      trigger: UNTimeIntervalNotificationTrigger(timeInterval: 600, repeats: false))
    let plain = UNNotificationRequest(identifier: "apple-cli:a", content: content, trigger: nil)
    let foreign = UNNotificationRequest(identifier: "foreign", content: content, trigger: nil)
    let records = notificationRecords([interval, foreign, plain])
    #expect(records.map(\.identifier) == ["apple-cli:a", "apple-cli:z"])
    let observed = try #require(records.last)
    #expect(observed.title == content.title)
    #expect(observed.body.utf8.elementsEqual(content.body.utf8))
    #expect(observed.subtitle == content.subtitle)
    #expect(observed.trigger?.kind == "timeInterval")
    #expect(observed.trigger?.timeIntervalSeconds == 600)
    #expect(observed.trigger?.repeats == false)
    #expect(records.first?.trigger == nil)
    let rawID = String(repeating: "x", count: 490)
    let normalizedID = try notificationIdentifier(rawID)
    #expect(normalizedID.utf8.count == 500)
    #expect(try notificationIdentifier(normalizedID) == normalizedID)
    #expect(throws: CLIError.self) { try notificationIdentifier(rawID + "x") }

    var components = DateComponents()
    components.calendar = Calendar(identifier: .gregorian)
    components.timeZone = TimeZone(secondsFromGMT: 0)
    components.hour = 14
    components.minute = 30
    let calendar = UNNotificationRequest(
      identifier: "apple-cli:calendar", content: content,
      trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true))
    let deliveredAt = Date(timeIntervalSince1970: 1_700_000_000)
    let projected = notificationRecord(calendar, deliveredAt: deliveredAt)
    #expect(projected.trigger?.kind == "calendar")
    #expect(projected.trigger?.repeats == true)
    #expect(projected.trigger?.dateComponents == components)
    #expect(projected.deliveredAt == deliveredAt)
  }

  @Test func notificationManagementUsesExactIDsAndSeparatesCollections() throws {
    let pending = NotificationRecord(
      identifier: "apple-cli:shared", title: "Waiting", body: "Pending body", subtitle: "")
    let delivered = NotificationRecord(
      identifier: "apple-cli:shared", title: "Delivered", body: "Delivered body", subtitle: "",
      deliveredAt: Date(timeIntervalSince1970: 1_700_000_000))
    let backend = FakeNotificationBackend(
      records: [
        .pending: [
          pending,
          NotificationRecord(
            identifier: "apple-cli:z-other", title: "Second", body: "Other", subtitle: ""),
        ],
        .delivered: [delivered],
      ],
      removals: [
        .pending: NotificationRemovalResult(
          operation: "notifications.pending.cancel", identifier: pending.identifier,
          attempted: true, wasPresent: true, verifiedAbsent: true),
        .delivered: NotificationRemovalResult(
          operation: "notifications.delivered.remove", identifier: delivered.identifier,
          attempted: true, wasPresent: true, verifiedAbsent: true),
      ])
    let command = NotificationsCommand(backend: backend)
    for collection in NotificationCollection.allCases {
      let path = ["notifications", collection.rawValue]
      let list = try jsonObject(
        try #require(
          try command.run(
            options: CLIOptionsFixture.parse(
              path + ["list", "--limit", "1", "--json"]))
        ).stdout ?? "")
      let listData = try #require(list["data"] as? [String: Any])
      let summaries = try #require(listData["notifications"] as? [[String: Any]])
      #expect(summaries.count == 1)
      #expect(summaries.first?["identifier"] as? String == "apple-cli:shared")
      #expect(summaries.first?["body"] == nil)
      #expect(listData["totalCount"] as? Int == (collection == .pending ? 2 : 1))
      #expect(listData["truncated"] as? Bool == (collection == .pending))
      let read = try jsonObject(
        try #require(
          try command.run(
            options: CLIOptionsFixture.parse(
              path + ["read", "--id", "shared", "--json"]))
        ).stdout ?? "")
      let record = (read["data"] as? [String: Any])?["notification"] as? [String: Any]
      #expect(
        record?["body"] as? String == (collection == .pending ? pending.body : delivered.body))
      do {
        _ = try command.run(options: CLIOptionsFixture.parse(path + ["read", "--id", "missing"]))
        Issue.record("Expected a missing notification to be reported.")
      } catch let error as CLIError { #expect(error.code == .notFound) }
      do {
        _ = try command.run(options: CLIOptionsFixture.parse(path + ["list", "--limit", "501"]))
        Issue.record("Expected an invalid notification limit to be rejected.")
      } catch let error as CLIError { #expect(error.code == .validationError) }
      let action = collection == .pending ? "cancel" : "remove"
      let removalPath = path + [action, "--id", "shared", "--json"]
      let count = backend.removalCalls().count
      let preview = try jsonObject(
        try #require(
          try command.run(
            options: CLIOptionsFixture.parse(
              removalPath + ["--dry-run"]))
        ).stdout ?? "")
      let summary = (preview["data"] as? [String: Any])?["normalizedArguments"] as? [String: String]
      #expect(summary?["identifier"] == "apple-cli:shared")
      #expect(backend.removalCalls().count == count)
      do {
        _ = try command.run(options: CLIOptionsFixture.parse(removalPath))
        Issue.record("Expected notification removal to require explicit authorization.")
      } catch let error as CLIError { #expect(error.code == .unsafeMutationRefused) }
      #expect(backend.removalCalls().count == count)
      let result = try jsonObject(
        try #require(
          try command.run(
            options: CLIOptionsFixture.parse(
              removalPath + ["--allow-persistent-action"]))
        ).stdout ?? "")
      let removal = try #require(result["data"] as? [String: Any])
      #expect(removal["verifiedAbsent"] as? Bool == true)
      #expect(backend.removalCalls().last == "\(collection.rawValue):apple-cli:shared")
    }
  }
}

private final class FakeClipboardBackend: ClipboardAccessing, @unchecked Sendable {
  private let lock = NSLock()
  private var items: [ClipboardItem]
  private var changeCount = 1
  private var lastCurrentHostOnly = false

  init(text: String) {
    items = [
      ClipboardItem(representations: [
        ClipboardRepresentation(
          type: NSPasteboard.PasteboardType.string.rawValue, data: Data(text.utf8))
      ])
    ]
  }

  func types() throws -> ClipboardTypesResponse {
    lock.withLock {
      ClipboardTypesResponse(
        types: Array(Set(items.flatMap(\.representations).map(\.type))).sorted(),
        changeCount: changeCount)
    }
  }

  func readString(preferredType: String?, maxBytes: Int) throws -> ClipboardReadResponse {
    lock.withLock {
      let type = preferredType ?? NSPasteboard.PasteboardType.string.rawValue
      let strings = items.compactMap { item in
        item.representations.first { $0.type == type }?.data.flatMap {
          String(data: $0, encoding: .utf8)
        }
      }
      return ClipboardReadResponse(
        item: strings.isEmpty
          ? nil : ClipboardReadItem(type: type, value: strings.joined(separator: "\n")),
        changeCount: changeCount)
    }
  }

  func readItems(preferredType: String?, limit: Int, maxBytes: Int) throws -> ClipboardItemsResponse
  {
    throw CLIError(
      code: .internalError, message: "Item reads are not configured in this test stub.")
  }

  func writeText(
    _ text: String, ifChangeCount: Int? = nil, maxBytes: Int = 1_048_576,
    currentHostOnly: Bool = false
  ) throws -> ClipboardChange {
    try writeItems(
      [
        ClipboardItem(representations: [
          ClipboardRepresentation(
            type: NSPasteboard.PasteboardType.string.rawValue, data: Data(text.utf8))
        ])
      ], ifChangeCount: ifChangeCount, maxBytes: maxBytes, currentHostOnly: currentHostOnly)
  }

  func writeItems(
    _ items: [ClipboardItem], ifChangeCount: Int?, maxBytes: Int, currentHostOnly: Bool
  ) throws -> ClipboardChange {
    try lock.withLock {
      try checkChangeCount(ifChangeCount)
      lastCurrentHostOnly = currentHostOnly
      let changed = self.items != items
      if changed {
        self.items = items
        changeCount += 1
      }
      return ClipboardChange(changed: changed, changeCount: changeCount)
    }
  }

  func usedCurrentHostOnly() -> Bool {
    lock.withLock { lastCurrentHostOnly }
  }

  func clear(ifChangeCount: Int? = nil) throws -> ClipboardChange {
    try lock.withLock {
      try checkChangeCount(ifChangeCount)
      let changed = !items.isEmpty
      if changed {
        items = []
        changeCount += 1
      }
      return ClipboardChange(changed: changed, changeCount: changeCount)
    }
  }

  func currentText() -> String {
    lock.withLock {
      items.first?.representations.first?.data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
    }
  }

  private func checkChangeCount(_ requested: Int?) throws {
    if let requested, requested != changeCount {
      throw CLIError(code: .unsafeMutationRefused, message: "Clipboard changed.")
    }
  }
}

private final class ClipboardNativeProvider: NSObject, NSPasteboardItemDataProvider {
  enum Behavior: CaseIterable { case provide, unavailable, replace }
  private let board: NSPasteboard.Name
  private let text: String
  private let behavior: Behavior

  init(board: NSPasteboard.Name, text: String, behavior: Behavior) {
    self.board = board
    self.text = text
    self.behavior = behavior
  }

  func pasteboard(
    _ pasteboard: NSPasteboard?, item: NSPasteboardItem,
    provideDataForType type: NSPasteboard.PasteboardType
  ) {
    switch behavior {
    case .provide:
      item.setData(Data(text.utf8), forType: type)
    case .unavailable:
      break
    case .replace:
      let destination = NSPasteboard(name: board)
      destination.clearContents()
      destination.setString(text, forType: .string)
    }
  }
}

private final class FakeNotificationBackend: NotificationDelivering, @unchecked Sendable {
  private let lock = NSLock()
  private var sent: [LocalNotificationRequest] = []
  private let records: [NotificationCollection: [NotificationRecord]]
  private let removals: [NotificationCollection: NotificationRemovalResult]
  private var removed: [String] = []

  init(
    records: [NotificationCollection: [NotificationRecord]] = [:],
    removals: [NotificationCollection: NotificationRemovalResult] = [:]
  ) {
    self.records = records
    self.removals = removals
  }

  func send(_ request: LocalNotificationRequest) throws -> NotificationSubmission {
    lock.lock()
    sent.append(request)
    lock.unlock()
    return NotificationSubmission(
      identifier: request.identifier ?? "apple-cli:\(UUID().uuidString)", submitted: true)
  }

  func settings() throws -> NotificationSettingsRecord {
    throw CLIError(
      code: .internalError, message: "Notification settings are not configured in this test stub.")
  }

  func requestAuthorization() throws -> NotificationAuthorizationResult {
    throw CLIError(
      code: .internalError,
      message: "Notification authorization is not configured in this test stub.")
  }

  func sentRequests() -> [LocalNotificationRequest] {
    lock.withLock { sent }
  }

  func requests(in collection: NotificationCollection) throws -> [NotificationRecord] {
    guard let result = records[collection] else {
      throw CLIError(
        code: .internalError,
        message: "Notification collection is not configured in this test stub.")
    }
    return result
  }

  func remove(identifier: String, from collection: NotificationCollection) throws
    -> NotificationRemovalResult
  {
    guard let result = removals[collection] else {
      throw CLIError(
        code: .internalError, message: "Notification removal is not configured in this test stub.")
    }
    lock.withLock { removed.append("\(collection.rawValue):\(identifier)") }
    return result
  }

  func removalCalls() -> [String] { lock.withLock { removed } }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw SystemDomainCommandTestError.notObject
  }
  return object
}

private enum SystemDomainCommandTestError: Error {
  case notObject
}
