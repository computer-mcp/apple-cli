import CoreData
import Foundation
import Testing

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
}

@objc(AppleCLIProbeManagedRecord)
private final class ProbeManagedRecord: NSManagedObject {
  @NSManaged var deferredValue: String?
}
