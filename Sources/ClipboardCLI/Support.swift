import AppKit
import CryptoKit
import Darwin
import Foundation
import Utility

enum ClipboardLimits {
  static let defaultBytes = 1_048_576
  static let maximumBytes = 67_108_864
  static let defaultItems = 50
  static let maximumItems = 500
  static let maximumRepresentations = 256

  static func validate(maxBytes: Int, limit: Int = defaultItems) throws {
    guard (1...maximumBytes).contains(maxBytes), (1...maximumItems).contains(limit) else {
      throw CLIError(
        code: .validationError,
        message: "Clipboard byte and item limits are outside the supported range.",
        details: ["max_bytes": "\(maximumBytes)", "max_items": "\(maximumItems)"])
    }
  }
}

func validateReadOnly(_ options: CLIOptions) throws {
  if options.dryRun {
    throw CLIError(
      code: .validationError,
      message: "--dry-run is only valid for mutation or external-action commands.")
  }
}

func validateTargetOptions(
  _ options: CLIOptions, allowedOptions: Set<String>, allowedFlags: Set<String> = []
) throws {
  let unknownOptions = Set(options.targetOptions.keys).subtracting(allowedOptions)
  let unknownFlags = options.targetFlags.subtracting(allowedFlags)
  if !unknownOptions.isEmpty || !unknownFlags.isEmpty {
    let unsupported = (Array(unknownOptions) + Array(unknownFlags)).sorted()
    throw CLIError(
      code: .validationError,
      message: "Unsupported option for this command.",
      details: ["options": unsupported.map { "--\($0)" }.joined(separator: ",")])
  }
}

func requiredOption(_ name: String, options: CLIOptions, allowEmpty: Bool = false) throws -> String
{
  guard let value = options.targetOption(name), allowEmpty || !value.isEmpty else {
    throw CLIError(code: .validationError, message: "--\(name) is required.")
  }
  return value
}

func clipboardMaxBytes(_ options: CLIOptions) throws -> Int {
  let value: Int
  if let raw = options.targetOption("max-bytes") {
    guard let parsed = Int(raw) else {
      throw CLIError(code: .validationError, message: "--max-bytes requires an integer.")
    }
    value = parsed
  } else {
    value = ClipboardLimits.defaultBytes
  }
  try ClipboardLimits.validate(maxBytes: value)
  return value
}

func clipboardChangeCount(_ options: CLIOptions) throws -> Int? {
  guard let raw = options.targetOption("if-change-count") else { return nil }
  guard let value = Int(raw), value >= 0 else {
    throw CLIError(
      code: .validationError, message: "--if-change-count requires a nonnegative integer.")
  }
  return value
}

func validatedClipboardItems(_ items: [ClipboardItem], maxBytes: Int) throws -> [ClipboardItem] {
  try ClipboardLimits.validate(maxBytes: maxBytes)
  guard (1...ClipboardLimits.maximumItems).contains(items.count) else {
    throw CLIError(
      code: .validationError,
      message: "Clipboard replacement requires 1...500 items; use clear for an empty pasteboard.")
  }
  let filePromiseTypes = Set(NSFilePromiseReceiver.readableDraggedTypes)
  var remaining = maxBytes
  return try items.map { item in
    guard (1...ClipboardLimits.maximumRepresentations).contains(item.representations.count) else {
      throw CLIError(
        code: .validationError, message: "Each clipboard item requires 1...256 representations.")
    }
    var types = Set<String>()
    for representation in item.representations {
      guard !filePromiseTypes.contains(representation.type) else {
        throw CLIError(
          code: .unsupportedOperation,
          message:
            "File-promise metadata requires a live provider and cannot be restored as raw data.")
      }
      guard clipboardTypeSyntaxIsValid(representation.type),
        types.insert(representation.type).inserted,
        let data = representation.data
      else {
        throw CLIError(
          code: .validationError,
          message: "Clipboard representations require unique types and available base64 data.")
      }
      guard data.count <= remaining else { throw clipboardSizeError(maxBytes) }
      remaining -= data.count
    }
    return ClipboardItem(representations: item.representations)
  }
}

