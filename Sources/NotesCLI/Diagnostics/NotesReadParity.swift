import Foundation
import Utility

struct NotesReadParityReport: Equatable, Sendable {
  var sampleLimit: Int
  var accounts: NotesParitySection
  var folders: NotesParitySection
  var notes: NotesParitySection

  var isMatching: Bool {
    accounts.matches && folders.matches && notes.matches
  }

  var mismatchedSections: [String] {
    [
      accounts.matches ? nil : accounts.name,
      folders.matches ? nil : folders.name,
      notes.matches ? nil : notes.name,
    ].compactMap { $0 }
  }
}

struct NotesParitySection: Equatable, Sendable {
  var name: String
  var privateCount: Int
  var referenceCount: Int
  var privateDigest: String
  var referenceDigest: String
  var fieldDigests: [String: NotesParityFieldDigest]
  var fieldCounts: [String: NotesParityFieldCounts]
  var matchedIDCount: Int
  var privateOnlyIDCount: Int
  var referenceOnlyIDCount: Int
  var matchedIDFieldMismatchCounts: [String: Int]
  var matchedIDFieldMismatchSamples: [String: [NotesParityMismatchSample]]
  var matchedIDDateDeltaBuckets: [String: [String: Int]]

  var matches: Bool {
    privateCount == referenceCount && privateDigest == referenceDigest
  }

  var mismatchedFields: [String] {
    fieldDigests.keys.sorted().filter { field in
      guard let digest = fieldDigests[field] else {
        return false
      }
      return digest.privateDigest != digest.referenceDigest
    }
  }
}

struct NotesParityFieldDigest: Equatable, Sendable {
  var privateDigest: String
  var referenceDigest: String
}

struct NotesParityFieldCounts: Equatable, Sendable {
  var privateNonEmptyCount: Int
  var referenceNonEmptyCount: Int
}

struct NotesParityMismatchSample: Equatable, Sendable {
  var idDigest: String
  var privateValueDigest: String
  var referenceValueDigest: String
  var privateMetadata: [String: String]
}

protocol NotesParityMetadataProviding {
  func notesParityMetadata(section: String, ids: Set<String>) throws -> [String: [String: String]]
}

struct NotesReadParityChecker {
  var implementationReader: any NotesReading
  var parityReader: any NotesReading
  var sampleLimit: Int

  init(
    implementationReader: any NotesReading,
    parityReader: any NotesReading,
    sampleLimit: Int = 1000
  ) {
    self.implementationReader = implementationReader
    self.parityReader = parityReader
    self.sampleLimit = sampleLimit
  }

  func run() throws -> NotesReadParityReport {
    let privateAccountRows = accountRows(try implementationReader.listAccounts())
    let referenceAccountRows = accountRows(try parityReader.listAccounts())
    let privateFolderRows = folderRows(try implementationReader.listFolders(account: nil, limit: sampleLimit))
    let referenceFolderRows = folderRows(try parityReader.listFolders(account: nil, limit: sampleLimit))
    let privateNoteRows = noteRows(try implementationReader.listNotes(folder: nil, limit: sampleLimit))
    let referenceNoteRows = noteRows(try parityReader.listNotes(folder: nil, limit: sampleLimit))
    let metadataProvider = implementationReader as? NotesParityMetadataProviding

    return NotesReadParityReport(
      sampleLimit: sampleLimit,
      accounts: section(
        name: "accounts",
        privateRows: privateAccountRows,
        referenceRows: referenceAccountRows,
        privateMetadata: try metadataProvider?.notesParityMetadata(
          section: "accounts",
          ids: Set(privateAccountRows.keyedFields.keys)
        ) ?? [:]
      ),
      folders: section(
        name: "folders",
        privateRows: privateFolderRows,
        referenceRows: referenceFolderRows,
        privateMetadata: try metadataProvider?.notesParityMetadata(
          section: "folders",
          ids: Set(privateFolderRows.keyedFields.keys)
        ) ?? [:]
      ),
      notes: section(
        name: "notes",
        privateRows: privateNoteRows,
        referenceRows: referenceNoteRows,
        privateMetadata: try metadataProvider?.notesParityMetadata(
          section: "notes",
          ids: Set(privateNoteRows.keyedFields.keys)
        ) ?? [:]
      )
    )
  }

