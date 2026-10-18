import CoreData
import Foundation
import NotesShared
import NotesSupport
import Utility

enum NotesContextBootstrapStep: Equatable, Sendable {
  case shared, start, create
}

func notesBootstrapContext<Context>(
  require: (NotesContextBootstrapStep) throws -> Void,
  shared: () -> Context?, start: () -> Void, create: () -> Context?
) throws -> Context? {
  try require(.shared)
  if let context = shared() { return context }
  try require(.start)
  start()
  try require(.shared)
  if let context = shared() { return context }
  try require(.create)
  return create()
}

enum NotesNativeContext {
  static let noteSave = NotesRuntimeMethod(owner: "ICNote", selector: "save", returnType: "v")
  static let managedContext = NotesRuntimeMethod(
    owner: "ICNoteContext", selector: "managedObjectContext", returnType: "@")
  static let contextSave = NotesRuntimeMethod(
    owner: "ICNoteContext", selector: "save:", returnType: "B", argumentTypes: ["^@"])
  static let managedSave = NotesRuntimeMethod(
    owner: "NSManagedObjectContext", selector: "ic_save", returnType: "B")

  static func open(requiresSave: Bool = false) throws -> ICNoteContext {
    let operation = "notes.context.open"
    let context: ICNoteContext? = try notesBootstrapContext(
      require: { step in
        let method: NotesRuntimeMethod = switch step {
        case .shared:
          NotesRuntimeMethod(owner: "ICNoteContext", selector: "sharedContext",
            scope: .classMethod, returnType: "@")
        case .start:
          NotesRuntimeMethod(owner: "ICNoteContext", selector: "startSharedContextWithOptions:",
            scope: .classMethod, returnType: "v", argumentTypes: ["Q"])
        case .create:
          NotesRuntimeMethod(owner: "ICNoteContext", selector: "initWithOptions:",
            returnType: "@", argumentTypes: ["Q"])
        }
        try method.require(operation: operation)
      },
      shared: { ICNoteContext.sharedContext() as? ICNoteContext },
      start: { ICNoteContext.startSharedContext(withOptions: 0) },
      create: { ICNoteContext(options: 0) }
    )
    guard let context else {
      throw CLIError(code: .backendUnavailable,
        message: "Notes private framework context could not be started.")
    }
    try managedContext.require(operation: operation, receiver: context)
    if requiresSave { try preflightSave(context, operation: operation) }
    return context
  }

  static func preflightSave(_ context: ICNoteContext, operation: String) throws {
    try contextSave.require(operation: operation, receiver: context)
    try managedContext.require(operation: operation, receiver: context)
    if let managedObjectContext = context.managedObjectContext {
      try managedSave.require(operation: operation, receiver: managedObjectContext)
    }
  }
}
