import Foundation
import Utility

public struct NotesCommand: Sendable {
  let implementation: any NotesReading & NotesMutating
  let sqliteReader: SQLiteReader
  let printDispatcher: any NotesPrintDispatching
  let pagesDispatcher: any NotesPagesDispatching
  let clipboardWriter: any NotesClipboardWriting
  let recognizedTextGenerator: any NotesAttachmentRecognizedTextGenerating
  let target = "notes"

  public init(
    implementation: (any NotesReading & NotesMutating)? = nil,
    sqliteReader: SQLiteReader = SQLiteReader(),
    printDispatcher: any NotesPrintDispatching = NotesCUPSPrintDispatcher(),
    pagesDispatcher: any NotesPagesDispatching = NotesPagesOpenDispatcher(),
    clipboardWriter: any NotesClipboardWriting = NotesAppKitClipboardWriter(),
    recognizedTextGenerator: any NotesAttachmentRecognizedTextGenerating =
      NotesVisionAttachmentRecognizedTextGenerator()
  ) {
    self.implementation = implementation ?? makeDefaultNotesImplementation()
    self.sqliteReader = sqliteReader
    self.printDispatcher = printDispatcher
    self.pagesDispatcher = pagesDispatcher
    self.clipboardWriter = clipboardWriter
    self.recognizedTextGenerator = recognizedTextGenerator
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals.first {
    case "doctor":
      return try runDoctor(options: options)
    case "accounts":
      return try runAccounts(options: options)
    case "folders":
      return try runFolders(options: options)
    case "smart-folders":
      return try runSmartFolders(options: options)
    case "tags":
      return try runTags(options: options)
    case "attachments":
      return try runAttachments(options: options)
    case "links":
      return try runLinks(options: options)
    case "body":
      return try runBodyFormatting(options: options)
    case "state":
      return try runState(options: options)
    case "settings":
      return try runSettings(options: options)
    case "notes":
      switch options.positionals.dropFirst().first {
      case "guide", "workflow":
        return try runWorkflowAudits(options: options)
      case "list", "search", "index", "semantic-search", "read":
        return try runReadSearch(options: options)
      case "quick-note", "create", "update", "append", "move", "copy", "restore", "restore-all",
        "delete", "purge", "empty-trash", "pin", "unpin", "batch":
        return try runLifecycle(options: options)
      case "import", "replace", "export", "print", "open-in-pages", "open-pages":
        return try runImportExport(options: options)
      default:
        break
      }
    default:
      break
    }
    return nil
  }
}
