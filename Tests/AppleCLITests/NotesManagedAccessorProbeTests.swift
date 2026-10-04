import CoreData
import Foundation
import Testing
import Utility

@testable import NotesCLI

@Suite
struct NotesManagedAccessorProbeTests {
  @Test func dynamicAccessorsRequireMatchingModelAndDeclaration() {
    let name = NSStringFromClass(ProbeManagedRecord.self)
    let probe = NotesManagedAccessorProbe(propertiesByClass: [
      name: ["deferredValue", "missingValue"]
    ])
    #expect(probe.isDeferred(ProbeManagedRecord.self, selector: "deferredValue"))
    #expect(probe.isDeferred(ProbeManagedRecord.self, selector: "setDeferredValue:"))
    #expect(!probe.isDeferred(ProbeManagedRecord.self, selector: "missingValue"))
    #expect(!probe.isDeferred(ProbeManagedRecord.self, selector: "perform:with:"))
    #expect(!probe.isDeferred(NSObject.self, selector: "deferredValue"))
    #expect(
      !NotesManagedAccessorProbe(propertiesByClass: [:])
        .isDeferred(ProbeManagedRecord.self, selector: "deferredValue"))
  }

  @Test func deferredRequiredAccessorsDoNotPassReadiness() {
    let readiness = NotesRuntimeReadinessResult(
      frameworks: [],
      classes: [
        NotesRuntimeClassProbeResult(
          className: "ProbeManagedRecord", available: true,
          requiredSelectors: ["deferredValue"], missingSelectors: [],
          deferredSelectors: ["deferredValue"])
      ])
    #expect(readiness.missingSelectors.isEmpty)
    #expect(readiness.deferredSelectors == ["ProbeManagedRecord.deferredValue"])
    #expect(!readiness.isReady)
    let rich = NotesRichCapabilityProbeResult(candidates: [
      NotesRichCapabilityCandidateProbeResult(
        family: "model", owner: "ProbeManagedRecord", selector: "deferredValue",
        kind: "instance", required: true, available: false, deferred: true)
    ])
    #expect(rich.missingRequiredCandidates.isEmpty)
    #expect(rich.deferredCandidates.count == 1)
    #expect(!rich.isReady)
  }

  @Test func realInMemoryModelSuppliesUsableTypedDateAccessors() throws {
    let context = try dateContext(modificationType: .dateAttributeType)
    try context.performAndWait {
      let entity = try #require(context.persistentStoreCoordinator?.managedObjectModel.entities.first)
      let record = DateAccessorRecord(entity: entity, insertInto: context)
      try notesRequireDateAccessors(record, operation: "test.read")
      let instant = Date(timeIntervalSince1970: 1_000)
      record.creationDate = instant
      record.modificationDate = instant
      #expect(record.creationDate == instant)
      #expect(record.modificationDate == instant)
      #expect(record.managedObjectContext === context)
      #expect(record.entity.attributesByName["creationDate"]?.attributeType == .dateAttributeType)
    }
  }

  @Test func declarationWithoutTheActualDateModelRefusesAccess() throws {
    let context = try dateContext(modificationType: .stringAttributeType)
    try context.performAndWait {
      let entity = try #require(context.persistentStoreCoordinator?.managedObjectModel.entities.first)
      let record = WrongModelDateAccessorRecord(entity: entity, insertInto: context)
      do {
        try notesRequireDateAccessors(record, operation: "test.read")
        Issue.record("An incompatible model attribute was accepted.")
      } catch let error as CLIError {
        #expect(error.code == .backendUnavailable)
        #expect(error.details["native_selector"] == "modificationDate")
        #expect(error.details["reason"] == "model_attribute_mismatch")
      }
    }
  }

  private func dateContext(modificationType: NSAttributeType) throws
    -> NSManagedObjectContext
  {
    let entity = NSEntityDescription()
    entity.name = modificationType == .dateAttributeType ? "DateRecord" : "WrongModelDateRecord"
    entity.managedObjectClassName = modificationType == .dateAttributeType
      ? NSStringFromClass(DateAccessorRecord.self) : NSStringFromClass(WrongModelDateAccessorRecord.self)
    entity.properties = ["creationDate", "modificationDate"].map { name in
      let attribute = NSAttributeDescription()
      attribute.name = name
      attribute.isOptional = true
      attribute.attributeType = name == "creationDate" ? .dateAttributeType : modificationType
      return attribute
    }
    let model = NSManagedObjectModel()
    model.entities = [entity]
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    try coordinator.addPersistentStore(ofType: NSInMemoryStoreType,
      configurationName: nil, at: nil, options: nil)
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.persistentStoreCoordinator = coordinator
    return context
  }
}

@objc(AppleCLIProbeManagedRecord)
private final class ProbeManagedRecord: NSManagedObject {
  @NSManaged var deferredValue: String?
}

@objc(AppleCLIDateAccessorRecord)
private final class DateAccessorRecord: NSManagedObject {
  @NSManaged var creationDate: Date?
  @NSManaged var modificationDate: Date?
}

@objc(AppleCLIWrongModelDateAccessorRecord)
private final class WrongModelDateAccessorRecord: NSManagedObject {
  @NSManaged var creationDate: Date?
  @NSManaged var modificationDate: Date?
}
