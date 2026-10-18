import Foundation
import Utility

public struct MapsCollectionDraft: Equatable, Sendable {
  public var id: UUID
  public var title: String
  public var description: String?
  public var position: Int?
  public init(id: UUID = UUID(), title: String, description: String? = nil, position: Int? = nil) {
    self.id = id
    self.title = title
    self.description = description
    self.position = position
  }
}

public struct MapsCollectionPatch: Equatable, Sendable {
  public var title: String?
  public var description: String?
  public var clearDescription: Bool
  public var position: Int?
  public init(
    title: String? = nil, description: String? = nil, clearDescription: Bool = false,
    position: Int? = nil
  ) {
    self.title = title
    self.description = description
    self.clearDescription = clearDescription
    self.position = position
  }

  func applying(to record: MapsCollectionRecord) -> MapsCollectionRecord {
    var updated = record
    if let title { updated.title = title }
    if let description { updated.description = description }
    if clearDescription { updated.description = nil }
    if let position { updated.position = position }
    return updated
  }
}

public struct MapsCollectionMutationResult: Codable, Equatable, Sendable {
  public var operation: String
  public var changed: Bool
  public var collection: MapsCollectionRecord?
  public var item: MapsCollectionItemRecord?
  public var deletedID: String?
}

public enum MapsCollectionPlaceSource: Equatable, Sendable {
  case identifier(String)
  case coordinate(latitude: Double, longitude: Double)
}

public struct MapsCollectionPlaceDraft: Equatable, Sendable {
  public var id: UUID
  public var source: MapsCollectionPlaceSource
  public var customName: String?
  public var note: String?
  public init(
    id: UUID = UUID(), source: MapsCollectionPlaceSource, customName: String? = nil,
    note: String? = nil
  ) {
    self.id = id
    self.source = source
    self.customName = customName
    self.note = note
  }
}

func validateCollectionPlaceDraft(_ draft: MapsCollectionPlaceDraft) throws {
  guard [draft.customName, draft.note].allSatisfy({ $0?.contains("\0") != true }) else {
    throw CLIError(
      code: .validationError, message: "Saved place text cannot contain NUL characters.")
  }
  switch draft.source {
  case .identifier(let id):
    guard !id.isEmpty, !id.contains("\0"), id == id.trimmingCharacters(in: .whitespacesAndNewlines)
    else {
      throw CLIError(code: .validationError, message: "A native place identifier is required.")
    }
  case .coordinate(let latitude, let longitude):
    guard latitude.isFinite, longitude.isFinite, (-90...90).contains(latitude),
      (-180...180).contains(longitude)
    else {
      throw CLIError(code: .validationError, message: "Saved place coordinates are invalid.")
    }
  }
}

func validateCollectionTitle(_ title: String) throws {
  guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !title.contains("\0") else {
    throw CLIError(
      code: .validationError, message: "A collection title must contain text and no NUL characters."
    )
  }
}

func requireCustomCollection(_ id: UUID) throws {
  // Maps reserves this identity for its built-in Favorites guide.
  guard id != UUID(uuidString: "00000000-0000-0000-0000-000000000001") else {
    throw CLIError(
      code: .unsafeMutationRefused,
      message:
        "Maps manages the built-in Favorites guide. Its name, position and deletion cannot be changed."
    )
  }
}

func validateCollectionPatch(_ patch: MapsCollectionPatch) throws {
  if let title = patch.title { try validateCollectionTitle(title) }
  guard
    patch.title != nil || patch.description != nil || patch.clearDescription
      || patch.position != nil
  else {
    throw CLIError(
      code: .validationError, message: "At least one collection field must be supplied for update.")
  }
  guard patch.description == nil || !patch.clearDescription else {
    throw CLIError(
      code: .validationError,
      message: "`--description` and `--clear-description` are mutually exclusive.")
  }
}

func mapsCollectionMatches(
  _ lhs: MapsCollectionRecord, _ rhs: MapsCollectionRecord,
  ignoringModificationTime: Bool = false
) -> Bool {
  lhs.id == rhs.id && mapsSavedTextMatches(lhs.title, rhs.title)
    && mapsSavedTextMatches(lhs.description, rhs.description)
    && mapsSavedTextMatches(lhs.imageURL, rhs.imageURL) && lhs.position == rhs.position
    && lhs.reportedPlaceCount == rhs.reportedPlaceCount && lhs.createdAt == rhs.createdAt
    && (ignoringModificationTime || lhs.modifiedAt == rhs.modifiedAt)
}

func mapsSavedTextMatches(_ lhs: String?, _ rhs: String?) -> Bool {
  switch (lhs, rhs) {
  case (nil, nil): true
  case (.some(let lhs), .some(let rhs)): lhs.utf8.elementsEqual(rhs.utf8)
  default: false
  }
}

func mapsCollectionItemMatches(_ lhs: MapsCollectionItemRecord, _ rhs: MapsCollectionItemRecord)
  -> Bool
{
  lhs.id == rhs.id && lhs.kind == rhs.kind && lhs.position == rhs.position
    && lhs.createdAt == rhs.createdAt && lhs.modifiedAt == rhs.modifiedAt
    && lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    && mapsSavedTextMatches(lhs.customName, rhs.customName)
    && mapsSavedTextMatches(lhs.placeName, rhs.placeName)
    && mapsSavedTextMatches(lhs.address, rhs.address)
    && mapsSavedTextMatches(lhs.category, rhs.category)
    && mapsSavedTextMatches(lhs.note, rhs.note)
    && mapsSavedTextMatches(lhs.nativeIdentifier, rhs.nativeIdentifier)
    && lhs.transitLineIdentifier == rhs.transitLineIdentifier
}

func mapsCollectionVerificationFailure(_ id: String, reason: String) -> CLIError {
  CLIError(
    code: .backendUnavailable, message: "The saved Maps mutation could not be verified.",
    details: ["id": id, "reason": reason])
}
