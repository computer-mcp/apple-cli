import Foundation
import Utility

extension MapsCommand {
  func runCollectionMutation(_ options: CLIOptions) throws -> CLICommandResult? {
    guard
      [
        ["collections", "create"], ["collections", "update"], ["collections", "delete"],
        ["collections", "places", "create"],
        ["collections", "places", "add"], ["collections", "places", "remove"],
      ].contains(options.positionals)
    else { return nil }
    guard options.limit == nil else {
      throw CLIError(code: .validationError, message: "`--limit` is only valid for list commands.")
    }
    let operation: String
    var summary: [String: String]
    let commit: () throws -> MapsCollectionMutationResult
    switch options.positionals {
    case ["collections", "create"]:
      try validateTargetOptions(
        options, allowedOptions: ["id", "title", "description", "position"])
      let title = try requiredOption("title", options: options)
      try validateCollectionTitle(title)
      let id =
        try options.targetOption("id").map { try savedIdentifier($0, kind: .collection) } ?? UUID()
      try requireCustomCollection(id)
      let draft = MapsCollectionDraft(
        id: id, title: title, description: options.targetOption("description"),
        position: try collectionPosition(options))
      operation = "collections.create"
      summary = [
        "id": MapsSavedKind.collection.idPrefix + id.uuidString.lowercased(), "title": title,
      ]
      if let description = draft.description { summary["description"] = description }
      if let position = draft.position { summary["position"] = String(position) }
      commit = { try collectionWriter.createCollection(draft) }
    case ["collections", "update"]:
      try validateTargetOptions(
        options, allowedOptions: ["id", "title", "description", "position"],
        allowedFlags: ["clear-description"])
      let patch = MapsCollectionPatch(
        title: options.targetOption("title"),
        description: options.targetOption("description"),
        clearDescription: options.hasTargetFlag("clear-description"),
        position: try collectionPosition(options))
      try validateCollectionPatch(patch)
      let id = try savedIdentifier(options, kind: .collection)
      try requireCustomCollection(id)
      let current = try collections.readCollection(id: id)
      operation = "collections.update"
      summary = [
        "id": current.id, "before_sha256": sha256Hex(try CLIJSON.encodeString(current)),
        "patch_sha256": sha256Hex(try CLIJSON.encodeString(patch.applying(to: current))),
      ]
      commit = { try collectionWriter.updateCollection(current: current, patch: patch) }
    case ["collections", "delete"]:
      try validateTargetOptions(options, allowedOptions: ["id"])
      let id = try savedIdentifier(options, kind: .collection)
      try requireCustomCollection(id)
      let current = try collections.readCollection(id: id)
      operation = "collections.delete"
      summary = ["id": current.id, "before_sha256": sha256Hex(try CLIJSON.encodeString(current))]
      commit = { try collectionWriter.deleteCollection(current: current) }
    case ["collections", "places", "create"]:
      try validateTargetOptions(
        options, allowedOptions: ["id", "item", "place", "latitude", "longitude", "name", "note"])
      let collectionID = try savedIdentifier(options, kind: .collection)
      let itemID =
        try options.targetOption("item").map {
          try savedIdentifier($0, kind: .collectionItem, option: "item")
        } ?? UUID()
      let draft = MapsCollectionPlaceDraft(
        id: itemID, source: try collectionPlaceSource(options),
        customName: options.targetOption("name"), note: options.targetOption("note"))
      try validateCollectionPlaceDraft(draft)
      let current = try collections.readCollection(id: collectionID)
      operation = "collections.places.create"
      summary = [
        "id": current.id,
        "item": MapsSavedKind.collectionItem.idPrefix + itemID.uuidString.lowercased(),
        "before_sha256": sha256Hex(try CLIJSON.encodeString(current)),
      ]
      switch draft.source {
      case .identifier(let id): summary["place"] = "maps-item:" + id
      case .coordinate(let latitude, let longitude):
        summary["latitude"] = String(latitude)
        summary["longitude"] = String(longitude)
      }
      if let name = draft.customName { summary["name"] = name }
      if let note = draft.note { summary["note"] = note }
      commit = { try collectionWriter.createCollectionPlace(collection: current, draft: draft) }
    case ["collections", "places", "add"], ["collections", "places", "remove"]:
      try validateTargetOptions(options, allowedOptions: ["id", "item"])
      let collectionID = try savedIdentifier(options, kind: .collection)
      let itemID = try savedIdentifier(options, kind: .collectionItem, option: "item")
      let current = try collections.readCollection(id: collectionID)
      let item = try collections.readCollectionItem(id: itemID)
      let linked = options.positionals.last == "add"
      operation = linked ? "collections.places.add" : "collections.places.remove"
      summary = [
        "id": current.id, "item": item.id,
        "before_sha256": sha256Hex(try CLIJSON.encodeString(current)),
        "item_sha256": sha256Hex(try CLIJSON.encodeString(item)),
      ]
      commit = {
        try collectionWriter.setCollectionMembership(
          collection: current, item: item, linked: linked)
      }
    default: return nil
    }
    if options.dryRun {
      return try result(
        CLISafety.dryRun(
          target: "maps", operation: operation, summary: summary,
          scope: "maps-collection:" + sha256Hex(try CLIJSON.encodeString(summary))),
        human: "dry-run: \(operation)", options: options)
    }
    let payload = try commit()
    return try result(payload, human: "\(operation) changed=\(payload.changed)", options: options)
  }

  private func collectionPosition(_ options: CLIOptions) throws -> Int? {
    guard let value = options.targetOption("position") else { return nil }
    guard let position = Int(value), position >= 0 else {
      throw CLIError(code: .validationError, message: "`--position` must be a nonnegative integer.")
    }
    return position
  }

  private func collectionPlaceSource(_ options: CLIOptions) throws -> MapsCollectionPlaceSource {
    if let place = options.targetOption("place") {
      guard options.targetOption("latitude") == nil, options.targetOption("longitude") == nil else {
        throw CLIError(
          code: .validationError, message: "`--place` cannot be combined with coordinate options.")
      }
      guard place.hasPrefix("maps-item:") else {
        throw CLIError(
          code: .validationError, message: "`--place` requires a native `maps-item:` identifier.")
      }
      return .identifier(String(place.dropFirst("maps-item:".count)))
    }
    return .coordinate(
      latitude: try coordinateOption("latitude", options: options),
      longitude: try coordinateOption("longitude", options: options))
  }
}
