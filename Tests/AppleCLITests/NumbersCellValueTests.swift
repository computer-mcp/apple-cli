import AppKit
import Carbon
import Foundation
import Testing
import Utility
@testable import NumbersCLI

@Suite
struct NumbersCellValueTests {
  @Test func cellKeepsDisplayValueActualValueAndFormulaSeparate() throws {
    let backend = NumbersAppleScriptContentBackend { _ in
      numbersCellResult(
        display: NSAppleEventDescriptor(string: "$125.00"),
        raw: NSAppleEventDescriptor(double: 125),
        formula: NSAppleEventDescriptor(string: "=120+5"))
    }
    let cell = try #require(try backend.readCell(
      path: "/fixture.numbers", sheet: "Sheet", table: "Table", row: 2, column: 2))

    #expect(cell.value == "$125.00")
    #expect(cell.rawValue == "125.0")
    #expect(cell.valueType == .number)
    #expect(cell.formula == "=120+5")
  }

  @Test func cellPreservesTextWithoutInferringNumberOrBooleanTypes() throws {
    for text in ["125", "false", "中文😀", "1,25"] {
      let backend = NumbersAppleScriptContentBackend { _ in
        numbersCellResult(
          display: NSAppleEventDescriptor(string: text), raw: NSAppleEventDescriptor(string: text),
          formula: NSAppleEventDescriptor(typeCode: OSType(cMissingValue)))
      }
      let cell = try #require(try backend.readCell(
        path: "/fixture.numbers", sheet: "Sheet", table: "Table", row: 2, column: 2))

      #expect(cell.rawValue == text)
      #expect(cell.valueType == .text)
      #expect(cell.formula == "")
    }
  }

  @Test func cellPreservesBooleanDateAndEmptyValueTypes() throws {
    let date = Date(timeIntervalSince1970: 1_609_556_645)
    let cases: [(NSAppleEventDescriptor, NumbersCellValueType, String?)] = [
      (NSAppleEventDescriptor(boolean: false), .boolean, "false"),
      (NSAppleEventDescriptor(date: date), .date, "2021-01-02T03:04:05Z"),
      (NSAppleEventDescriptor(typeCode: OSType(cMissingValue)), .empty, nil),
      (NSAppleEventDescriptor(int32: 2_147_483_647), .number, "2147483647"),
    ]
    for (raw, kind, value) in cases {
      let cell = try numbersCellRecord(try #require(numbersCellResult(
        display: NSAppleEventDescriptor(string: "Display"), raw: raw,
        formula: NSAppleEventDescriptor(typeCode: OSType(cMissingValue))).atIndex(1)))

      #expect(cell.valueType == kind)
      #expect(cell.rawValue == value)
      #expect(cell.formula == "")
    }
  }

  @Test func cellRejectsUnsupportedAndIncompleteValueSchemas() throws {
    let unknown = NSAppleEventDescriptor.list()
    let incomplete = NSAppleEventDescriptor.list()
    incomplete.insert(NSAppleEventDescriptor(string: "Sheet"), at: 1)
    for row in [
      try #require(numbersCellResult(
        display: NSAppleEventDescriptor(string: "125"), raw: unknown,
        formula: NSAppleEventDescriptor(typeCode: OSType(cMissingValue))).atIndex(1)),
      incomplete,
    ] {
      do {
        _ = try numbersCellRecord(row)
        Issue.record("Unproven cell data must fail.")
      } catch let error as CLIError {
        #expect(error.code == .backendUnavailable)
      }
    }
  }

  @Test func cellDistinguishesKnownEmptyFromUnavailableMetadata() throws {
    let unavailable = NumbersCellRecord(
      sheetName: "Sheet", tableName: "Table", row: 1, column: 1,
      rowCount: 1, columnCount: 1, value: "")
    let json = try CLIJSON.encodeString(unavailable)
    let object = try #require(JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: Any])

    #expect(object["rawValue"] == nil)
    #expect(object["valueType"] == nil)
    #expect(object["formula"] == nil)
    #expect(!unavailable.matchesLiteralText(""))
  }

  @Test(.enabled(if: ProcessInfo.processInfo.environment["APPLE_CLI_VALIDATE_IWORK_SDEF"] == "1"))
  func numbersCellScriptsCompileAgainstInstalledDictionary() throws {
    let reader = NumbersAppleScriptContentBackend { source in
      try compileNumbersScript(source)
      return NSAppleEventDescriptor.list()
    }
    let writer = NumbersAppleScriptContentBackend { source in
      try compileNumbersScript(source)
      let output = NSAppleEventDescriptor.list()
      let row = NSAppleEventDescriptor.list()
      row.insert(NSAppleEventDescriptor(string: "ok"), at: 1)
      output.insert(row, at: 1)
      return output
    }
    #expect(try reader.readCell(
      path: "/fixture.numbers", sheet: "Sheet", table: "Table", row: 2, column: 2) == nil)
    #expect(try reader.listSheets(path: "/fixture.numbers") == [])
    #expect(try reader.readTable(
      path: "/fixture.numbers", sheet: "Sheet", table: "Table", limit: 10) == nil)
    try writer.setCellText(
      path: "/fixture.numbers", sheet: "Sheet", table: "Table", row: 2, column: 2, value: "中文😀")
  }
}

private func compileNumbersScript(_ source: String) throws {
  let script = try #require(NSAppleScript(source: source))
  var errorInfo: NSDictionary?
  #expect(script.compileAndReturnError(&errorInfo))
  #expect(errorInfo == nil)
}

private func numbersCellResult(
  display: NSAppleEventDescriptor, raw: NSAppleEventDescriptor, formula: NSAppleEventDescriptor
) -> NSAppleEventDescriptor {
  let row = NSAppleEventDescriptor.list()
  let fields = [
    NSAppleEventDescriptor(string: "Sheet"), NSAppleEventDescriptor(string: "Table"),
    NSAppleEventDescriptor(string: "10"), NSAppleEventDescriptor(string: "10"),
    NSAppleEventDescriptor(string: "2"), NSAppleEventDescriptor(string: "2"),
    display, raw, formula,
  ]
  for (index, field) in fields.enumerated() { row.insert(field, at: index + 1) }
  let output = NSAppleEventDescriptor.list()
  output.insert(row, at: 1)
  return output
}
