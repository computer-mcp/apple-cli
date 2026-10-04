import Foundation
import NotesCLI

struct NativeNotesBodyEvidence: Codable, Equatable {
  var inlineFormats: [String]
  var colors: [String]

  static func capture(_ structure: NotesBodyStructureRecord, note: NotesNoteDetail) throws -> Self {
    guard let body = note.body, let formats = structure.inlineFormatRuns,
      let colors = structure.colorRuns
    else { throw NativeFixtureManifest.refused("body_style_evidence_unavailable") }
    let text = (note.title + "\n" + body) as NSString
    let bodyStart = (note.title + "\n" as NSString).length
    guard structure.richTextLength == text.length,
      structure.richTextSHA256 == nativeFixtureDigest(text as String)
    else { throw NativeFixtureManifest.refused("body_style_snapshot_mismatch") }
    return try Self(inlineFormats: records(formats, text: text, bodyStart: bodyStart),
      colors: records(colors, text: text, bodyStart: bodyStart))
  }

  private static func records<Value: Encodable>(_ records: [Value], text: NSString, bodyStart: Int) throws -> [String] {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    return try records.compactMap { record -> String? in
      guard var value = try JSONSerialization.jsonObject(with: encoder.encode(record)) as? [String: Any],
        let location = value["utf16Location"] as? Int, let length = value["utf16Length"] as? Int,
        location >= 0, length > 0, location <= text.length, length <= text.length - location
      else { throw NativeFixtureManifest.refused("body_style_range_unavailable") }
      if location + length <= bodyStart { return nil }
      guard location >= bodyStart else { throw NativeFixtureManifest.refused("body_style_range_crosses_title") }
      let substring = text.substring(with: NSRange(location: location, length: length))
      guard value["textSHA256"] as? String == nativeFixtureDigest(substring),
        value["textByteCount"] as? Int == substring.utf8.count,
        value["format"] as? String != "font" || !(value["fontSHA256"] as? String ?? "").isEmpty
      else { throw NativeFixtureManifest.refused("body_style_content_mismatch") }
      value["utf16Location"] = location - bodyStart
      value["ordinal"] = 0
      let data = try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys])
      return String(decoding: data, as: UTF8.self)
    }.sorted()
  }
}
