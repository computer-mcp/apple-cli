import AppKit
import Foundation
import Utility

public struct AppKitClipboardBackend: ClipboardAccessing {
  private let pasteboardName: String

  public init() {
    pasteboardName = NSPasteboard.Name.general.rawValue
  }

  public init(pasteboard: NSPasteboard) {
    pasteboardName = pasteboard.name.rawValue
  }

  private var pasteboard: NSPasteboard {
    NSPasteboard(name: .init(rawValue: pasteboardName))
  }

  public func types() throws -> ClipboardTypesResponse {
    let pasteboard = self.pasteboard
    let count = pasteboard.changeCount
    let types = (pasteboard.types ?? []).map(\.rawValue).sorted()
    try ensureOwnership(pasteboard, count: count)
    return ClipboardTypesResponse(types: types, changeCount: count)
  }

  public func readString(
    preferredType: String?, maxBytes: Int = 1_048_576
  ) throws -> ClipboardReadResponse {
    try ClipboardLimits.validate(maxBytes: maxBytes)
    let pasteboard = self.pasteboard
    try requireReadAccess(pasteboard)
    let count = pasteboard.changeCount
    let type = preferredType.map(NSPasteboard.PasteboardType.init(rawValue:)) ?? .string
    let declared = (pasteboard.types ?? []).contains(type)
    let value = pasteboard.string(forType: type)
    try ensureOwnership(pasteboard, count: count)
    guard let value else {
      guard !declared else {
        throw CLIError(
          code: .backendUnavailable, message: "The declared clipboard text is unavailable.")
      }
      return ClipboardReadResponse(item: nil, changeCount: count)
    }
    guard value.utf8.count <= maxBytes else { throw clipboardSizeError(maxBytes) }
    return ClipboardReadResponse(
      item: ClipboardReadItem(type: type.rawValue, value: value), changeCount: count)
  }

  public func readItems(
    preferredType: String? = nil, limit: Int = 50, maxBytes: Int = 1_048_576
  ) throws -> ClipboardItemsResponse {
    try ClipboardLimits.validate(maxBytes: maxBytes, limit: limit)
    let pasteboard = self.pasteboard
    try requireReadAccess(pasteboard)
    let count = pasteboard.changeCount
    let native = try nativeItems(pasteboard, count: count)
    let selected = native.enumerated().filter { _, item in
      preferredType.map { requested in item.types.contains { $0.rawValue == requested } } ?? true
    }
    var totalBytes = 0
    var items: [ClipboardItem] = []
    for (index, item) in selected.prefix(limit) {
      let types = item.types.filter { preferredType == nil || $0.rawValue == preferredType }
      guard types.count <= ClipboardLimits.maximumRepresentations,
        types.allSatisfy({ $0.rawValue.utf8.count <= 1024 })
      else {
        throw CLIError(
          code: .unsupportedOperation,
          message: "Clipboard representation metadata exceeds the supported bound.")
      }
      var representations: [ClipboardRepresentation] = []
      for type in types {
        let data = item.data(forType: type)
        try ensureOwnership(pasteboard, count: count)
        if let data {
          guard data.count <= maxBytes - totalBytes else { throw clipboardSizeError(maxBytes) }
          totalBytes += data.count
        }
        representations.append(ClipboardRepresentation(type: type.rawValue, data: data))
      }
      items.append(ClipboardItem(representations: representations, ordinal: index + 1))
    }
    try ensureOwnership(pasteboard, count: count)
    return ClipboardItemsResponse(
      items: items, changeCount: count, totalItems: native.count, totalBytes: totalBytes,
      truncated: selected.count > limit, filtered: preferredType != nil)
  }

