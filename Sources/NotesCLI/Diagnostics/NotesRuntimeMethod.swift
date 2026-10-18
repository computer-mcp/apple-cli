import Darwin
import Foundation
import ObjectiveC.runtime
import Utility

struct NotesRuntimeMethod: Sendable {
  enum Scope: String, Equatable, Sendable {
    case instance
    case classMethod = "class"
  }

  var owner: String
  var selector: String
  var scope: Scope = .instance
  var returnType: String
  var argumentTypes: [String] = []

  func require(operation: String, receiver: NSObject? = nil) throws {
    let runtimeSelector = NSSelectorFromString(selector)
    // Core Data may install model accessors when asked about a real object.
    if scope == .instance, let receiver {
      _ = receiver.responds(to: runtimeSelector)
    }
    let runtimeClass: AnyClass?
    if let receiver {
      runtimeClass = object_getClass(receiver)
    } else {
      runtimeClass = NSClassFromString(owner)
    }
    let method = runtimeClass.flatMap {
      scope == .classMethod
        ? class_getClassMethod($0, runtimeSelector)
        : class_getInstanceMethod($0, runtimeSelector)
    }
    var details = [
      "mechanism": "notes_framework",
      "operation": operation,
      "native_class": runtimeClass.map(NSStringFromClass) ?? owner,
      "native_selector": selector,
      "method_scope": scope.rawValue,
      "expected_return": returnType,
      "expected_arguments": (["@", ":"] + argumentTypes).joined(separator: ","),
    ]
    guard let method else {
      details["reason"] = runtimeClass == nil ? "class_unavailable" : "method_unavailable"
      throw CLIError(code: .backendUnavailable,
        message: "Notes framework method is unavailable.", details: details)
    }
    let copiedReturn = method_copyReturnType(method)
    let actualReturn = String(cString: copiedReturn)
    free(copiedReturn)
    let actualArguments = (0..<method_getNumberOfArguments(method)).map { index in
      guard let pointer = method_copyArgumentType(method, index) else { return "<missing>" }
      defer { free(pointer) }
      return String(cString: pointer)
    }
    details["actual_return"] = actualReturn
    details["actual_arguments"] = actualArguments.joined(separator: ",")
    guard Self.abiType(actualReturn) == Self.abiType(returnType),
      actualArguments.map(Self.abiType) == (["@", ":"] + argumentTypes).map(Self.abiType)
    else {
      details["reason"] = "signature_mismatch"
      throw CLIError(code: .backendUnavailable,
        message: "Notes framework method has an incompatible signature.", details: details)
    }
  }

  private static func abiType(_ encoding: String) -> String {
    let type = encoding.drop { "rnNoORV".contains($0) }
    if type.first == "^" { return "^" + abiType(String(type.dropFirst())) }
    if type.hasPrefix("@\""), type.hasSuffix("\"") { return "@" }
    return String(type)
  }
}
