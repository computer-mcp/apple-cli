import Foundation
import PrintCLI
import Testing
import Utility

@Suite
struct PrintCommandTests {
  @Test func printPrintersListReturnsJSON() throws {
    let command = PrintCommand(backend: FakePrintBackend())
    let options = try CLIOptionsFixture.parse(["printers", "list", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let printers = data?["printers"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(printers?.first?["name"] as? String == "Office_Printer")
  }

  @Test func printPrinterReadMissingReturnsNotFound() throws {
    let command = PrintCommand(backend: FakePrintBackend())
    let options = try CLIOptionsFixture.parse(["printers", "read", "--name", "Missing", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected missing printer to throw.")
    } catch let error as CLIError {
      #expect(error.code == .notFound)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func printJobsListReturnsJSON() throws {
    let command = PrintCommand(backend: FakePrintBackend())
    let options = try CLIOptionsFixture.parse([
      "jobs", "list", "--printer", "Office_Printer", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let jobs = data?["jobs"] as? [[String: Any]]

    #expect(jobs?.first?["id"] as? String == "Office_Printer-42")
    #expect(jobs?.first?["printerName"] as? String == "Office_Printer")
  }

  @Test func printReadOnlyCommandsRejectDryRuns() throws {
    let command = PrintCommand(backend: FakePrintBackend())
    let options = try CLIOptionsFixture.parse([
      "jobs",
      "list",
      "--dry-run",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected read-only print command to reject dry-run.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func printSubmitRequiresExternalDispatchAllowFlag() throws {
    let file = try temporaryPrintFile(name: "Report.pdf")
    defer { try? FileManager.default.removeItem(at: file.deletingLastPathComponent()) }

    let command = PrintCommand(backend: FakePrintBackend(), actions: FakePrintActions())
    let options = try CLIOptionsFixture.parse([
      "jobs",
      "submit",
      "--printer",
      "Office_Printer",
      "--file",
      file.path,
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected print submit without allow flag to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func printSubmitDryRunPreviewsAndAllowFlagExecutes() throws {
    let file = try temporaryPrintFile(name: "Report.pdf")
    defer { try? FileManager.default.removeItem(at: file.deletingLastPathComponent()) }

    let actions = FakePrintActions()
    let command = PrintCommand(backend: FakePrintBackend(), actions: actions)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "jobs",
      "submit",
      "--printer",
      "Office_Printer",
      "--file",
      file.path,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let requirements = data?["requirements"] as? [String: Any]

    #expect(data?["mode"] as? String == "dry-run")
    #expect(data?["operation"] as? String == "print.submit")
    #expect(requirements?["allowFlags"] as? [String] == ["--allow-external-dispatch"])
    #expect(actions.submittedFiles.isEmpty)

    let executeOptions = try CLIOptionsFixture.parse([
      "jobs",
      "submit",
      "--printer",
      "Office_Printer",
      "--file",
      file.path,
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["jobID"] as? String == "Office_Printer-77")
    #expect(actions.submittedFiles == [file.path])
    #expect(actions.submittedPrinters == ["Office_Printer"])
  }

  @Test func printSubmitAllowFlagExecutesCurrentFileSelection() throws {
    let first = try temporaryPrintFile(name: "First.pdf")
    let second = first.deletingLastPathComponent().appendingPathComponent("Second.pdf")
    try Data("second".utf8).write(to: second)
    defer { try? FileManager.default.removeItem(at: first.deletingLastPathComponent()) }

    let actions = FakePrintActions()
    let command = PrintCommand(backend: FakePrintBackend(), actions: actions)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "jobs",
      "submit",
      "--printer",
      "Office_Printer",
      "--file",
      first.path,
      "--dry-run",
      "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    #expect(data?["mode"] as? String == "dry-run")

    let changedOptions = try CLIOptionsFixture.parse([
      "jobs",
      "submit",
      "--printer",
      "Office_Printer",
      "--file",
      second.path,
      "--allow-external-dispatch",
      "--json",
    ])

    let changed = try #require(try command.run(options: changedOptions))
    let changedObject = try jsonObject(changed.stdout ?? "")
    let changedData = changedObject["data"] as? [String: Any]

    #expect(changedData?["jobID"] as? String == "Office_Printer-77")
    #expect(actions.submittedFiles == [second.path])
  }

  @Test func printCancelRequiresExternalDispatchAllowFlag() throws {
    let command = PrintCommand(backend: FakePrintBackend(), actions: FakePrintActions())
    let options = try CLIOptionsFixture.parse([
      "jobs", "cancel", "--id", "Office_Printer-42", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected print cancel without allow flag to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func printCancelDryRunPreviewsAndAllowFlagExecutes() throws {
    let actions = FakePrintActions()
    let command = PrintCommand(backend: FakePrintBackend(), actions: actions)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "jobs", "cancel", "--id", "Office_Printer-42", "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    let requirements = data?["requirements"] as? [String: Any]

    #expect(data?["mode"] as? String == "dry-run")
    #expect(data?["operation"] as? String == "print.cancel")
    #expect(requirements?["allowFlags"] as? [String] == ["--allow-external-dispatch"])
    #expect(actions.cancelledJobIDs.isEmpty)

    let executeOptions = try CLIOptionsFixture.parse([
      "jobs",
      "cancel",
      "--id",
      "Office_Printer-42",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let executedObject = try jsonObject(executed.stdout ?? "")
    let executedData = executedObject["data"] as? [String: Any]

    #expect(executedData?["submitted"] as? Bool == true)
    #expect(actions.cancelledJobIDs == ["Office_Printer-42"])
  }

  @Test func printCancelAllowFlagExecutesCurrentJobSelection() throws {
    let actions = FakePrintActions()
    let command = PrintCommand(backend: FakePrintBackend(), actions: actions)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "jobs", "cancel", "--id", "Office_Printer-42", "--dry-run", "--json",
    ])

    let dryRun = try #require(try command.run(options: dryRunOptions))
    let dryRunObject = try jsonObject(dryRun.stdout ?? "")
    let data = dryRunObject["data"] as? [String: Any]
    #expect(data?["mode"] as? String == "dry-run")

    let changedOptions = try CLIOptionsFixture.parse([
      "jobs",
      "cancel",
      "--id",
      "Office_Printer-43",
      "--allow-external-dispatch",
      "--json",
    ])

    let changed = try #require(try command.run(options: changedOptions))
    let changedObject = try jsonObject(changed.stdout ?? "")
    let changedData = changedObject["data"] as? [String: Any]

    #expect(changedData?["submitted"] as? Bool == true)
    #expect(actions.cancelledJobIDs == ["Office_Printer-43"])
  }

  @Test func cupsBackendParsesPrintersAndJobs() throws {
    let backend = CUPSPrintBackend(runner: FakeCUPSRunner())

    let printers = try backend.listPrinters(limit: 10)
    let jobs = try backend.listJobs(printer: nil, limit: 10)

    #expect(printers.count == 2)
    #expect(printers.first?.name == "Label_Printer")
    #expect(printers.first?.deviceURI == "usb://label")
    #expect(printers.last?.isDefault == true)
    #expect(jobs.first?.id == "Office_Printer-42")
    #expect(jobs.first?.sizeBytes == 2048)
  }

  @Test func cupsPrintActionsParseSubmitAndCancelOutputs() throws {
    let runner = FakeCUPSActionRunner()
    let actions = CUPSPrintActions(runner: runner)

    let jobID = try actions.submit(filePath: "/tmp/Report.pdf", printerName: "Office_Printer")
    let cancelled = try actions.cancel(jobID: "Office_Printer-77")

    #expect(jobID == "Office_Printer-77")
    #expect(cancelled == true)
  }
}

private struct FakePrintBackend: PrintReading {
  func listPrinters(limit: Int) throws -> [PrinterRecord] {
    printers().prefix(limit).map { $0 }
  }

  func readPrinter(name: String) throws -> PrinterRecord? {
    printers().first { $0.name == name }
  }

  func listJobs(printer: String?, limit: Int) throws -> [PrintJobRecord] {
    [
      PrintJobRecord(
        id: "Office_Printer-42",
        printerName: "Office_Printer",
        owner: "ada",
        sizeBytes: 2048,
        submittedAtText: "Mon May 11 15:00:00 2026"
      ),
      PrintJobRecord(
        id: "Office_Printer-43",
        printerName: "Office_Printer",
        owner: "ada",
        sizeBytes: 1024,
        submittedAtText: "Mon May 11 15:01:00 2026"
      ),
    ]
    .filter { printer == nil || $0.printerName == printer }
    .prefix(limit)
    .map { $0 }
  }

  private func printers() -> [PrinterRecord] {
    [
      PrinterRecord(
        name: "Office_Printer",
        state: "idle",
        isEnabled: true,
        isDefault: true,
        deviceURI: "ipp://office"
      )
    ]
  }
}

private final class FakePrintActions: PrintActing, @unchecked Sendable {
  var submittedFiles: [String] = []
  var submittedPrinters: [String] = []
  var cancelledJobIDs: [String] = []

  func submit(filePath: String, printerName: String) throws -> String {
    submittedFiles.append(filePath)
    submittedPrinters.append(printerName)
    return "\(printerName)-77"
  }

  func cancel(jobID: String) throws -> Bool {
    cancelledJobIDs.append(jobID)
    return true
  }
}

private struct FakeCUPSRunner: CUPSCommandRunning {
  func runLPStat(arguments: [String]) throws -> String {
    switch arguments {
    case ["-p"]:
      return """
        printer Office_Printer is idle. enabled since Mon May 11 15:00:00 2026
        printer Label_Printer is disabled. disabled since Mon May 11 14:00:00 2026
        """
    case ["-v"]:
      return """
        device for Office_Printer: ipp://office
        device for Label_Printer: usb://label
        """
    case ["-d"]:
      return "system default destination: Office_Printer\n"
    case ["-o"], ["-o", "Office_Printer"]:
      return "Office_Printer-42 ada 2048 Mon May 11 15:00:00 2026\n"
    default:
      return ""
    }
  }
}

private struct FakeCUPSActionRunner: CUPSActionCommandRunning {
  func runLP(arguments: [String]) throws -> String {
    #expect(arguments == ["-d", "Office_Printer", "/tmp/Report.pdf"])
    return "request id is Office_Printer-77 (1 file(s))\n"
  }

  func runCancel(arguments: [String]) throws -> String {
    #expect(arguments == ["Office_Printer-77"])
    return ""
  }
}

private func temporaryPrintFile(name: String) throws -> URL {
  let root = FileManager.default.temporaryDirectory
    .appendingPathComponent("apple-cli-print-tests")
    .appendingPathComponent(UUID().uuidString, isDirectory: true)
  try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
  let file = root.appendingPathComponent(name)
  try Data("print fixture".utf8).write(to: file)
  return file
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw PrintCommandTestError.notObject
  }
  return object
}

private enum PrintCommandTestError: Error {
  case notObject
}
