import Darwin
import Foundation
import ObjectiveC
import Utility

enum MapsSavedKind {
  case favorite, collection, collectionItem
  var requestClass: String {
    switch self {
    case .favorite: "MSFavoriteItemRequest"
    case .collection: "MSCollectionRequest"
    case .collectionItem: "MSCollectionItemRequest"
    }
  }
  var objectClass: String {
    switch self {
    case .favorite: "MSFavoriteItem"
    case .collection: "MSCollection"
    case .collectionItem: "MSCollectionItem"
    }
  }
  var idPrefix: String {
    switch self {
    case .favorite: "maps-favorite:"
    case .collection: "maps-collection:"
    case .collectionItem: "maps-collection-item:"
    }
  }
}

struct MapsSavedRuntime {
  init() throws {
    guard
      dlopen("/System/Library/PrivateFrameworks/MapsSync.framework/MapsSync", RTLD_LOCAL | RTLD_NOW)
        != nil
    else {
      throw failure("framework_unavailable")
    }
  }

  func failure(_ reason: String, selector: String? = nil) -> CLIError {
    var details = ["reason": reason]
    if let selector { details["selector"] = selector }
    return CLIError(
      code: .backendUnavailable,
      message: "Saved Maps data could not be accessed through the native framework.",
      details: details)
  }

  func type(_ name: String) throws -> AnyClass {
    guard let cls = NSClassFromString(name) else { throw failure("class_unavailable") }
    return cls
  }

  func method(
    _ cls: AnyClass, _ name: String, classMethod: Bool = false,
    result: String, arguments: [String] = []
  ) throws -> Method {
    let selector = NSSelectorFromString(name)
    guard
      let method = classMethod
        ? class_getClassMethod(cls, selector) : class_getInstanceMethod(cls, selector),
      method_getNumberOfArguments(method) == arguments.count + 2
    else {
      throw failure("method_unavailable_or_incompatible", selector: name)
    }
    let copiedReturn = method_copyReturnType(method)
    let actualReturn = String(cString: copiedReturn)
    free(copiedReturn)
    guard actualReturn == result else { throw failure("signature_mismatch", selector: name) }
    for (index, expected) in arguments.enumerated() {
      guard let copied = method_copyArgumentType(method, UInt32(index + 2)) else {
        throw failure("signature_unavailable", selector: name)
      }
      let actual = String(cString: copied)
      free(copied)
      guard actual == expected else { throw failure("signature_mismatch", selector: name) }
    }
    return method
  }

  func allocate(_ cls: AnyClass) throws -> Unmanaged<AnyObject> {
    let method = try method(cls, "alloc", classMethod: true, result: "@")
    typealias Call = @convention(c) (AnyObject, Selector) -> Unmanaged<AnyObject>?
    let call = unsafeBitCast(method_getImplementation(method), to: Call.self)
    guard let object = call(cls as AnyObject, NSSelectorFromString("alloc")) else {
      throw failure("allocation_failed")
    }
    return object
  }

  func queryOptions(
    limit: Int, offset: Int = 0, predicate: NSPredicate? = nil, ascending: Bool = true
  ) throws -> AnyObject {
    let rangeClass: AnyClass = try type("MapsSync.MapsSyncRange")
    let rangeMethod = try method(
      rangeClass, "initWithOffset:limit:", result: "@", arguments: ["q", "q"])
    typealias InitRange = @convention(c) (AnyObject, Selector, Int, Int) -> Unmanaged<AnyObject>?
    let rangeCall = unsafeBitCast(method_getImplementation(rangeMethod), to: InitRange.self)
    guard
      let range = rangeCall(
        try allocate(rangeClass).takeUnretainedValue(),
        NSSelectorFromString("initWithOffset:limit:"), offset, limit)?.takeRetainedValue()
    else {
      throw failure("range_initialization_failed")
    }
    guard try integer(range, "offset") == offset, try integer(range, "limit") == limit else {
      throw failure("query_range_mismatch")
    }
    let optionsClass: AnyClass = try type("MapsSync.MapsSyncQueryOptions")
    let initializer = try method(
      optionsClass, "initWithPredicate:sortDescriptors:range:",
      result: "@", arguments: ["@", "@", "@"])
    typealias InitOptions =
      @convention(c) (AnyObject, Selector, AnyObject?, AnyObject?, AnyObject?) -> Unmanaged<
        AnyObject
      >?
    let call = unsafeBitCast(method_getImplementation(initializer), to: InitOptions.self)
    let sorting =
      [
        NSSortDescriptor(key: "positionIndex", ascending: ascending),
        NSSortDescriptor(key: "identifier", ascending: true),
      ] as NSArray
    guard
      let options = call(
        try allocate(optionsClass).takeUnretainedValue(),
        NSSelectorFromString("initWithPredicate:sortDescriptors:range:"), predicate, sorting, range)?
        .takeRetainedValue()
    else {
      throw failure("query_initialization_failed")
    }
    guard let storedRange = try object(options, "range"),
      try integer(storedRange, "offset") == offset, try integer(storedRange, "limit") == limit
    else {
      throw failure("query_range_mismatch")
    }
    let notify = try method(optionsClass, "setNotifyOnLoad:", result: "v", arguments: ["B"])
    typealias SetBool = @convention(c) (AnyObject, Selector, Bool) -> Void
    unsafeBitCast(method_getImplementation(notify), to: SetBool.self)(
      options, NSSelectorFromString("setNotifyOnLoad:"), false)
    return options
  }