  public func writeText(
    _ text: String, ifChangeCount: Int? = nil, maxBytes: Int = 1_048_576,
    currentHostOnly: Bool = false
  ) throws -> ClipboardChange {
    try writeItems(
      [
        ClipboardItem(representations: [
          ClipboardRepresentation(
            type: NSPasteboard.PasteboardType.string.rawValue, data: Data(text.utf8))
        ])
      ],
      ifChangeCount: ifChangeCount, maxBytes: maxBytes, currentHostOnly: currentHostOnly)
  }

  public func writeItems(
    _ items: [ClipboardItem], ifChangeCount: Int? = nil, maxBytes: Int = 1_048_576,
    currentHostOnly: Bool = false
  ) throws -> ClipboardChange {
    let items = try validatedClipboardItems(items, maxBytes: maxBytes)
    let prepared = try prepareClipboardItems(items)
    let pasteboard = self.pasteboard
    let before = pasteboard.changeCount
    try requireChangeCount(ifChangeCount, actual: before)
    // Contents options have no public getter. An explicit restriction needs a new ownership claim.
    if !currentHostOnly {
      let current = try nativeItems(pasteboard, count: before)
      if try matches(current, items: items, pasteboard: pasteboard, count: before) {
        return ClipboardChange(changed: false, changeCount: before)
      }
    }
    try ensureOwnership(pasteboard, count: before)
    let claimed = pasteboard.prepareForNewContents(with: currentHostOnly ? .currentHostOnly : [])
    try ensureOwnership(pasteboard, count: claimed, mutation: true)
    guard pasteboard.writeObjects(prepared) else {
      throw mutationFailure("write")
    }
    try ensureOwnership(pasteboard, count: claimed, mutation: true)
    let cold = self.pasteboard
    let readBack = try nativeItems(cold, count: claimed, mutation: true)
    guard
      try matches(
        readBack, items: items, pasteboard: cold, count: claimed, mutation: true,
        allowGeneratedRepresentations: true)
    else {
      throw mutationFailure("readback")
    }
    return ClipboardChange(changed: true, changeCount: claimed)
  }

  public func clear(ifChangeCount: Int? = nil) throws -> ClipboardChange {
    let pasteboard = self.pasteboard
    let before = pasteboard.changeCount
    try requireChangeCount(ifChangeCount, actual: before)
    if try nativeItems(pasteboard, count: before).isEmpty {
      return ClipboardChange(changed: false, changeCount: before)
    }
    try ensureOwnership(pasteboard, count: before)
    let claimed = pasteboard.clearContents()
    let cold = self.pasteboard
    guard try nativeItems(cold, count: claimed, mutation: true).isEmpty else {
      throw mutationFailure("clear_readback")
    }
    return ClipboardChange(changed: true, changeCount: claimed)
  }

  private func nativeItems(
    _ pasteboard: NSPasteboard, count: Int, mutation: Bool = false
  ) throws -> [NSPasteboardItem] {
    let items = pasteboard.pasteboardItems
    let types = pasteboard.types ?? []
    try ensureOwnership(pasteboard, count: count, mutation: mutation)
    guard let items else {
      guard types.isEmpty else {
        if mutation { throw mutationFailure("items_readback") }
        throw CLIError(
          code: .backendUnavailable, message: "Clipboard items could not be retrieved.")
      }
      return []
    }
    return items
  }

  private func matches(
    _ native: [NSPasteboardItem], items: [ClipboardItem], pasteboard: NSPasteboard,
    count: Int, mutation: Bool = false, allowGeneratedRepresentations: Bool = false
  ) throws -> Bool {
    try ensureOwnership(pasteboard, count: count, mutation: mutation)
    guard native.count == items.count else { return false }
    for (actual, expected) in zip(native, items) {
      let actualTypes = Set(actual.types.map(\.rawValue))
      let expectedTypes = Set(expected.representations.map(\.type))
      try ensureOwnership(pasteboard, count: count, mutation: mutation)
      guard expectedTypes.isSubset(of: actualTypes) else { return false }
      guard
        actual.types.map(\.rawValue).filter(expectedTypes.contains)
          == expected.representations.map(\.type)
      else { return false }
      let additionalTypes = actualTypes.subtracting(expectedTypes)
      if !additionalTypes.isEmpty && !allowGeneratedRepresentations {
        guard
          try matchesDerivedRTFText(
            actual, expected: expected, types: additionalTypes, pasteboard: pasteboard, count: count
          )
        else { return false }
      }
      for representation in expected.representations {
        let data = actual.data(forType: .init(rawValue: representation.type))
        try ensureOwnership(pasteboard, count: count, mutation: mutation)
        guard data == representation.data else { return false }
      }
    }
    try ensureOwnership(pasteboard, count: count, mutation: mutation)
    return true
  }

