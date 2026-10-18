import AppKit
import Foundation
import NotesUI
import Utility

struct NotesNativeInlineStyle {
  private let controller: ICTTTextController
  private let operation: String

  init(operation: String) throws {
    self.operation = operation
    try NotesRuntimeMethod(owner: "ICTTTextController", selector: "init", returnType: "@").require(operation: operation)
    controller = ICTTTextController()
    try NotesRuntimeMethod(owner: "ICTTTextController", selector: "styleForModelAttributes:",
      returnType: "@", argumentTypes: ["@"]).require(operation: operation, receiver: controller)
    try NotesRuntimeMethod(owner: "ICTTTextController", selector: "modelForStyleAttributes:filterAttributes:",
      returnType: "@", argumentTypes: ["@", "B"]).require(operation: operation, receiver: controller)
  }

  func presentation(_ attributes: [NSAttributedString.Key: Any]) throws -> [NSAttributedString.Key: Any] {
    try dictionary(controller.style(forModelAttributes: raw(attributes)))
  }

  func model(_ attributes: [NSAttributedString.Key: Any]) throws -> [NSAttributedString.Key: Any] {
    try dictionary(controller.model(forStyleAttributes: raw(attributes), filterAttributes: true))
  }

  private func raw(_ attributes: [NSAttributedString.Key: Any]) -> NSDictionary {
    Dictionary(uniqueKeysWithValues: attributes.map { ($0.key.rawValue, $0.value) }) as NSDictionary
  }

  private func dictionary(_ value: Any?) throws -> [NSAttributedString.Key: Any] {
    guard let attributes = value as? [String: Any] else {
      throw CLIError(code: .backendUnavailable, message: "Notes inline style conversion is unavailable.",
        details: ["operation": operation])
    }
    return Dictionary(uniqueKeysWithValues: attributes.map { (NSAttributedString.Key($0.key), $0.value) })
  }
}

func notesHasModelAttributes(_ text: NSAttributedString) -> Bool {
  var found = false
  let keys: Set<String> = ["TTStyle", "TTTimestamp", "TTHints", "ICTTFont", "TTUnderline",
    "TTStrikethrough", "TTColor", "TTEmphasis"]
  text.enumerateAttributes(in: NSRange(location: 0, length: text.length), options: []) { attributes, _, stop in
    if attributes.keys.contains(where: { keys.contains($0.rawValue) }) {
      found = true
      stop.pointee = true
    }
  }
  return found
}

func notesMergeInlineModelAttributes(
  original: [NSAttributedString.Key: Any], converted: [NSAttributedString.Key: Any], ownedKeys: [String]
) -> [NSAttributedString.Key: Any] {
  var merged = original
  for name in ownedKeys {
    let key = NSAttributedString.Key(name)
    merged[key] = converted[key]
  }
  return merged
}

func notesMutateNativeInlineAttributes(
  in text: NSMutableAttributedString, range: NSRange, ownedKeys: [String], operation: String,
  mutate: ([NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any]
) throws {
  let converter = try NotesNativeInlineStyle(operation: operation)
  var replacements: [(range: NSRange, attributes: [NSAttributedString.Key: Any])] = []
  var failure: Error?
  text.enumerateAttributes(in: range, options: []) { attributes, run, stop in
    do {
      let presentation = try converter.presentation(attributes)
      let converted = try converter.model(mutate(presentation))
      replacements.append((run, notesMergeInlineModelAttributes(
        original: attributes, converted: converted, ownedKeys: ownedKeys)))
    } catch {
      failure = error
      stop.pointee = true
    }
  }
  if let failure { throw failure }
  for replacement in replacements { text.setAttributes(replacement.attributes, range: replacement.range) }
}
