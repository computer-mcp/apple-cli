import AppKit
import Carbon
import Foundation
import Utility

struct KeynoteNativeSlide: Equatable, Sendable {
  var index: Int
  var skipped: Bool
  var titleShowing: Bool
  var bodyShowing: Bool
  var title: String?
  var body: String?
  var presenterNotes: String?
}

struct KeynoteNativeSnapshot: Sendable {
  var documentID: String
  var readSource: String
  var totalSlideCount: Int
  var slides: [KeynoteNativeSlide]
}

struct KeynoteNativePDFReceipt: Sendable {
  var documentID: String
  var readSource: String
  var slideCount: Int
}

struct KeynoteAppleScriptBackend: Sendable {
  private let executeScript: @Sendable (String) throws -> NSAppleEventDescriptor

  init() { executeScript = Self.runScript }

  init(executeScript: @escaping @Sendable (String) throws -> NSAppleEventDescriptor) {
    self.executeScript = executeScript
  }

  func readSlides(path: String, limit: Int) throws -> KeynoteNativeSnapshot {
    guard (1...500).contains(limit) else {
      throw CLIError(code: .validationError, message: "Keynote slide limit must be in 1...500.")
    }
    let descriptor = try executeScript(Self.slidesScript(path: path, limit: limit))
    let fields = try descriptor.keynoteList(count: 4)
    let documentID = try fields[0].keynoteRequiredText()
    let readSource = try fields[1].keynoteReadSource()
    let totalSlideCount = try fields[2].keynoteNonnegativeInt()
    let rows = try fields[3].keynoteList()
    guard rows.count == min(totalSlideCount, limit) else { throw invalidKeynoteReadback() }
    let slides = try rows.enumerated().map { offset, row in
      let values = try row.keynoteList(count: 7)
      let index = try values[0].keynoteNonnegativeInt()
      guard index == offset + 1 else { throw invalidKeynoteReadback() }
      return KeynoteNativeSlide(
        index: index,
        skipped: try values[1].keynoteBool(),
        titleShowing: try values[2].keynoteBool(),
        bodyShowing: try values[3].keynoteBool(),
        title: try values[4].keynoteOptionalText(),
        body: try values[5].keynoteOptionalText(),
        presenterNotes: try values[6].keynoteOptionalText()
      )
    }
    return KeynoteNativeSnapshot(
      documentID: documentID, readSource: readSource, totalSlideCount: totalSlideCount, slides: slides)
  }

  func exportPDF(path: String, to destinationPath: String) throws -> KeynoteNativePDFReceipt {
    let fields = try executeScript(Self.pdfScript(path: path, to: destinationPath))
      .keynoteList(count: 3)
    return KeynoteNativePDFReceipt(
      documentID: try fields[0].keynoteRequiredText(),
      readSource: try fields[1].keynoteReadSource(),
      slideCount: try fields[2].keynoteNonnegativeInt()
    )
  }

  static func slidesScript(path: String, limit: Int) -> String {
    withDocument(path: path, body: """
    set initialSlideCount to count of slides of targetDocument
    set requestedCount to initialSlideCount
    if requestedCount is greater than \(limit) then set requestedCount to \(limit)
    set slideRows to {}
    if requestedCount is greater than 0 then
      repeat with slideIndex from 1 to requestedCount
        set eachSlide to slide slideIndex of targetDocument
        set titleValue to missing value
        set bodyValue to missing value
        set titleItem to default title item of eachSlide
        set bodyItem to default body item of eachSlide
        if titleItem is not missing value then set titleValue to object text of titleItem as text
        if bodyItem is not missing value then set bodyValue to object text of bodyItem as text
        set notesValue to presenter notes of eachSlide
        if notesValue is not missing value then set notesValue to notesValue as text
        set end of slideRows to {slide number of eachSlide, skipped of eachSlide, title showing of eachSlide, body showing of eachSlide, titleValue, bodyValue, notesValue}
      end repeat
    end if
    if (id of targetDocument as text) is not equal to selectedDocumentID or (count of slides of targetDocument) is not initialSlideCount then error number -2702
    set output to {selectedDocumentID, readSource, initialSlideCount, slideRows}
    """)
  }

  static func pdfScript(path: String, to destinationPath: String) -> String {
    withDocument(path: path, body: """
    set initialSlideCount to count of slides of targetDocument
    export targetDocument to (POSIX file \(keynoteAppleScriptLiteral(destinationPath))) as PDF with properties {export style:IndividualSlides, all stages:false, skipped slides:true}
    if (id of targetDocument as text) is not equal to selectedDocumentID or (count of slides of targetDocument) is not initialSlideCount then error number -2702
    set output to {selectedDocumentID, readSource, initialSlideCount}
    """)
  }