private func clipboardTypeSyntaxIsValid(_ type: String) -> Bool {
  let components = type.split(separator: ".", omittingEmptySubsequences: false)
  guard type.utf8.count <= 1024, components.count >= 2,
    components.allSatisfy({ !$0.isEmpty })
  else { return false }
  return type.unicodeScalars.allSatisfy { scalar in
    let value = scalar.value
    return value > 127 || (65...90).contains(value) || (97...122).contains(value)
      || (48...57).contains(value) || value == 45 || value == 46
  }
}

func clipboardSizeError(_ maxBytes: Int) -> CLIError {
  CLIError(
    code: .validationError, message: "Clipboard content exceeds --max-bytes.",
    details: ["max_bytes": "\(maxBytes)"])
}

private struct ClipboardItemsInput: Decodable {
  struct Payload: Decodable {
    var items: [ClipboardItem]
    var truncated: Bool?
    var filtered: Bool?
  }
  var payload: Payload
  private enum CodingKeys: String, CodingKey { case ok, data }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if container.contains(.data) {
      guard try container.decode(Bool.self, forKey: .ok) else {
        throw CLIError(
          code: .validationError, message: "Clipboard input must be a successful snapshot.")
      }
      payload = try container.decode(Payload.self, forKey: .data)
    } else {
      payload = try Payload(from: decoder)
    }
  }
}

func readClipboardInput(_ path: String, maxBytes: Int) throws -> [ClipboardItem] {
  try ClipboardLimits.validate(maxBytes: maxBytes)
  let expandedPath = (path as NSString).expandingTildeInPath
  let descriptor = open(expandedPath, O_RDONLY | O_NOFOLLOW | O_NONBLOCK)
  guard descriptor >= 0 else {
    throw CLIError(
      code: .validationError, message: "Clipboard input must be a readable regular JSON file.")
  }
  let handle = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
  defer { try? handle.close() }
  var metadata = stat()
  let encodedLimit = ((maxBytes + 2) / 3) * 4 + 2_097_152
  guard fstat(descriptor, &metadata) == 0, metadata.st_mode & S_IFMT == S_IFREG,
    metadata.st_size >= 0, metadata.st_size <= encodedLimit
  else {
    throw CLIError(
      code: .validationError, message: "Clipboard input is not a bounded regular JSON file.")
  }
  do {
    var input = Data()
    while let chunk = try handle.read(upToCount: min(65_536, encodedLimit + 1 - input.count)),
      !chunk.isEmpty
    {
      input.append(chunk)
      guard input.count <= encodedLimit else { throw clipboardSizeError(maxBytes) }
    }
    var after = stat()
    guard fstat(descriptor, &after) == 0, after.st_size == metadata.st_size,
      after.st_mtimespec.tv_sec == metadata.st_mtimespec.tv_sec,
      after.st_mtimespec.tv_nsec == metadata.st_mtimespec.tv_nsec
    else {
      throw CLIError(
        code: .unsafeMutationRefused, message: "Clipboard input changed while being read.")
    }
    let payload = try JSONDecoder().decode(ClipboardItemsInput.self, from: input).payload
    guard payload.truncated != true, payload.filtered != true else {
      throw CLIError(
        code: .validationError,
        message: "A truncated or filtered clipboard snapshot cannot be used as a replacement.")
    }
    return try validatedClipboardItems(payload.items, maxBytes: maxBytes)
  } catch let error as CLIError {
    throw error
  } catch {
    throw CLIError(
      code: .validationError,
      message: "Clipboard input must contain items with type and dataBase64 representations.")
  }
}

func sha256Hex(_ value: String) -> String {
  sha256Hex(Data(value.utf8))
}

func sha256Hex(_ value: Data) -> String {
  SHA256.hash(data: value).map { String(format: "%02x", $0) }.joined()
}