  private func section(
    name: String,
    privateRows: NotesParityRows,
    referenceRows: NotesParityRows,
    privateMetadata: [String: [String: String]]
  ) -> NotesParitySection {
    let fieldNames = Set(privateRows.fields.keys).union(referenceRows.fields.keys)
    let privateIDs = Set(privateRows.keyedFields.keys)
    let referenceIDs = Set(referenceRows.keyedFields.keys)
    let matchedIDs = privateIDs.intersection(referenceIDs)
    return NotesParitySection(
      name: name,
      privateCount: privateRows.fingerprints.count,
      referenceCount: referenceRows.fingerprints.count,
      privateDigest: digest(privateRows.fingerprints),
      referenceDigest: digest(referenceRows.fingerprints),
      fieldDigests: Dictionary(
        uniqueKeysWithValues: fieldNames.sorted().map { fieldName in
          (
            fieldName,
            NotesParityFieldDigest(
              privateDigest: digest(privateRows.fields[fieldName] ?? []),
              referenceDigest: digest(referenceRows.fields[fieldName] ?? [])
            )
          )
        }),
      fieldCounts: Dictionary(
        uniqueKeysWithValues: fieldNames.sorted().map { fieldName in
          (
            fieldName,
            NotesParityFieldCounts(
              privateNonEmptyCount: privateRows.fields[fieldName, default: []]
                .filter { !$0.isEmpty }.count,
              referenceNonEmptyCount: referenceRows.fields[fieldName, default: []]
                .filter { !$0.isEmpty }.count
            )
          )
        }),
      matchedIDCount: matchedIDs.count,
      privateOnlyIDCount: privateIDs.subtracting(referenceIDs).count,
      referenceOnlyIDCount: referenceIDs.subtracting(privateIDs).count,
      matchedIDFieldMismatchCounts: Dictionary(
        uniqueKeysWithValues: fieldNames.sorted().map { fieldName in
          (
            fieldName,
            matchedIDs.filter { id in
              privateRows.keyedFields[id]?[fieldName] != referenceRows.keyedFields[id]?[fieldName]
            }.count
          )
        }),
      matchedIDFieldMismatchSamples: Dictionary(
        uniqueKeysWithValues: fieldNames.sorted().map { fieldName in
          (
            fieldName,
            mismatchSamples(
              fieldName: fieldName,
              matchedIDs: matchedIDs,
              privateRows: privateRows,
              referenceRows: referenceRows,
              privateMetadata: privateMetadata
            )
          )
        }),
      matchedIDDateDeltaBuckets: Dictionary(
        uniqueKeysWithValues: ["created", "updated"].map { fieldName in
          (
            fieldName,
            dateDeltaBuckets(
              fieldName: fieldName,
              matchedIDs: matchedIDs,
              privateRows: privateRows,
              referenceRows: referenceRows
            )
          )
        })
    )
  }

  private func accountRows(_ accounts: [NotesAccountRecord]) -> NotesParityRows {
    rows(
      accounts.map { account in
        [
          "id": account.id,
          "name": account.name,
        ]
      })
  }

  private func folderRows(_ folders: [NotesFolderRecord]) -> NotesParityRows {
    rows(
      folders.map { folder in
        [
          "id": folder.id,
          "name": folder.name,
          "account": folder.accountName,
        ]
      })
  }

  private func noteRows(_ notes: [NotesNoteSummary]) -> NotesParityRows {
    rows(
      notes.map { note in
        [
          "id": note.id,
          "title": note.title,
          "folder": note.folderName,
          "account": note.accountName,
          "created": note.createdAt.map(formatDate) ?? "",
          "updated": note.updatedAt.map(formatDate) ?? "",
        ]
      })
  }

  private func rows(_ rows: [[String: String]]) -> NotesParityRows {
    var fields: [String: [String]] = [:]
    var fingerprints: [String] = []
    var keyedFields: [String: [String: String]] = [:]

    for row in rows {
      let names = row.keys.sorted()
      let fingerprint = names.map { name in "\(name):\(row[name] ?? "")" }
      fingerprints.append(digest(fingerprint))

      for name in names {
        fields[name, default: []].append(row[name] ?? "")
      }

      if let id = nonEmpty(row["id"]) {
        keyedFields[id] = row
      }
    }

    return NotesParityRows(fingerprints: fingerprints, fields: fields, keyedFields: keyedFields)
  }

  private func digest(_ values: [String]) -> String {
    sha256Hex(values.sorted().joined(separator: "\n"))
  }