  func defaultStore(deadline: MapsDeadline) throws -> AnyObject {
    let cls: AnyClass = try type("MapsSync.MapsSyncStore")
    let method = try method(
      cls, "withDefaultStoreWithBlock:", classMethod: true, result: "v", arguments: ["@?"])
    typealias Block = @convention(block) (AnyObject?, NSError?) -> Void
    typealias Call = @convention(c) (AnyObject, Selector, Block) -> Void
    let call = unsafeBitCast(method_getImplementation(method), to: Call.self)
    return try waitForMapsCallback(
      deadline: deadline, phase: "saved_store", cancel: {},
      start: { finish in
        let block: Block = { value, error in
          finish(nativeMapsResponse(value, error: error, phase: "saved_store"))
        }
        call(cls as AnyObject, NSSelectorFromString("withDefaultStoreWithBlock:"), block)
      })
  }

  func fetch(kind: MapsSavedKind, store: AnyObject, options: AnyObject, deadline: MapsDeadline)
    throws -> [AnyObject]
  {
    let cls: AnyClass = try type(kind.requestClass)
    let initializer = try method(cls, "initWithStore:", result: "@", arguments: ["@"])
    typealias InitRequest = @convention(c) (AnyObject, Selector, AnyObject) -> Unmanaged<AnyObject>?
    let create = unsafeBitCast(method_getImplementation(initializer), to: InitRequest.self)
    guard
      let request = create(
        try allocate(cls).takeUnretainedValue(), NSSelectorFromString("initWithStore:"), store)?
        .takeRetainedValue()
    else {
      throw failure("request_initialization_failed")
    }
    let selector = NSSelectorFromString("fetchWithOptions:completionHandler:")
    // Objective-C's argument parser splits Swift's extended quoted/block encoding.
    // Check the complete verified signature before calling the native block API.
    guard let method = class_getInstanceMethod(cls, selector),
      let encoding = method_getTypeEncoding(method),
      String(cString: encoding)
        == "v32@0:8@\"_TtC8MapsSync20MapsSyncQueryOptions\"16@?<v@?@\"NSArray\"@\"NSError\">24"
    else {
      throw failure("signature_mismatch", selector: NSStringFromSelector(selector))
    }
    typealias Block = @convention(block) (NSArray?, NSError?) -> Void
    typealias Call = @convention(c) (AnyObject, Selector, AnyObject, Block) -> Void
    let call = unsafeBitCast(method_getImplementation(method), to: Call.self)
    return try waitForMapsCallback(
      deadline: deadline, phase: "saved_fetch", cancel: {},
      start: { finish in
        let block: Block = { values, error in
          finish(
            nativeMapsResponse(
              values?.map { $0 as AnyObject }, error: error, phase: "saved_fetch"))
        }
        call(request, selector, options, block)
      })
  }

  func object(_ receiver: AnyObject, _ selector: String) throws -> AnyObject? {
    guard let cls = object_getClass(receiver) else { throw failure("object_class_unavailable") }
    let method = try method(cls, selector, result: "@")
    typealias Call = @convention(c) (AnyObject, Selector) -> Unmanaged<AnyObject>?
    return unsafeBitCast(method_getImplementation(method), to: Call.self)(
      receiver, NSSelectorFromString(selector))?.takeUnretainedValue()
  }

  func value<Value>(_ receiver: AnyObject, _ selector: String, as: Value.Type) throws -> Value? {
    guard let object = try object(receiver, selector) else { return nil }
    guard let value = object as? Value else {
      throw failure("field_type_mismatch", selector: selector)
    }
    return value
  }

  func integer(_ receiver: AnyObject, _ selector: String) throws -> Int {
    guard let cls = object_getClass(receiver) else { throw failure("object_class_unavailable") }
    let method = try method(cls, selector, result: "q")
    typealias Call = @convention(c) (AnyObject, Selector) -> Int
    return unsafeBitCast(method_getImplementation(method), to: Call.self)(
      receiver, NSSelectorFromString(selector))
  }

