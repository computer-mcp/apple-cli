import Foundation
import Utility

extension MapsSyncSavedPlacesBackend: MapsCollectionsWriting {
  public func createCollection(_ draft: MapsCollectionDraft) throws -> MapsCollectionMutationResult
  {
    try requireCustomCollection(draft.id)
    try validateCollectionTitle(draft.title)
    if let position = draft.position, position < 0 {
      throw CLIError(code: .validationError, message: "A collection position must be nonnegative.")
    }
    let runtime = try MapsSavedRuntime()
    let deadline = MapsDeadline(seconds: 20)
    let store = try runtime.defaultStore(deadline: deadline)
    let id = MapsSavedKind.collection.idPrefix + draft.id.uuidString.lowercased()
    if let existing = try present(
      .collection, id: draft.id, runtime: runtime, store: store, deadline: deadline)
    {
      let record = try runtime.collectionRecord(existing)
      guard mapsSavedTextMatches(record.title, draft.title),
        mapsSavedTextMatches(record.description, draft.description),
        draft.position == nil || draft.position == record.position
      else {
        throw CLIError(
          code: .unsafeMutationRefused,
          message: "The collection ID already belongs to different content.", details: ["id": id])
      }
      return MapsCollectionMutationResult(
        operation: "collections.create", changed: false, collection: record)
    }
    let position: Int
    if let explicit = draft.position {
      position = explicit
    } else {
      let values = try runtime.fetch(
        kind: .collection, store: store,
        options: runtime.queryOptions(limit: 1, ascending: false), deadline: deadline)
      try requireBound(values, limit: 1)
      let last = try values.first.map { try runtime.integer($0, "positionIndex") } ?? -1
      guard last < Int.max else { throw runtime.failure("collection_position_overflow") }
      position = max(0, last + 1)
    }
    try runtime.validateCollectionChange(store, delete: false)
    let object = try runtime.createCollection(draft, position: position, store: store)
    return try verifyingChange(id: id) {
      try runtime.collectionChange(store, objects: [object], delete: false, deadline: deadline)
      let cold = try runtime.defaultStore(deadline: deadline)
      let saved = try selected(
        .collection, id: draft.id, runtime: runtime, store: cold, deadline: deadline)
      let record = try runtime.collectionRecord(saved)
      guard record.id == id, mapsSavedTextMatches(record.title, draft.title),
        mapsSavedTextMatches(record.description, draft.description), record.position == position,
        record.reportedPlaceCount == 0, record.imageURL == nil,
        try runtime.value(saved, "image", as: Data.self) == nil,
        try links(draft.id, runtime: runtime, store: cold, deadline: deadline).isEmpty
      else {
        throw mapsCollectionVerificationFailure(id, reason: "created_fields_mismatch")
      }
      return MapsCollectionMutationResult(
        operation: "collections.create", changed: true, collection: record)
    }
  }

  public func updateCollection(current: MapsCollectionRecord, patch: MapsCollectionPatch) throws
    -> MapsCollectionMutationResult
  {
    try validateCollectionPatch(patch)
    try requireCustomCollection(savedIdentifier(current.id, kind: .collection))
    if let position = patch.position, position < 0 {
      throw CLIError(code: .validationError, message: "A collection position must be nonnegative.")
    }
    let runtime = try MapsSavedRuntime()
    let deadline = MapsDeadline(seconds: 20)
    let store = try runtime.defaultStore(deadline: deadline)
    let id = try savedIdentifier(current.id, kind: .collection)
    let object = try selected(
      .collection, id: id, runtime: runtime, store: store, deadline: deadline)
    try requireCurrent(current, object: object, runtime: runtime)
    let desired = patch.applying(to: current)
    if mapsCollectionMatches(current, desired) {
      return MapsCollectionMutationResult(
        operation: "collections.update", changed: false, collection: current)
    }
    let members = try links(id, runtime: runtime, store: store, deadline: deadline)
    let image = try runtime.value(object, "image", as: Data.self)
    try runtime.validateCollectionChange(store, delete: false)
    try runtime.validateCollectionSetters(object, patch: patch)
    if let title = patch.title {
      try runtime.setObject(object, selector: "setTitle:", value: title as NSString)
    }
    if let description = patch.description {
      try runtime.setObject(
        object, selector: "setCollectionDescription:", value: description as NSString)
    }
    if patch.clearDescription {
      try runtime.setObject(object, selector: "setCollectionDescription:", value: nil)
    }
    if let position = patch.position { try runtime.setPosition(object, position: position) }
    return try verifyingChange(id: current.id) {
      try runtime.collectionChange(store, objects: [object], delete: false, deadline: deadline)
      let cold = try runtime.defaultStore(deadline: deadline)
      let saved = try selected(
        .collection, id: id, runtime: runtime, store: cold, deadline: deadline)
      let record = try runtime.collectionRecord(saved)
      guard mapsCollectionMatches(desired, record, ignoringModificationTime: true),
        try links(id, runtime: runtime, store: cold, deadline: deadline) == members,
        try runtime.value(saved, "image", as: Data.self) == image
      else {
        throw mapsCollectionVerificationFailure(
          current.id, reason: "updated_fields_or_preservation_mismatch")
      }
      return MapsCollectionMutationResult(
        operation: "collections.update", changed: true, collection: record)
    }
  }

