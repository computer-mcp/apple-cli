import Foundation
import ObjectiveC
import Utility

extension MapsSavedRuntime {
  func validateCollectionSetters(_ receiver: AnyObject, patch: MapsCollectionPatch) throws {
    guard let cls = object_getClass(receiver) else { throw failure("object_class_unavailable") }
    if patch.title != nil { _ = try method(cls, "setTitle:", result: "v", arguments: ["@"]) }
    if patch.description != nil || patch.clearDescription {
      _ = try method(cls, "setCollectionDescription:", result: "v", arguments: ["@"])
    }
    if patch.position != nil {
      _ = try method(cls, "setPositionIndex:", result: "v", arguments: ["q"])
    }
  }

  func setObject(_ receiver: AnyObject, selector: String, value: AnyObject?) throws {
    guard let cls = object_getClass(receiver) else { throw failure("object_class_unavailable") }
    let method = try method(cls, selector, result: "v", arguments: ["@"])
    typealias Call = @convention(c) (AnyObject, Selector, AnyObject?) -> Void
    unsafeBitCast(method_getImplementation(method), to: Call.self)(
      receiver, NSSelectorFromString(selector), value)
  }

  func setPosition(_ receiver: AnyObject, position: Int) throws {
    guard let cls = object_getClass(receiver) else { throw failure("object_class_unavailable") }
    let method = try method(cls, "setPositionIndex:", result: "v", arguments: ["q"])
    typealias Call = @convention(c) (AnyObject, Selector, Int) -> Void
    unsafeBitCast(method_getImplementation(method), to: Call.self)(
      receiver, NSSelectorFromString("setPositionIndex:"), position)
  }

  func createCollection(_ draft: MapsCollectionDraft, position: Int, store: AnyObject) throws
    -> AnyObject
  {
    let cls: AnyClass = try type("MSCollection")
    let name = "initWithStore:collectionDescription:image:imageUrl:positionIndex:title:"
    let method = try method(cls, name, result: "@", arguments: ["@", "@", "@", "@", "q", "@"])
    _ = try self.method(cls, "setIdentifier:", result: "v", arguments: ["@"])
    typealias Call =
      @convention(c) (
        AnyObject, Selector, AnyObject, AnyObject?, AnyObject?, AnyObject?, Int, AnyObject
      ) -> Unmanaged<AnyObject>?
    guard
      let collection = unsafeBitCast(method_getImplementation(method), to: Call.self)(
        try allocate(cls).takeUnretainedValue(), NSSelectorFromString(name), store,
        draft.description.map { $0 as NSString }, nil, nil, position, draft.title as NSString)?
        .takeRetainedValue()
    else { throw failure("collection_initialization_failed") }
    try setObject(collection, selector: "setIdentifier:", value: draft.id as NSUUID)
    guard
      try identifier(collection, kind: .collection) == MapsSavedKind.collection.idPrefix
        + draft.id.uuidString.lowercased()
    else { throw failure("collection_identity_mismatch") }
    return collection
  }

  func collectionChange(
    _ store: AnyObject, objects: [AnyObject], delete: Bool, deadline: MapsDeadline
  ) throws {
    let name =
      delete ? "deleteWithObjects:completionHandler:" : "saveWithObjects:completionHandler:"
    let method = try collectionChangeMethod(store, delete: delete)
    typealias Block = @convention(block) (NSError?) -> Void
    typealias Call = @convention(c) (AnyObject, Selector, NSArray, Block) -> Void
    let call = unsafeBitCast(method_getImplementation(method), to: Call.self)
    let _: Bool = try waitForMapsCallback(
      deadline: deadline, phase: delete ? "saved_delete" : "saved_save", cancel: {},
      start: { finish in
        let block: Block = { error in
          finish(
            nativeMapsResponse(true, error: error, phase: delete ? "saved_delete" : "saved_save"))
        }
        call(store, NSSelectorFromString(name), objects as NSArray, block)
      })
  }

  func validateCollectionChange(_ store: AnyObject, delete: Bool) throws {
    _ = try collectionChangeMethod(store, delete: delete)
  }

  private func collectionChangeMethod(_ store: AnyObject, delete: Bool) throws -> Method {
    let name =
      delete ? "deleteWithObjects:completionHandler:" : "saveWithObjects:completionHandler:"
    guard let cls = object_getClass(store),
      let method = class_getInstanceMethod(cls, NSSelectorFromString(name)),
      let encoding = method_getTypeEncoding(method),
      String(cString: encoding) == "v32@0:8@\"NSArray\"16@?<v@?@\"NSError\">24"
    else { throw failure("signature_mismatch", selector: name) }
    return method
  }

  func setMembership(_ collection: AnyObject, item: AnyObject, linked: Bool) throws {
    guard let cls = object_getClass(collection) else {
      throw failure("object_class_unavailable")
    }
    let name = linked ? "addPlace:" : "removePlace:"
    let method = try method(cls, name, result: "v", arguments: ["@"])
    typealias Call = @convention(c) (AnyObject, Selector, AnyObject) -> Void
    unsafeBitCast(method_getImplementation(method), to: Call.self)(
      collection, NSSelectorFromString(name), item)
  }
}
