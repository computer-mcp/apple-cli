import Foundation
import MapKit
import ObjectiveC
import Utility

struct MapsSavedPlaceSnapshot {
  var record: MapsCollectionItemRecord
  var dictionary: NSDictionary
  var unknownFields: Data?
  var nativeMUID: UInt64
  var hasMUID: Bool
  var storedMUID: NSNumber?
  var droppedPinCoordinate: Data?
  var floor: Int32
  var origin: Int16
  var type: Int16
  var hasOriginalIdentifier: Bool
  var refreshedAt: Date?

  func matches(_ other: Self, allowingCreationTimes: Bool = false) -> Bool {
    var expected = record
    if allowingCreationTimes {
      expected.createdAt = other.record.createdAt
      expected.modifiedAt = other.record.modifiedAt
    }
    return mapsCollectionItemMatches(expected, other.record)
      && dictionary.isEqual(other.dictionary) && unknownFields == other.unknownFields
      && nativeMUID == other.nativeMUID && hasMUID == other.hasMUID
      && storedMUID == other.storedMUID && droppedPinCoordinate == other.droppedPinCoordinate
      && floor == other.floor && origin == other.origin && type == other.type
      && hasOriginalIdentifier == other.hasOriginalIdentifier && refreshedAt == other.refreshedAt
  }

  func matches(_ draft: MapsCollectionPlaceDraft) -> Bool {
    guard record.id == MapsSavedKind.collectionItem.idPrefix + draft.id.uuidString.lowercased(),
      record.kind == .place, mapsSavedTextMatches(record.customName, draft.customName),
      mapsSavedTextMatches(record.note, draft.note), !hasOriginalIdentifier,
      droppedPinCoordinate == nil, floor == 0, origin == 0, type == 0
    else { return false }
    switch draft.source {
    case .identifier(let id):
      return mapsSavedTextMatches(record.nativeIdentifier, id) && hasMUID && nativeMUID > 0
        && storedMUID?.uint64Value == nativeMUID
    case .coordinate(let latitude, let longitude):
      return record.nativeIdentifier == nil && !hasMUID && nativeMUID == 0 && storedMUID == nil
        && record.latitude == latitude && record.longitude == longitude
        && mapsSavedTextMatches(record.placeName, draft.customName)
    }
  }
}

extension MapsSavedRuntime {
  func savedPlaceStorage(_ place: AnyObject) throws -> AnyObject? {
    guard let storage = try object(place, "mapItemStorage") else { return nil }
    guard let native = storage as? NSObject, native.isKind(of: try type("GEOMapItemStorage")) else {
      throw failure("saved_place_storage_type_mismatch")
    }
    return storage
  }

  func mapItem(_ storage: AnyObject) throws -> MKMapItem {
    guard let geo = try object(storage, "_geoMapItem") else {
      throw failure("saved_geo_item_unavailable")
    }
    let name = "_itemWithGeoMapItem:"
    let method = try method(MKMapItem.self, name, classMethod: true, result: "@", arguments: ["@"])
    typealias Call = @convention(c) (AnyObject, Selector, AnyObject) -> Unmanaged<AnyObject>?
    guard
      let item = unsafeBitCast(method_getImplementation(method), to: Call.self)(
        MKMapItem.self as AnyObject, NSSelectorFromString(name), geo)?.takeUnretainedValue()
        as? MKMapItem
    else { throw failure("saved_map_item_unavailable") }
    return item
  }

  func savedPlaceIdentifier(_ place: AnyObject) throws -> String? {
    guard #available(macOS 15, *), let storage = try savedPlaceStorage(place) else { return nil }
    return try mapItem(storage).identifier?.rawValue
  }

  func unsigned(_ receiver: AnyObject, _ selector: String) throws -> UInt64 {
    guard let cls = object_getClass(receiver) else { throw failure("object_class_unavailable") }
    let method = try method(cls, selector, result: "Q")
    typealias Call = @convention(c) (AnyObject, Selector) -> UInt64
    return unsafeBitCast(method_getImplementation(method), to: Call.self)(
      receiver, NSSelectorFromString(selector))
  }

  func short(_ receiver: AnyObject, _ selector: String) throws -> Int16 {
    guard let cls = object_getClass(receiver) else { throw failure("object_class_unavailable") }
    let method = try method(cls, selector, result: "s")
    typealias Call = @convention(c) (AnyObject, Selector) -> Int16
    return unsafeBitCast(method_getImplementation(method), to: Call.self)(
      receiver, NSSelectorFromString(selector))
  }