  func boolean(_ receiver: AnyObject, _ selector: String) throws -> Bool {
    guard let cls = object_getClass(receiver) else { throw failure("object_class_unavailable") }
    let method = try method(cls, selector, result: "B")
    typealias Call = @convention(c) (AnyObject, Selector) -> Bool
    return unsafeBitCast(method_getImplementation(method), to: Call.self)(
      receiver, NSSelectorFromString(selector))
  }

  func identifier(_ object: AnyObject, kind: MapsSavedKind) throws -> String {
    guard let object = object as? NSObject, object.isKind(of: try type(kind.objectClass)),
      let uuid = try value(object, "identifier", as: UUID.self)
    else {
      throw failure("saved_identity_unavailable")
    }
    return kind.idPrefix + uuid.uuidString.lowercased()
  }

  func coordinates(_ object: AnyObject) throws -> (Double?, Double?) {
    let latitude = try value(object, "latitude", as: NSNumber.self)?.doubleValue
    let longitude = try value(object, "longitude", as: NSNumber.self)?.doubleValue
    guard latitude.map({ $0.isFinite && (-90...90).contains($0) }) ?? true,
      longitude.map({ $0.isFinite && (-180...180).contains($0) }) ?? true
    else {
      throw failure("saved_coordinate_invalid")
    }
    return (latitude, longitude)
  }

  func favoriteRecord(_ object: AnyObject) throws -> MapsFavoriteRecord {
    let id = try identifier(object, kind: .favorite)
    let (latitude, longitude) = try coordinates(object)
    return try MapsFavoriteRecord(
      id: id, customName: value(object, "customName", as: String.self),
      placeName: value(object, "mapItemName", as: String.self),
      address: value(object, "mapItemAddress", as: String.self),
      latitude: latitude, longitude: longitude, hidden: boolean(object, "hidden"),
      position: integer(object, "positionIndex"),
      createdAt: value(object, "createTime", as: Date.self),
      modifiedAt: value(object, "modificationTime", as: Date.self))
  }

  func collectionRecord(_ object: AnyObject) throws -> MapsCollectionRecord {
    let id = try identifier(object, kind: .collection)
    guard let cls = object_getClass(object) else { throw failure("object_class_unavailable") }
    let countMethod = try method(cls, "placesCount", result: "i")
    typealias GetCount = @convention(c) (AnyObject, Selector) -> Int32
    let count = unsafeBitCast(method_getImplementation(countMethod), to: GetCount.self)(
      object, NSSelectorFromString("placesCount"))
    guard count >= 0 else { throw failure("collection_count_invalid") }
    return try MapsCollectionRecord(
      id: id, title: value(object, "title", as: String.self),
      description: value(object, "collectionDescription", as: String.self),
      imageURL: value(object, "imageUrl", as: String.self),
      position: integer(object, "positionIndex"), reportedPlaceCount: Int(count),
      createdAt: value(object, "createTime", as: Date.self),
      modifiedAt: value(object, "modificationTime", as: Date.self))
  }

  func collectionItemRecord(_ object: AnyObject) throws -> MapsCollectionItemRecord {
    let id = try identifier(object, kind: .collectionItem)
    guard let object = object as? NSObject else { throw failure("object_class_unavailable") }
    let kind: MapsCollectionItemKind
    if object.isKind(of: try type("MSCollectionPlaceItem")) {
      kind = .place
    } else if object.isKind(of: try type("MSCollectionTransitItem")) {
      kind = .transit
    } else {
      throw CLIError(
        code: .unsupportedOperation, message: "This saved collection item type is not supported.",
        details: ["native_type": NSStringFromClass(Swift.type(of: object))])
    }
    var record = try MapsCollectionItemRecord(
      id: id, kind: kind, position: integer(object, "positionIndex"),
      createdAt: value(object, "createTime", as: Date.self),
      modifiedAt: value(object, "modificationTime", as: Date.self))
    switch kind {
    case .place:
      record.customName = try value(object, "customName", as: String.self)
      record.placeName = try value(object, "mapItemName", as: String.self)
      record.address = try value(object, "mapItemAddress", as: String.self)
      (record.latitude, record.longitude) = try coordinates(object)
      record.category = try value(object, "mapItemCategory", as: String.self)
      record.note = try value(object, "placeItemNote", as: String.self)
      record.nativeIdentifier = try savedPlaceIdentifier(object)
    case .transit:
      guard let cls = object_getClass(object) else { throw failure("object_class_unavailable") }
      let method = try method(cls, "muid", result: "Q")
      typealias GetIdentifier = @convention(c) (AnyObject, Selector) -> UInt64
      let lineID = unsafeBitCast(method_getImplementation(method), to: GetIdentifier.self)(
        object, NSSelectorFromString("muid"))
      record.transitLineIdentifier = String(lineID)
    }
    return record
  }
}
