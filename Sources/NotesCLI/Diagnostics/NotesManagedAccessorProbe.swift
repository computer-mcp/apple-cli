import CoreData
import Foundation
import ObjectiveC.runtime
import Utility

func notesRequireDateAccessors(_ object: NSManagedObject, operation: String) throws {
  for property in ["creationDate", "modificationDate"] {
    guard object.entity.attributesByName[property]?.attributeType == .dateAttributeType else {
      throw CLIError(code: .backendUnavailable,
        message: "Notes object model does not expose the expected date attribute.",
        details: ["operation": operation, "native_selector": property,
          "reason": "model_attribute_mismatch"])
    }
    try NotesRuntimeMethod(owner: "ICNote", selector: property, returnType: "@")
      .require(operation: operation, receiver: object)
  }
}

struct NotesManagedAccessorProbe: Sendable {
  var propertiesByClass: [String: Set<String>]

  static func installedModel() -> Self {
    guard let folderClass = NSClassFromString("ICFolder") as? NSManagedObject.Type,
      let url = Bundle(for: folderClass).url(forResource: "NoteData", withExtension: "mom"),
      let model = NSManagedObjectModel(contentsOf: url)
    else { return Self(propertiesByClass: [:]) }
    var properties: [String: Set<String>] = [:]
    for entity in model.entities {
      guard let name = entity.managedObjectClassName else { continue }
      properties[name, default: []].formUnion(entity.propertiesByName.keys)
    }
    return Self(propertiesByClass: properties)
  }

  func isDeferred(_ owner: AnyClass, selector: String) -> Bool {
    guard owner is NSManagedObject.Type else { return false }
    let name: String
    if selector.hasPrefix("set"), selector.hasSuffix(":"),
      selector.filter({ $0 == ":" }).count == 1
    {
      let value = selector.dropFirst(3).dropLast()
      guard let first = value.first else { return false }
      name = first.lowercased() + value.dropFirst()
    } else {
      guard !selector.contains(":") else { return false }
      name = selector
    }
    // A declaration alone is insufficient: require both @dynamic metadata and
    // the installed model's property. No context or persistent store is opened.
    guard propertiesByClass[NSStringFromClass(owner)]?.contains(name) == true,
      let property = class_getProperty(owner, name),
      let attributes = property_getAttributes(property)
    else { return false }
    return String(cString: attributes).split(separator: ",").contains("D")
  }
}