  func savedPlaceSnapshot(_ place: AnyObject) throws -> MapsSavedPlaceSnapshot {
    let record = try collectionItemRecord(place)
    guard record.kind == .place, let storage = try savedPlaceStorage(place),
      let dictionary = try value(storage, "dictionaryRepresentation", as: NSDictionary.self)
    else { throw failure("saved_place_snapshot_unavailable") }
    let unknown = try object(storage, "unknownFields")
    let bytes: Data?
    if let unknown {
      guard let data = try value(unknown, "data", as: Data.self) else {
        throw failure("saved_place_unknown_fields_unavailable")
      }
      bytes = data
    } else {
      bytes = nil
    }
    guard let cls = object_getClass(place) else { throw failure("object_class_unavailable") }
    let floorMethod = try method(cls, "droppedPinFloorOrdinal", result: "i")
    typealias Floor = @convention(c) (AnyObject, Selector) -> Int32
    return try MapsSavedPlaceSnapshot(
      record: record, dictionary: dictionary, unknownFields: bytes,
      nativeMUID: unsigned(storage, "_muid"), hasMUID: boolean(storage, "_hasMUID"),
      storedMUID: value(place, "muid", as: NSNumber.self),
      droppedPinCoordinate: value(place, "droppedPinCoordinate", as: Data.self),
      floor: unsafeBitCast(method_getImplementation(floorMethod), to: Floor.self)(
        place, NSSelectorFromString("droppedPinFloorOrdinal")),
      origin: short(place, "origin"), type: short(place, "type"),
      hasOriginalIdentifier: object(place, "originalIdentifier") != nil,
      refreshedAt: value(place, "mapItemLastRefreshed", as: Date.self))
  }

  func createPlace(_ draft: MapsCollectionPlaceDraft, item: MKMapItem, store: AnyObject) throws
    -> AnyObject
  {
    let cls: AnyClass = try type("MSCollectionPlaceItem")
    let stripName = "strippedMapItemWith:"
    let strip = try method(cls, stripName, classMethod: true, result: "@", arguments: ["@"])
    typealias Strip = @convention(c) (AnyObject, Selector, AnyObject) -> Unmanaged<AnyObject>?
    guard let source = try object(item, "_geoMapItemStorageForPersistence"),
      let geo = try object(source, "_geoMapItem"),
      let storage = unsafeBitCast(method_getImplementation(strip), to: Strip.self)(
        cls as AnyObject, NSSelectorFromString(stripName), geo)?.takeUnretainedValue(),
      let native = storage as? NSObject, native.isKind(of: try type("GEOMapItemStorage"))
    else { throw failure("collection_place_storage_unavailable") }
    let nativeMUID = try unsigned(storage, "_muid")
    let hasMUID = try boolean(storage, "_hasMUID")
    let projection = try placeRecord(item, fallbackName: "Place")
    switch draft.source {
    case .identifier(let id):
      guard mapsSavedTextMatches(projection.nativeIdentifier, id), hasMUID, nativeMUID > 0 else {
        throw failure("collection_service_identity_unavailable")
      }
    case .coordinate(let latitude, let longitude):
      guard projection.nativeIdentifier == nil, !hasMUID, nativeMUID == 0,
        projection.latitude == latitude, projection.longitude == longitude
      else { throw failure("collection_coordinate_identity_mismatch") }
    }
    let name =
      "initWithStore:customName:droppedPinCoordinate:droppedPinFloorOrdinal:latitude:longitude:mapItemAddress:mapItemCategory:mapItemLastRefreshed:mapItemName:muid:origin:originalIdentifier:placeItemNote:type:"
    let initializer = try method(
      cls, name, result: "@",
      arguments: ["@", "@", "@", "i", "@", "@", "@", "@", "@", "@", "@", "s", "@", "@", "s"])
    for setter in ["setIdentifier:", "setMapItemStorage:"] {
      _ = try method(cls, setter, result: "v", arguments: ["@"])
    }
    typealias Create =
      @convention(c) (
        AnyObject, Selector, AnyObject, AnyObject?, AnyObject?, Int32, AnyObject?, AnyObject?,
        AnyObject?, AnyObject?, AnyObject?, AnyObject?, AnyObject?, Int16, AnyObject?, AnyObject?,
        Int16
      ) -> Unmanaged<AnyObject>?
    guard
      let place = unsafeBitCast(method_getImplementation(initializer), to: Create.self)(
        try allocate(cls).takeUnretainedValue(), NSSelectorFromString(name), store,
        draft.customName.map { $0 as NSString }, nil, 0,
        projection.latitude.map { NSNumber(value: $0) },
        projection.longitude.map { NSNumber(value: $0) },
        projection.address.map { $0 as NSString }, projection.category.map { $0 as NSString },
        hasMUID ? Date() as NSDate : nil, item.name.map { $0 as NSString },
        hasMUID ? NSNumber(value: nativeMUID) : nil, 0, nil, draft.note.map { $0 as NSString }, 0
      )?.takeRetainedValue()
    else { throw failure("collection_place_initialization_failed") }
    try setObject(place, selector: "setIdentifier:", value: draft.id as NSUUID)
    // MapsSync's factory owns its persisted GEO representation and pruning rules.
    try setObject(place, selector: "setMapItemStorage:", value: storage)
    return place
  }
}