  private static func withDocument(path: String, body: String) -> String {
    """
    with timeout of 30 seconds
      tell application "Keynote"
        set targetDocument to missing value
        set documentWasOpen to false
        set documentOwnedByOperation to false
        set existingDocumentIDs to id of every document
        try
          repeat with eachDocument in documents
            try
              set documentPath to POSIX path of (file of eachDocument as alias)
              if documentPath is equal to \(keynoteAppleScriptLiteral(path)) then
                set targetDocument to eachDocument
                set documentWasOpen to true
                exit repeat
              end if
            end try
          end repeat
          if targetDocument is missing value then
            set targetDocument to open (POSIX file \(keynoteAppleScriptLiteral(path)))
            set documentWasOpen to (id of targetDocument) is in existingDocumentIDs
          end if
          set selectedDocumentID to id of targetDocument as text
          set documentOwnedByOperation to documentWasOpen is false
          set readSource to "opened_file"
          if documentWasOpen then set readSource to "live_document"
          \(body)
          if documentOwnedByOperation then close targetDocument saving no
        on error errorMessage number errorNumber
          if targetDocument is not missing value and documentOwnedByOperation then
            try
              close targetDocument saving no
            end try
          end if
          error number errorNumber
        end try
      end tell
      return output
    end timeout
    """
  }

  private static func runScript(_ source: String) throws -> NSAppleEventDescriptor {
    var errorInfo: NSDictionary?
    guard let script = NSAppleScript(source: source) else {
      throw CLIError(code: .internalError, message: "Failed to create Keynote automation script.")
    }
    let result = script.executeAndReturnError(&errorInfo)
    if let errorInfo { throw automationError(errorInfo) }
    return result
  }

  static func automationError(_ errorInfo: NSDictionary) -> CLIError {
    let number = errorInfo[NSAppleScript.errorNumber] as? Int
    if number == -2702 {
      return CLIError(
        code: .backendUnavailable,
        message: "Keynote presentation changed during the operation. Read it again before retrying."
      )
    }
    let code: CLIErrorCode
    switch number {
    case -1712: code = .timeout
    case -1743, -1744: code = .permissionDenied
    case -1728, -43: code = .notFound
    default: code = .backendUnavailable
    }
    return CLIError.appleEventFailure(target: "Keynote", code: code, number: number)
  }
}

func keynoteAppleScriptLiteral(_ value: String) -> String {
  let escaped = value
    .replacingOccurrences(of: "\\", with: "\\\\")
    .replacingOccurrences(of: "\"", with: "\\\"")
    .replacingOccurrences(of: "\r", with: "\" & return & \"")
    .replacingOccurrences(of: "\n", with: "\" & linefeed & \"")
  return "(\"\(escaped)\")"
}

private func invalidKeynoteReadback() -> CLIError {
  CLIError(code: .backendUnavailable, message: "Keynote returned incomplete or invalid native content.")
}

private extension NSAppleEventDescriptor {
  func keynoteList(count: Int? = nil) throws -> [NSAppleEventDescriptor] {
    guard descriptorType == typeAEList,
      count == nil || numberOfItems == count
    else { throw invalidKeynoteReadback() }
    if numberOfItems == 0 { return [] }
    return try (1...numberOfItems).map { index in
      guard let value = atIndex(index) else { throw invalidKeynoteReadback() }
      return value
    }
  }

  func keynoteOptionalText() throws -> String? {
    if descriptorType == typeNull
      || (descriptorType == typeType && typeCodeValue == OSType(cMissingValue))
    { return nil }
    guard [typeUnicodeText, typeUTF8Text, typeChar, typeCString].contains(descriptorType),
      let value = stringValue
    else { throw invalidKeynoteReadback() }
    return value
  }

  func keynoteRequiredText() throws -> String {
    guard let value = try keynoteOptionalText(), !value.isEmpty else {
      throw invalidKeynoteReadback()
    }
    return value
  }

  func keynoteReadSource() throws -> String {
    let value = try keynoteRequiredText()
    guard ["opened_file", "live_document"].contains(value) else { throw invalidKeynoteReadback() }
    return value
  }

  func keynoteNonnegativeInt() throws -> Int {
    guard [typeSInt16, typeSInt32, typeSInt64, typeUInt32, typeUInt64].contains(descriptorType),
      let text = coerce(toDescriptorType: typeUnicodeText)?.stringValue,
      let value = Int(text), value >= 0
    else {
      throw invalidKeynoteReadback()
    }
    return value
  }

  func keynoteBool() throws -> Bool {
    guard [typeBoolean, typeTrue, typeFalse].contains(descriptorType) else {
      throw invalidKeynoteReadback()
    }
    return booleanValue
  }
}
