import Foundation
import Testing
import Utility

@testable import NotesCLI

@Suite
struct NotesAppleScriptParityReaderTests {
  @Test func notesAppleScriptParityReaderIsReadOnly() {
    let implementation: any NotesReading = NotesAppleScriptParityReader()

    #expect((implementation as Any) is any NotesMutating == false)
  }

  @Test func notesAppleScriptRunnerWrapsScriptsInTimeout() {
    let script = appleScriptWithTimeout("return 1", seconds: 30)

    #expect(script.contains("with timeout of 30 seconds"))
    #expect(script.contains("return 1"))
    #expect(script.contains("end timeout"))
  }

  @Test func notesAppleScriptErrorMappingRecognizesAutomationPermissionDenied() {
    let error = automationError(
      [
        NSAppleScript.errorMessage: "Not authorized to send Apple events to Notes.",
        NSAppleScript.errorNumber: -1743,
      ]
    )

    #expect(error.code == .permissionDenied)
    #expect(error.details["apple_event_error"] == "-1743")
  }

  @Test func notesAppleScriptErrorMappingRecognizesTimeout() {
    let error = automationError(
      [
        NSAppleScript.errorMessage: "Apple event timed out.",
        NSAppleScript.errorNumber: -1712,
      ]
    )

    #expect(error.code == .timeout)
    #expect(error.details["apple_event_error"] == "-1712")
  }

  @Test func notesAppleScriptDateParserAcceptsLocalizedChineseDate() throws {
    let date = try #require(parseAppleScriptDate("2023年4月9日 星期日 下午4:48:41"))
    let components = Calendar(identifier: .gregorian).dateComponents(
      in: TimeZone.current,
      from: date
    )

    #expect(components.year == 2023)
    #expect(components.month == 4)
    #expect(components.day == 9)
    #expect(components.hour == 16)
    #expect(components.minute == 48)
    #expect(components.second == 41)
  }

  @Test func notesAppleScriptDateParserAcceptsFlexibleChineseDayPeriods() throws {
    let earlyMorning = try #require(parseAppleScriptDate("2026年6月19日 星期五 凌晨3:16:44"))
    let evening = try #require(parseAppleScriptDate("2026年6月19日 星期五 晚上8:16:44"))
    let calendar = Calendar(identifier: .gregorian)
    let earlyMorningComponents = calendar.dateComponents(in: TimeZone.current, from: earlyMorning)
    let eveningComponents = calendar.dateComponents(in: TimeZone.current, from: evening)

    #expect(earlyMorningComponents.hour == 3)
    #expect(eveningComponents.hour == 20)
  }
}
