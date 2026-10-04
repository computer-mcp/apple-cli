import CoreData
import Foundation
import Testing
@testable import NotesCLI

@Suite struct NotesLifecycleReadbackTests {
  @Test(arguments: ["", "\n  Unicode 👩🏽‍💻 e\u{301}\n\n", "\r\nBody", "\rBody"])
  func plainBodyExcludesOnlyTheProvenTitleTerminator(body: String) {
    let projection = "\n" + body
    #expect(notesPlainTextBody(title: "Title", fullText: "Title" + projection,
      nativeBody: projection) == body)
  }

  @Test func plainBodyKeepsWhitespaceWithoutMatchingFullTextEvidence() {
    let body = "\n  Body\n"
    #expect(notesPlainTextBody(title: "Title", fullText: nil, nativeBody: body) == body)
    #expect(notesPlainTextBody(title: "Title", fullText: "Different" + body,
      nativeBody: body) == body)
    #expect(notesPlainTextBody(title: "", fullText: body, nativeBody: body) == body)
    #expect(notesPlainTextBody(title: "Title", fullText: "Title\n" + body,
      nativeBody: body) == body)
    #expect(notesPlainTextBody(title: "Title", fullText: "TitleBody\n",
      nativeBody: "Body\n") == "Body\n")
    #expect(notesPlainTextBody(title: "Title", fullText: "Title\r\nBody",
      nativeBody: "\r\nBody") == "\r\nBody")
  }

  @Test(arguments: ["", "  Body 👩🏽‍💻 e\u{301}\n\n", "\n\n"])
  func nativeFullTextFallbackExcludesTheProvenCompleteTitle(body: String) {
    let title = "Long title 😀"
    let full = title + "\n" + body
    #expect(notesPlainTextBody(title: title, fullText: full, nativeBody: full).utf8.elementsEqual(body.utf8))
    #expect(notesPlainTextBody(title: title, fullText: title, nativeBody: title) == "")
    #expect(notesPlainTextBody(title: "Different", fullText: full, nativeBody: full) == full)
  }

  @Test func canonicallyEquivalentTitleBytesDoNotProveAPlainTextBoundary() {
    let title = "Caf\u{E9}"
    let full = "Cafe\u{301}\n\nBody"
    #expect(notesPlainTextBody(title: title, fullText: full, nativeBody: full).utf8.elementsEqual(full.utf8))
  }

  @Test func managedLookupDistinguishesADeletedObjectFromALiveOne() throws {
    let coordinator = try coordinator()
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.persistentStoreCoordinator = coordinator
    try context.performAndWait {
      let object = NSEntityDescription.insertNewObject(forEntityName: "Entry", into: context)
      object.setValue("Fixture", forKey: "title")
      try context.save()
      let id = object.objectID.uriRepresentation().absoluteString
      context.reset()
      let live = try #require(try NotesManagedObjectLookup.resolve(id: id, context: context))
      #expect(live.value(forKey: "title") as? String == "Fixture")
      context.delete(live)
      try context.save()
      context.reset()
      #expect(try NotesManagedObjectLookup.resolve(id: id, context: context) == nil)
      #expect(try NotesManagedObjectLookup.resolve(id: "not-an-object-id", context: context) == nil)
    }
  }

  @Test(arguments: [
    (NSCocoaErrorDomain, NSFileReadNoPermissionError),
    (NSPOSIXErrorDomain, NSManagedObjectReferentialIntegrityError),
  ])
  func managedLookupPropagatesErrorsOtherThanMissingObjects(domain: String, code: Int) throws {
    let coordinator = try coordinator()
    let context = NotesFailingLookupContext(concurrencyType: .privateQueueConcurrencyType)
    context.persistentStoreCoordinator = coordinator
    try context.performAndWait {
      let object = NSEntityDescription.insertNewObject(forEntityName: "Entry", into: context)
      try context.obtainPermanentIDs(for: [object])
      let id = object.objectID.uriRepresentation().absoluteString
      context.lookupError = NSError(domain: domain, code: code)
      do {
        _ = try NotesManagedObjectLookup.resolve(id: id, context: context)
        Issue.record("An unrelated lookup error was treated as an absent object.")
      } catch let error as NSError {
        #expect(error.domain == domain)
        #expect(error.code == code)
      }
    }
  }

  private func coordinator() throws -> NSPersistentStoreCoordinator {
    let model = NSManagedObjectModel()
    let entity = NSEntityDescription()
    entity.name = "Entry"
    entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
    let title = NSAttributeDescription()
    title.name = "title"
    title.attributeType = .stringAttributeType
    title.isOptional = true
    entity.properties = [title]
    model.entities = [entity]
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil,
      at: nil, options: nil)
    return coordinator
  }
}

private final class NotesFailingLookupContext: NSManagedObjectContext, @unchecked Sendable {
  var lookupError = NSError(domain: NSCocoaErrorDomain, code: NSFileReadNoPermissionError)

  override func existingObject(with objectID: NSManagedObjectID) throws -> NSManagedObject {
    throw lookupError
  }
}