  public func deleteCollection(current: MapsCollectionRecord) throws -> MapsCollectionMutationResult
  {
    try requireCustomCollection(savedIdentifier(current.id, kind: .collection))
    let runtime = try MapsSavedRuntime()
    let deadline = MapsDeadline(seconds: 20)
    let store = try runtime.defaultStore(deadline: deadline)
    let id = try savedIdentifier(current.id, kind: .collection)
    let object = try selected(
      .collection, id: id, runtime: runtime, store: store, deadline: deadline)
    try requireCurrent(current, object: object, runtime: runtime)
    let objects = try related(
      .collectionItem, predicate: "ANY collections.identifier == %@", id: id,
      runtime: runtime, store: store, deadline: deadline)
    let memberships = try objects.map { item in
      (
        try runtime.identifier(item, kind: .collectionItem),
        try parents(
          savedIdentifier(runtime.identifier(item, kind: .collectionItem), kind: .collectionItem),
          runtime: runtime, store: store, deadline: deadline)
      )
    }
    try runtime.validateCollectionChange(store, delete: true)
    return try verifyingChange(id: current.id) {
      try runtime.collectionChange(store, objects: [object], delete: true, deadline: deadline)
      let cold = try runtime.defaultStore(deadline: deadline)
      guard
        try present(.collection, id: id, runtime: runtime, store: cold, deadline: deadline) == nil
      else {
        throw mapsCollectionVerificationFailure(
          current.id, reason: "deleted_collection_still_present")
      }
      for (itemID, before) in memberships {
        let expected = before.subtracting([current.id])
        let item = try present(
          .collectionItem, id: savedIdentifier(itemID, kind: .collectionItem), runtime: runtime,
          store: cold, deadline: deadline)
        if item != nil {
          guard
            try parents(
              savedIdentifier(itemID, kind: .collectionItem), runtime: runtime, store: cold,
              deadline: deadline) == expected
          else {
            throw mapsCollectionVerificationFailure(current.id, reason: "other_memberships_changed")
          }
        } else if !expected.isEmpty {
          throw mapsCollectionVerificationFailure(current.id, reason: "shared_item_missing")
        }
      }
      return MapsCollectionMutationResult(
        operation: "collections.delete", changed: true, deletedID: current.id)
    }
  }

