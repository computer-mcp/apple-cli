import Foundation
import Testing
import Utility

@testable import NotesCLI
@testable import RemindersCLI

@Suite struct NativeRuntimeMethodTests {
  @Test(arguments: ["notes", "reminders"])
  func compatibleInheritedMethodsAndClassMethods(target: String) throws {
    let owner = NSStringFromClass(RuntimeMethodChild.self)
    try require(target, owner: owner, selector: "objectMethod", result: "@")
    try require(target, owner: owner, selector: "sharedObject", classMethod: true, result: "@")
    try require(target, owner: owner, selector: "saveWithError:", result: "B", arguments: ["^@"])
    try require(target, owner: owner, selector: "saveWithError:", result: "B", arguments: ["^r@"])
    try require(target, owner: owner, selector: "acceptsObject:", result: "v", arguments: ["@\"NSObject\""])
  }

  @Test(arguments: ["notes", "reminders"])
  func incompatibleMethodsRefuseBeforeInvocation(target: String) throws {
    let fixture = RuntimeMethodFixture()
    let cases: [(String, String, Bool, String, [String], String)] = [
      ("AppleCLINonexistentRuntimeOwner", "objectMethod", false, "@", [], "class_unavailable"),
      (NSStringFromClass(RuntimeMethodFixture.self), "missingMethod", false, "@", [], "method_unavailable"),
      (NSStringFromClass(RuntimeMethodFixture.self), "objectMethod", true, "@", [], "method_unavailable"),
      (NSStringFromClass(RuntimeMethodFixture.self), "sharedObject", false, "@", [], "method_unavailable"),
      (NSStringFromClass(RuntimeMethodFixture.self), "objectMethod", false, "Q", [], "signature_mismatch"),
      (NSStringFromClass(RuntimeMethodFixture.self), "saveWithError:", false, "B", [], "signature_mismatch"),
      (NSStringFromClass(RuntimeMethodFixture.self), "saveWithError:", false, "B", ["@"], "signature_mismatch"),
      (NSStringFromClass(RuntimeMethodFixture.self), "acceptsOptions:", false, "v", ["q"], "signature_mismatch"),
      (NSStringFromClass(RuntimeMethodFixture.self), "acceptsObject:", false, "v", ["@?"], "signature_mismatch"),
    ]
    for (owner, selector, classMethod, result, arguments, reason) in cases {
      do {
        try require(target, owner: owner, selector: selector, classMethod: classMethod,
          result: result, arguments: arguments)
        _ = fixture.objectMethod()
        Issue.record("Invalid method requirement was accepted: \(selector)")
      } catch let error as CLIError {
        #expect(error.code == .backendUnavailable)
        #expect(error.details["reason"] == reason)
        #expect(error.details["operation"] == "test.read")
      }
    }
    #expect(fixture.calls == 0)
  }

  @Test(arguments: ["notes", "reminders"])
  func requirementUsesTheRealReceiverClass(target: String) throws {
    do {
      try require(target, owner: NSStringFromClass(RuntimeMethodFixture.self),
        selector: "objectMethod", result: "@", receiver: RuntimeMethodIncompatible())
      Issue.record("The receiver's incompatible return type was accepted.")
    } catch let error as CLIError {
      #expect(error.code == .backendUnavailable)
      #expect(error.details["reason"] == "signature_mismatch")
      #expect(error.details["native_class"] == NSStringFromClass(RuntimeMethodIncompatible.self))
    }
  }

  private func require(_ target: String, owner: String, selector: String,
    classMethod: Bool = false, result: String, arguments: [String] = [],
    receiver: NSObject? = nil) throws
  {
    if target == "notes" {
      try NotesRuntimeMethod(owner: owner, selector: selector,
        scope: classMethod ? .classMethod : .instance,
        returnType: result, argumentTypes: arguments)
        .require(operation: "test.read", receiver: receiver)
    } else {
      try ReminderKitRuntimeMethod(owner: owner, selector: selector,
        scope: classMethod ? .classMethod : .instance,
        returnType: result, argumentTypes: arguments)
        .require(operation: "test.read", receiver: receiver)
    }
  }
}

@Suite struct NotesContextBootstrapTests {
  @Test func existingSharedContextDoesNotRequireFallbackMethods() throws {
    var steps: [NotesContextBootstrapStep] = []
    let result: Int? = try notesBootstrapContext(
      require: { steps.append($0) }, shared: { 7 },
      start: { Issue.record("Unexpected start.") },
      create: { Issue.record("Unexpected creation."); return nil })
    #expect(result == 7)
    #expect(steps == [.shared])
  }

  @Test func startingSharedContextDoesNotRequireInitializer() throws {
    var steps: [NotesContextBootstrapStep] = []
    var started = false
    let result: Int? = try notesBootstrapContext(
      require: { steps.append($0) }, shared: { started ? 8 : nil },
      start: { started = true },
      create: { Issue.record("Unexpected creation."); return nil })
    #expect(result == 8)
    #expect(steps == [.shared, .start, .shared])
  }

  @Test func initializerIsRequiredOnlyAfterBothSharedReadsFail() throws {
    var steps: [NotesContextBootstrapStep] = []
    var sharedReads = 0
    let result: Int? = try notesBootstrapContext(
      require: { steps.append($0) }, shared: { sharedReads += 1; return nil },
      start: {}, create: { 9 })
    #expect(result == 9)
    #expect(sharedReads == 2)
    #expect(steps == [.shared, .start, .shared, .create])
  }

  @Test(arguments: [NotesContextBootstrapStep.shared, .start, .create])
  func missingRequirementPreventsItsNativeCall(step: NotesContextBootstrapStep) throws {
    var calls: [NotesContextBootstrapStep] = []
    let failure = CLIError(code: .backendUnavailable, message: "Test method missing.")
    do {
      let _: Int? = try notesBootstrapContext(
        require: { if $0 == step { throw failure } },
        shared: { calls.append(.shared); return nil },
        start: { calls.append(.start) }, create: { calls.append(.create); return nil })
      Issue.record("Missing bootstrap requirement was accepted.")
    } catch let error as CLIError {
      #expect(error == failure)
      #expect(!calls.contains(step))
    }
  }
}

@objc(AppleCLIRuntimeMethodFixture)
private class RuntimeMethodFixture: NSObject {
  var calls = 0
  @objc func objectMethod() -> NSObject? { calls += 1; return NSObject() }
  @objc class func sharedObject() -> NSObject? { NSObject() }
  @objc func saveWithError(_ error: AutoreleasingUnsafeMutablePointer<NSError?>?) -> Bool {
    calls += 1
    return true
  }
  @objc func acceptsOptions(_ options: UInt64) { calls += 1 }
  @objc func acceptsObject(_ object: NSObject?) { calls += 1 }
}

@objc(AppleCLIRuntimeMethodChild)
private final class RuntimeMethodChild: RuntimeMethodFixture {}

@objc(AppleCLIRuntimeMethodIncompatible)
private final class RuntimeMethodIncompatible: NSObject {
  @objc func objectMethod() -> UInt64 { 0 }
}