  private func dateDeltaBuckets(
    fieldName: String,
    matchedIDs: Set<String>,
    privateRows: NotesParityRows,
    referenceRows: NotesParityRows
  ) -> [String: Int] {
    var buckets: [String: Int] = [:]
    let formatter = ISO8601DateFormatter()

    for id in matchedIDs {
      guard
        let privateValue = privateRows.keyedFields[id]?[fieldName],
        let referenceValue = referenceRows.keyedFields[id]?[fieldName],
        let privateDate = formatter.date(from: privateValue),
        let referenceDate = formatter.date(from: referenceValue)
      else {
        buckets["unparsed", default: 0] += 1
        continue
      }

      buckets[dateDeltaBucket(privateDate.timeIntervalSince(referenceDate)), default: 0] += 1
    }

    return buckets
  }

  private func dateDeltaBucket(_ delta: TimeInterval) -> String {
    let absoluteDelta = abs(delta)
    let direction = delta >= 0 ? "private_later" : "reference_later"

    switch absoluteDelta {
    case 0:
      return "match"
    case ..<60:
      return "\(direction)_under_1m"
    case ..<3600:
      return "\(direction)_under_1h"
    case 28_800:
      return "\(direction)_exact_8h"
    case ..<86_400:
      return "\(direction)_under_1d"
    case ..<(86_400 * 30):
      return "\(direction)_under_30d"
    default:
      return "\(direction)_over_30d"
    }
  }

  private func mismatchSamples(
    fieldName: String,
    matchedIDs: Set<String>,
    privateRows: NotesParityRows,
    referenceRows: NotesParityRows,
    privateMetadata: [String: [String: String]]
  ) -> [NotesParityMismatchSample] {
    matchedIDs.sorted()
      .filter { id in
        privateRows.keyedFields[id]?[fieldName] != referenceRows.keyedFields[id]?[fieldName]
      }
      .prefix(3)
      .map { id in
        NotesParityMismatchSample(
          idDigest: digest(["id:\(id)"]),
          privateValueDigest: digest([privateRows.keyedFields[id]?[fieldName] ?? ""]),
          referenceValueDigest: digest([referenceRows.keyedFields[id]?[fieldName] ?? ""]),
          privateMetadata: privateMetadata[id] ?? [:]
        )
      }
  }

  private func nonEmpty(_ value: String?) -> String? {
    guard let value else {
      return nil
    }
    return value.isEmpty ? nil : value
  }
}

private struct NotesParityRows {
  var fingerprints: [String]
  var fields: [String: [String]]
  var keyedFields: [String: [String: String]]
}

func notesReadParityDoctorCheck() -> CLIDoctorCheck {
  guard notesReadParityDoctorCheckEnabled() else {
    return CLIDoctorCheck(
      name: "notes_read_parity",
      status: .notChecked,
      message:
        "Notes implementation read parity is opt-in; set APPLE_CLI_NOTES_READ_PARITY=1 to compare against the AppleScript parity reader.",
      details: [
        "enabled": "false",
        "body_output": "none",
      ]
    )
  }

  do {
    let report = try NotesReadParityChecker(
      implementationReader: NotesReader(),
      parityReader: NotesAppleScriptParityReader(),
      sampleLimit: notesReadParitySampleLimit()
    ).run()
    return notesReadParityDoctorCheck(report)
  } catch let error as CLIError {
    return CLIDoctorCheck(
      name: "notes_read_parity",
      status: doctorStatus(for: error),
      message: error.message,
      details: error.details.merging([
        "enabled": "true",
        "body_output": "none",
      ]) { current, _ in current }
    )
  } catch {
    return CLIDoctorCheck(
      name: "notes_read_parity",
      status: .backendUnavailable,
      message: "Notes read parity failed.",
      details: [
        "enabled": "true",
        "body_output": "none",
        "error": String(describing: error),
      ]
    )
  }
}

func notesReadParityDoctorCheckEnabled() -> Bool {
  ProcessInfo.processInfo.environment["APPLE_CLI_NOTES_READ_PARITY"] == "1"
}

func notesReadParitySampleLimit() -> Int {
  let value = ProcessInfo.processInfo.environment["APPLE_CLI_NOTES_READ_PARITY_LIMIT"]
    .flatMap(Int.init) ?? 1000
  return min(max(value, 1), 2000)
}

