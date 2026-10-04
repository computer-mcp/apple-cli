import Foundation
import MapKit
import Utility

extension MapsSyncSavedPlacesBackend {
  public func createCollectionPlace(
    collection: MapsCollectionRecord, draft: MapsCollectionPlaceDraft
  )
    throws -> MapsCollectionMutationResult
  {
    try validateCollectionPlaceDraft(draft)
    let runtime = try MapsSavedRuntime()
    let deadline = MapsDeadline(seconds: 25)
    let store = try runtime.defaultStore(deadline: deadline)
    let collectionID = try savedIdentifier(collection.id, kind: .collection)
    var parent = try selected(
      .collection, id: collectionID, runtime: runtime, store: store, deadline: deadline)
    try requireCurrent(collection, object: parent, runtime: runtime)
    if let existing = try present(
      .collectionItem, id: draft.id, runtime: runtime, store: store, deadline: deadline)
    {
      return try existingPlace(
        existing, collection: collection, draft: draft, runtime: runtime, store: store,
        deadline: deadline)
    }
    let item: MKMapItem
    switch draft.source {
    case .identifier(let id):
      item = try MapKitMapsBackend().serviceItem(identifier: id, deadline: deadline)
    case .coordinate(let latitude, let longitude):
      item = coordinateMapItem(latitude: latitude, longitude: longitude, name: draft.customName)
    }
    parent = try selected(
      .collection, id: collectionID, runtime: runtime, store: store, deadline: deadline)
    try requireCurrent(collection, object: parent, runtime: runtime)
    if let existing = try present(
      .collectionItem, id: draft.id, runtime: runtime, store: store, deadline: deadline)
    {
      return try existingPlace(
        existing, collection: collection, draft: draft, runtime: runtime, store: store,
        deadline: deadline)
    }
    let before = try links(collectionID, runtime: runtime, store: store, deadline: deadline)
    guard collection.reportedPlaceCount == before.count else {
      throw mapsCollectionVerificationFailure(
        collection.id, reason: "collection_count_inconsistent")
    }
    let image = try runtime.value(parent, "image", as: Data.self)
    try runtime.validateCollectionChange(store, delete: false)
    let place = try runtime.createPlace(draft, item: item, store: store)
    let expected = try runtime.savedPlaceSnapshot(place)
    guard expected.matches(draft) else {
      throw mapsCollectionVerificationFailure(
        collection.id, reason: "created_place_fields_mismatch")
    }
    try runtime.setMembership(parent, item: place, linked: true)
    return try verifyingChange(id: expected.record.id) {
      try runtime.collectionChange(
        store, objects: [parent, place], delete: false, deadline: deadline)
      let cold = try runtime.defaultStore(deadline: deadline)
      let saved = try selected(
        .collectionItem, id: draft.id, runtime: runtime, store: cold, deadline: deadline)
      let actual = try runtime.savedPlaceSnapshot(saved)
      guard expected.matches(actual, allowingCreationTimes: true), actual.matches(draft) else {
        throw mapsCollectionVerificationFailure(
          expected.record.id, reason: "saved_place_fields_or_storage_mismatch")
      }
      let savedParent = try selected(
        .collection, id: collectionID, runtime: runtime, store: cold, deadline: deadline)
      let parentRecord = try runtime.collectionRecord(savedParent)
      var expectedParent = collection
      expectedParent.reportedPlaceCount += 1
      guard mapsCollectionMatches(expectedParent, parentRecord, ignoringModificationTime: true),
        try runtime.value(savedParent, "image", as: Data.self) == image,
        try links(collectionID, runtime: runtime, store: cold, deadline: deadline)
          == before.union([actual.record.id]),
        try parents(draft.id, runtime: runtime, store: cold, deadline: deadline) == [collection.id]
      else {
        throw mapsCollectionVerificationFailure(
          expected.record.id, reason: "saved_place_relationship_or_collection_mismatch")
      }
      return MapsCollectionMutationResult(
        operation: "collections.places.create", changed: true, collection: parentRecord,
        item: actual.record)
    }
  }

  private func existingPlace(
    _ existing: AnyObject, collection: MapsCollectionRecord, draft: MapsCollectionPlaceDraft,
    runtime: MapsSavedRuntime, store: AnyObject, deadline: MapsDeadline
  ) throws -> MapsCollectionMutationResult {
    guard try runtime.collectionItemRecord(existing).kind == .place else {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: "The saved place ID already belongs to another kind of collection item.",
        details: ["id": MapsSavedKind.collectionItem.idPrefix + draft.id.uuidString.lowercased()])
    }
    let snapshot = try runtime.savedPlaceSnapshot(existing)
    let id = try savedIdentifier(collection.id, kind: .collection)
    guard snapshot.matches(draft),
      try links(id, runtime: runtime, store: store, deadline: deadline).contains(
        snapshot.record.id),
      try parents(draft.id, runtime: runtime, store: store, deadline: deadline).contains(
        collection.id)
    else {
      throw CLIError(
        code: .unsafeMutationRefused,
        message: "The saved place ID already belongs to different content or collection.",
        details: ["id": snapshot.record.id])
    }
    return MapsCollectionMutationResult(
      operation: "collections.places.create", changed: false, collection: collection,
      item: snapshot.record)
  }
}