  private func matchesDerivedRTFText(
    _ actual: NSPasteboardItem, expected: ClipboardItem, types: Set<String>,
    pasteboard: NSPasteboard, count: Int
  ) throws -> Bool {
    let utf16Type = "public.utf16-external-plain-text"
    let textTypes: Set<String> = [NSPasteboard.PasteboardType.string.rawValue, utf16Type]
    guard types.isSubset(of: textTypes),
      let rtf = expected.representations.first(where: {
        $0.type == NSPasteboard.PasteboardType.rtf.rawValue
      })?.data,
      let text = NSAttributedString(rtf: rtf, documentAttributes: nil)?.string
    else { return false }
    // RTF writers gain native plain-text representations. They are redundant only if the text agrees.
    for type in types {
      let data = actual.data(forType: .init(rawValue: type))
      try ensureOwnership(pasteboard, count: count)
      guard let data,
        let derived = String(data: data, encoding: type == utf16Type ? .utf16 : .utf8),
        derived.utf16.elementsEqual(text.utf16)
      else { return false }
    }
    return true
  }

  private func requireChangeCount(_ requested: Int?, actual: Int) throws {
    if let requested, requested != actual {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: "Clipboard change count does not match --if-change-count.",
        details: ["expected_change_count": "\(requested)", "actual_change_count": "\(actual)"])
    }
  }

  private func requireReadAccess(_ pasteboard: NSPasteboard) throws {
    if #available(macOS 15.4, *), pasteboard.name == .general,
      pasteboard.accessBehavior == .alwaysDeny
    {
      throw CLIError(
        code: .permissionDenied,
        message:
          "macOS denies programmatic clipboard reads for this app. Check Paste from Other Apps in System Settings."
      )
    }
  }

  private func ensureOwnership(_ pasteboard: NSPasteboard, count: Int, mutation: Bool = false)
    throws
  {
    guard pasteboard.changeCount == count else {
      if mutation { throw mutationFailure("ownership_changed") }
      throw CLIError(
        code: .unsafeMutationRefused, message: "Clipboard ownership changed during the operation.")
    }
  }

  private func mutationFailure(_ phase: String) -> CLIError {
    // Restoring an old snapshot could overwrite a new owner's clipboard.
    CLIError(
      code: .backendUnavailable,
      message:
        "Clipboard replacement could not be verified; reread the current state before retrying.",
      details: ["phase": phase, "mutation_may_have_occurred": "true"])
  }
}

func prepareClipboardItems(_ items: [ClipboardItem]) throws -> [NSPasteboardItem] {
  // Only fresh, unbound items may be passed to writeObjects.
  try items.map { item in
    let native = NSPasteboardItem()
    for representation in item.representations {
      let type = NSPasteboard.PasteboardType(rawValue: representation.type)
      guard let data = representation.data, native.setData(data, forType: type),
        native.data(forType: type) == data
      else {
        throw CLIError(
          code: .validationError,
          message: "AppKit rejected a clipboard representation before replacement.")
      }
    }
    guard native.types.map(\.rawValue) == item.representations.map(\.type) else {
      throw CLIError(
        code: .validationError,
        message: "AppKit changed the clipboard representation types before replacement.")
    }
    return native
  }
}