  public func setCollectionMembership(
    collection: MapsCollectionRecord, item: MapsCollectionItemRecord, linked: Bool
  ) throws -> MapsCollectionMutationResult {
    let runtime = try MapsSavedRuntime()
    let deadline = MapsDeadline(seconds: 20)
    let store = try runtime.defaultStore(deadline: deadline)
    let collectionID = try savedIdentifier(collection.id, kind: .collection)
    let itemID = try savedIdentifier(item.id, kind: .collectionItem)
    let object = try selected(
      .collection, id: collectionID, runtime: runtime, store: store, deadline: deadline)
    let member = try selected(
      .collectionItem, id: itemID, runtime: runtime, store: store, deadline: deadline)
    try requireCurrent(collection, object: object, runtime: runtime)
    guard try mapsCollectionItemMatches(runtime.collectionItemRecord(member), item) else {
      throw mapsCollectionVerificationFailure(collection.id, reason: "item_changed_before_write")
    }
    let before = try links(collectionID, runtime: runtime, store: store, deadline: deadline)
    let otherParents = try parents(itemID, runtime: runtime, store: store, deadline: deadline)
    guard before.contains(item.id) == otherParents.contains(collection.id) else {
      throw mapsCollectionVerificationFailure(
        collection.id, reason: "membership_inconsistent_before_write")
    }
    let operation = linked ? "collections.places.add" : "collections.places.remove"
    if before.contains(item.id) == linked {
      return MapsCollectionMutationResult(
        operation: operation, changed: false, collection: collection, item: item)
    }
    var expectedLinks = before
    var expectedParents = otherParents
    if linked {
      expectedLinks.insert(item.id)
      expectedParents.insert(collection.id)
    } else {
      expectedLinks.remove(item.id)
      expectedParents.remove(collection.id)
    }
    let image = try runtime.value(object, "image", as: Data.self)
    try runtime.validateCollectionChange(store, delete: false)
    try runtime.setMembership(object, item: member, linked: linked)
    return try verifyingChange(id: collection.id) {
      try runtime.collectionChange(
        store, objects: [object, member], delete: false, deadline: deadline)
      let cold = try runtime.defaultStore(deadline: deadline)
      let saved = try selected(
        .collection, id: collectionID, runtime: runtime, store: cold, deadline: deadline)
      let savedMember = try selected(
        .collectionItem, id: itemID, runtime: runtime, store: cold, deadline: deadline)
      let record = try runtime.collectionRecord(saved)
      let itemRecord = try runtime.collectionItemRecord(savedMember)
      var expectedCollection = collection
      var expectedItem = item
      expectedCollection.reportedPlaceCount = record.reportedPlaceCount
      expectedItem.modifiedAt = itemRecord.modifiedAt
      guard mapsCollectionMatches(expectedCollection, record, ignoringModificationTime: true) else {
        throw mapsCollectionVerificationFailure(collection.id, reason: "collection_fields_changed")
      }
      guard mapsCollectionItemMatches(itemRecord, expectedItem) else {
        throw mapsCollectionVerificationFailure(collection.id, reason: "item_fields_changed")
      }
      guard
        try links(collectionID, runtime: runtime, store: cold, deadline: deadline) == expectedLinks
      else {
        throw mapsCollectionVerificationFailure(
          collection.id, reason: "collection_membership_mismatch")
      }
      guard
        try parents(itemID, runtime: runtime, store: cold, deadline: deadline) == expectedParents
      else {
        throw mapsCollectionVerificationFailure(collection.id, reason: "other_memberships_changed")
      }
      guard try runtime.value(saved, "image", as: Data.self) == image else {
        throw mapsCollectionVerificationFailure(collection.id, reason: "collection_cover_changed")
      }
      return MapsCollectionMutationResult(
        operation: operation, changed: true, collection: record, item: itemRecord)
    }
  }

  func present(
    _ kind: MapsSavedKind, id: UUID, runtime: MapsSavedRuntime, store: AnyObject,
    deadline: MapsDeadline
  ) throws -> AnyObject? {
    do {
      return try selected(kind, id: id, runtime: runtime, store: store, deadline: deadline)
    } catch let error as CLIError where error.code == .notFound { return nil }
  }

  func links(
    _ id: UUID, runtime: MapsSavedRuntime, store: AnyObject, deadline: MapsDeadline
  ) throws -> Set<String> {
    Set(
      try related(
        .collectionItem, predicate: "ANY collections.identifier == %@", id: id,
        runtime: runtime, store: store, deadline: deadline
      ).map { try runtime.identifier($0, kind: .collectionItem) })
  }

  func parents(
    _ id: UUID, runtime: MapsSavedRuntime, store: AnyObject, deadline: MapsDeadline
  ) throws -> Set<String> {
    Set(
      try related(
        .collection, predicate: "ANY places.identifier == %@", id: id,
        runtime: runtime, store: store, deadline: deadline
      ).map { try runtime.identifier($0, kind: .collection) })
  }

  func related(
    _ kind: MapsSavedKind, predicate: String, id: UUID, runtime: MapsSavedRuntime,
    store: AnyObject, deadline: MapsDeadline
  ) throws -> [AnyObject] {
    let limit = 10_001
    let values = try runtime.fetch(
      kind: kind, store: store,
      options: runtime.queryOptions(
        limit: limit, predicate: NSPredicate(format: predicate, id as NSUUID)),
      deadline: deadline)
    try requireBound(values, limit: limit)
    guard values.count < limit else { throw runtime.failure("relationship_scope_exceeds_limit") }
    try requireUnique(values.map { try runtime.identifier($0, kind: kind) })
    return values
  }

  func requireCurrent(
    _ record: MapsCollectionRecord, object: AnyObject, runtime: MapsSavedRuntime
  ) throws {
    guard try mapsCollectionMatches(record, runtime.collectionRecord(object)) else {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: "The selected Maps collection changed before the write.",
        details: ["id": record.id])
    }
  }

  func verifyingChange(id: String, work: () throws -> MapsCollectionMutationResult) throws
    -> MapsCollectionMutationResult
  {
    do { return try work() } catch var error as CLIError {
      error.details["id"] = id
      error.details["mutation_outcome"] = "unverified"
      throw error
    }
  }
}
