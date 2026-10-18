import CoreData
import Foundation

enum NotesManagedObjectLookup {
  static func resolve(id: String, context: NSManagedObjectContext) throws -> NSManagedObject? {
    guard id.hasPrefix("x-coredata://"), let url = URL(string: id),
      let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url)
    else { return nil }
    do {
      return try context.existingObject(with: objectID)
    } catch let error as NSError
      where error.domain == NSCocoaErrorDomain && error.code == NSManagedObjectReferentialIntegrityError {
      return nil
    }
  }
}