func notesReadParityDoctorCheck(_ report: NotesReadParityReport) -> CLIDoctorCheck {
  var details = [
    "enabled": "true",
    "body_output": "none",
    "sample_limit": "\(report.sampleLimit)",
    "mismatched_sections": report.mismatchedSections.joined(separator: ","),
    "accounts_private_count": "\(report.accounts.privateCount)",
    "accounts_reference_count": "\(report.accounts.referenceCount)",
    "accounts_private_digest": report.accounts.privateDigest,
    "accounts_reference_digest": report.accounts.referenceDigest,
    "accounts_mismatched_fields": report.accounts.mismatchedFields.joined(separator: ","),
    "accounts_matched_id_count": "\(report.accounts.matchedIDCount)",
    "accounts_private_only_id_count": "\(report.accounts.privateOnlyIDCount)",
    "accounts_reference_only_id_count": "\(report.accounts.referenceOnlyIDCount)",
    "folders_private_count": "\(report.folders.privateCount)",
    "folders_reference_count": "\(report.folders.referenceCount)",
    "folders_private_digest": report.folders.privateDigest,
    "folders_reference_digest": report.folders.referenceDigest,
    "folders_mismatched_fields": report.folders.mismatchedFields.joined(separator: ","),
    "folders_matched_id_count": "\(report.folders.matchedIDCount)",
    "folders_private_only_id_count": "\(report.folders.privateOnlyIDCount)",
    "folders_reference_only_id_count": "\(report.folders.referenceOnlyIDCount)",
    "notes_private_count": "\(report.notes.privateCount)",
    "notes_reference_count": "\(report.notes.referenceCount)",
    "notes_private_digest": report.notes.privateDigest,
    "notes_reference_digest": report.notes.referenceDigest,
    "notes_mismatched_fields": report.notes.mismatchedFields.joined(separator: ","),
    "notes_matched_id_count": "\(report.notes.matchedIDCount)",
    "notes_private_only_id_count": "\(report.notes.privateOnlyIDCount)",
    "notes_reference_only_id_count": "\(report.notes.referenceOnlyIDCount)",
  ]

  appendFieldDigests(for: report.accounts, to: &details)
  appendFieldDigests(for: report.folders, to: &details)
  appendFieldDigests(for: report.notes, to: &details)

  return CLIDoctorCheck(
    name: "notes_read_parity",
    status: report.isMatching ? .ok : .warning,
    message: report.isMatching
      ? "Notes implementation reads match the AppleScript parity reader for bounded metadata."
      : "Notes implementation reads differ from the AppleScript parity reader for bounded metadata.",
    details: details
  )
}

private func appendFieldDigests(
  for section: NotesParitySection,
  to details: inout [String: String]
) {
  for fieldName in section.fieldDigests.keys.sorted() {
    guard let digest = section.fieldDigests[fieldName] else {
      continue
    }
    details["\(section.name)_\(fieldName)_private_digest"] = digest.privateDigest
    details["\(section.name)_\(fieldName)_reference_digest"] = digest.referenceDigest
    if let counts = section.fieldCounts[fieldName] {
      details["\(section.name)_\(fieldName)_private_nonempty_count"] =
        "\(counts.privateNonEmptyCount)"
      details["\(section.name)_\(fieldName)_reference_nonempty_count"] =
        "\(counts.referenceNonEmptyCount)"
    }
    details["\(section.name)_\(fieldName)_matched_id_mismatch_count"] =
      "\(section.matchedIDFieldMismatchCounts[fieldName] ?? 0)"
    let samples = section.matchedIDFieldMismatchSamples[fieldName] ?? []
    if !samples.isEmpty {
      details["\(section.name)_\(fieldName)_matched_id_mismatch_samples"] =
        renderMismatchSamples(samples)
    }
    if let dateDeltaBuckets = section.matchedIDDateDeltaBuckets[fieldName], !dateDeltaBuckets.isEmpty {
      details["\(section.name)_\(fieldName)_matched_id_date_delta_buckets"] =
        renderBucketCounts(dateDeltaBuckets)
    }
  }
}

private func renderBucketCounts(_ counts: [String: Int]) -> String {
  counts.keys.sorted().map { key in "\(key):\(counts[key] ?? 0)" }.joined(separator: ",")
}

private func renderMismatchSamples(_ samples: [NotesParityMismatchSample]) -> String {
  samples.map { sample in
    var parts = [
      "id_sha256=\(sample.idDigest)",
      "private_sha256=\(sample.privateValueDigest)",
      "reference_sha256=\(sample.referenceValueDigest)",
    ]

    let metadata = sample.privateMetadata.keys.sorted().map { key in
      "\(key)=\(sample.privateMetadata[key] ?? "")"
    }.joined(separator: "|")
    if !metadata.isEmpty {
      parts.append("private_metadata=\(metadata)")
    }

    return parts.joined(separator: ";")
  }.joined(separator: ",")
}

private func doctorStatus(for error: CLIError) -> CLIDoctorStatus {
  switch error.code {
  case .permissionDenied:
    return .permissionDenied
  case .timeout:
    return .timeout
  case .unsupportedOperation:
    return .unsupportedOperation
  default:
    return .backendUnavailable
  }
}
