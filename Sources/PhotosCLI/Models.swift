import Foundation
import Utility

public struct PhotosLibraryRecord: Codable, Equatable, Sendable {
  public var id: String
  public var name: String
  public var path: String
  public var version: String?
  public var isSystemLibrary: Bool
  public var isLastOpenedLibrary: Bool
  public var databasePath: String?
  public var databaseVersion: String?
  public var modelVersion: String?
  public var photosVersion: String?
  public var counts: [String: Int]?

  public init(
    id: String,
    name: String,
    path: String,
    version: String? = nil,
    isSystemLibrary: Bool = false,
    isLastOpenedLibrary: Bool = false,
    databasePath: String? = nil,
    databaseVersion: String? = nil,
    modelVersion: String? = nil,
    photosVersion: String? = nil,
    counts: [String: Int]? = nil
  ) {
    self.id = id
    self.name = name
    self.path = path
    self.version = version
    self.isSystemLibrary = isSystemLibrary
    self.isLastOpenedLibrary = isLastOpenedLibrary
    self.databasePath = databasePath
    self.databaseVersion = databaseVersion
    self.modelVersion = modelVersion
    self.photosVersion = photosVersion
    self.counts = counts
  }
}

public struct PhotosContainerRecord: Codable, Equatable, Sendable {
  public var id: String
  public var name: String
  public var kind: String
  public var parentID: String?

  public init(id: String, name: String, kind: String, parentID: String? = nil) {
    self.id = id
    self.name = name
    self.kind = kind
    self.parentID = parentID
  }
}

public struct PhotosAlbumRecord: Codable, Equatable, Sendable {
  public var id: String
  public var name: String
  public var parentID: String?
  public var itemCount: Int?
  public var specialKind: String?
  public var mediaItems: [PhotosMediaItemRecord]?

  public init(
    id: String,
    name: String,
    parentID: String? = nil,
    itemCount: Int? = nil,
    specialKind: String? = nil,
    mediaItems: [PhotosMediaItemRecord]? = nil
  ) {
    self.id = id
    self.name = name
    self.parentID = parentID
    self.itemCount = itemCount
    self.specialKind = specialKind
    self.mediaItems = mediaItems
  }
}

public struct PhotosFolderRecord: Codable, Equatable, Sendable {
  public var id: String
  public var name: String
  public var parentID: String?
  public var childCount: Int?
  public var childContainers: [PhotosContainerRecord]?
  public var childAlbums: [PhotosAlbumRecord]?
  public var childFolders: [PhotosFolderRecord]?

  public init(
    id: String,
    name: String,
    parentID: String? = nil,
    childCount: Int? = nil,
    childContainers: [PhotosContainerRecord]? = nil,
    childAlbums: [PhotosAlbumRecord]? = nil,
    childFolders: [PhotosFolderRecord]? = nil
  ) {
    self.id = id
    self.name = name
    self.parentID = parentID
    self.childCount = childCount
    self.childContainers = childContainers
    self.childAlbums = childAlbums
    self.childFolders = childFolders
  }
}

public struct PhotosLocationRecord: Codable, Equatable, Sendable {
  public var latitude: Double
  public var longitude: Double
  public var altitude: Double?

  public init(latitude: Double, longitude: Double, altitude: Double? = nil) {
    self.latitude = latitude
    self.longitude = longitude
    self.altitude = altitude
  }
}

public struct PhotosMediaItemRecord: Codable, Equatable, Sendable {
  public var id: String
  public var uuid: String
  public var filename: String
  public var title: String?
  public var description: String?
  public var mediaType: String
  public var date: Date?
  public var dateAdded: Date?
  public var timeZoneOffsetSeconds: Int?
  public var favorite: Bool
  public var hidden: Bool
  public var keywords: [String]
  public var labels: [String]
  public var persons: [String]
  public var albumIDs: [String]
  public var albumPaths: [String]
  public var folderPaths: [String]
  public var originalPath: String?
  public var width: Int?
  public var height: Int?
  public var fileSize: Int64?
  public var location: PhotosLocationRecord?
  public var hasPlace: Bool
  public var placeName: String?
  public var placeNames: [String]
  public var comments: [PhotosCommentRecord]
  public var likes: [PhotosLikeRecord]
  public var uti: String?
  public var originalUTI: String?
  public var shared: Bool?
  public var iCloud: Bool?
  public var inCloud: Bool?
  public var syndicated: Bool?
  public var savedToLibrary: Bool?
  public var sharedMoment: Bool?
  public var sharedLibrary: Bool?
  public var missingState: Bool?
  public var edited: Bool
  public var externalEdit: Bool
  public var traits: [String]
  public var rawPath: String?
  public var rawUTI: String?
  public var rawOriginal: Bool?
  public var editedPath: String?
  public var livePhotoMoviePath: String?
  public var editedLivePhotoMoviePath: String?
  public var previewPaths: [String]
  public var adjustmentPath: String?
  public var originalAdjustmentPath: String?
  public var exif: [String: String]

  public init(
    id: String,
    uuid: String,
    filename: String,
    title: String? = nil,
    description: String? = nil,
    mediaType: String = "image",
    date: Date? = nil,
    dateAdded: Date? = nil,
    timeZoneOffsetSeconds: Int? = nil,
    favorite: Bool = false,
    hidden: Bool = false,
    keywords: [String] = [],
    labels: [String] = [],
    persons: [String] = [],
    albumIDs: [String] = [],
    albumPaths: [String] = [],
    folderPaths: [String] = [],
    originalPath: String? = nil,
    width: Int? = nil,
    height: Int? = nil,
    fileSize: Int64? = nil,
    location: PhotosLocationRecord? = nil,
    hasPlace: Bool = false,
    placeName: String? = nil,
    placeNames: [String] = [],
    comments: [PhotosCommentRecord] = [],
    likes: [PhotosLikeRecord] = [],
    uti: String? = nil,
    originalUTI: String? = nil,
    shared: Bool? = nil,
    iCloud: Bool? = nil,
    inCloud: Bool? = nil,
    syndicated: Bool? = nil,
    savedToLibrary: Bool? = nil,
    sharedMoment: Bool? = nil,
    sharedLibrary: Bool? = nil,
    missingState: Bool? = nil,
    edited: Bool = false,
    externalEdit: Bool = false,
    traits: [String] = [],
    rawPath: String? = nil,
    rawUTI: String? = nil,
    rawOriginal: Bool? = nil,
    editedPath: String? = nil,
    livePhotoMoviePath: String? = nil,
    editedLivePhotoMoviePath: String? = nil,
    previewPaths: [String] = [],
    adjustmentPath: String? = nil,
    originalAdjustmentPath: String? = nil,
    exif: [String: String] = [:]
  ) {
    self.id = id
    self.uuid = uuid
    self.filename = filename
    self.title = title
    self.description = description
    self.mediaType = mediaType
    self.date = date
    self.dateAdded = dateAdded
    self.timeZoneOffsetSeconds = timeZoneOffsetSeconds
    self.favorite = favorite
    self.hidden = hidden
    self.keywords = keywords
    self.labels = labels
    self.persons = persons
    self.albumIDs = albumIDs
    self.albumPaths = albumPaths
    self.folderPaths = folderPaths
    self.originalPath = originalPath
    self.width = width
    self.height = height
    self.fileSize = fileSize
    self.location = location
    self.hasPlace = hasPlace
    self.placeName = placeName
    self.placeNames = placeNames
    self.comments = comments
    self.likes = likes
    self.uti = uti
    self.originalUTI = originalUTI
    self.shared = shared
    self.iCloud = iCloud
    self.inCloud = inCloud
    self.syndicated = syndicated
    self.savedToLibrary = savedToLibrary
    self.sharedMoment = sharedMoment
    self.sharedLibrary = sharedLibrary
    self.missingState = missingState
    self.edited = edited
    self.externalEdit = externalEdit
    self.traits = traits
    self.rawPath = rawPath
    self.rawUTI = rawUTI
    self.rawOriginal = rawOriginal
    self.editedPath = editedPath
    self.livePhotoMoviePath = livePhotoMoviePath
    self.editedLivePhotoMoviePath = editedLivePhotoMoviePath
    self.previewPaths = previewPaths
    self.adjustmentPath = adjustmentPath
    self.originalAdjustmentPath = originalAdjustmentPath
    self.exif = exif
  }
}

public struct PhotosCommentRecord: Codable, Equatable, Sendable {
  public var date: Date?
  public var user: String?
  public var isMine: Bool
  public var text: String

  public init(date: Date? = nil, user: String? = nil, isMine: Bool = false, text: String) {
    self.date = date
    self.user = user
    self.isMine = isMine
    self.text = text
  }
}

public struct PhotosLikeRecord: Codable, Equatable, Sendable {
  public var date: Date?
  public var user: String?
  public var isMine: Bool

  public init(date: Date? = nil, user: String? = nil, isMine: Bool = false) {
    self.date = date
    self.user = user
    self.isMine = isMine
  }
}

public struct PhotosQuery: Codable, Equatable, Sendable {
  public var libraryPath: String?
  public var album: String?
  public var albums: [String]
  public var folder: String?
  public var folders: [String]
  public var uuids: [String]
  public var keywords: [String]
  public var persons: [String]
  public var titles: [String]
  public var descriptions: [String]
  public var noKeyword: Bool
  public var noTitle: Bool
  public var noDescription: Bool
  public var filename: String?
  public var filenames: [String]
  public var originalPath: String?
  public var places: [String]
  public var noPlace: Bool
  public var location: String?
  public var hasLocation: Bool?
  public var label: String?
  public var regex: String?
  public var regexFields: [String]
  public var ignoreCase: Bool
  public var newestFirst: Bool
  public var uti: String?
  public var mediaType: String?
  public var dateFrom: String?
  public var dateTo: String?
  public var years: [Int]
  public var timeFrom: String?
  public var timeTo: String?
  public var dateAddedFrom: String?
  public var dateAddedTo: String?
  public var addedAfter: String?
  public var addedBefore: String?
  public var addedInLast: String?
  public var minSize: Int64?
  public var maxSize: Int64?
  public var traits: [String]
  public var excludedTraits: [String]
  public var favorite: Bool?
  public var hidden: Bool?
  public var shared: Bool?
  public var iCloud: Bool?
  public var inCloud: Bool?
  public var syndicated: Bool?
  public var savedToLibrary: Bool?
  public var sharedMoment: Bool?
  public var sharedLibrary: Bool?
  public var hasComment: Bool?
  public var hasLikes: Bool?
  public var inAlbum: Bool?
  public var edited: Bool?
  public var externalEdit: Bool?
  public var duplicate: Bool?
  public var missing: Bool?
  public var exif: [PhotosExifPredicate]
  public var selected: Bool
  public var limit: Int?

  public init(
    libraryPath: String? = nil,
    album: String? = nil,
    albums: [String] = [],
    folder: String? = nil,
    folders: [String] = [],
    uuids: [String] = [],
    keyword: String? = nil,
    keywords: [String] = [],
    person: String? = nil,
    persons: [String] = [],
    title: String? = nil,
    titles: [String] = [],
    description: String? = nil,
    descriptions: [String] = [],
    noKeyword: Bool = false,
    noTitle: Bool = false,
    noDescription: Bool = false,
    filename: String? = nil,
    filenames: [String] = [],
    originalPath: String? = nil,
    place: String? = nil,
    places: [String] = [],
    noPlace: Bool = false,
    location: String? = nil,
    hasLocation: Bool? = nil,
    label: String? = nil,
    regex: String? = nil,
    regexFields: [String] = [],
    ignoreCase: Bool = false,
    newestFirst: Bool = false,
    uti: String? = nil,
    mediaType: String? = nil,
    dateFrom: String? = nil,
    dateTo: String? = nil,
    years: [Int] = [],
    timeFrom: String? = nil,
    timeTo: String? = nil,
    dateAddedFrom: String? = nil,
    dateAddedTo: String? = nil,
    addedAfter: String? = nil,
    addedBefore: String? = nil,
    addedInLast: String? = nil,
    minSize: Int64? = nil,
    maxSize: Int64? = nil,
    traits: [String] = [],
    excludedTraits: [String] = [],
    favorite: Bool? = nil,
    hidden: Bool? = nil,
    shared: Bool? = nil,
    iCloud: Bool? = nil,
    inCloud: Bool? = nil,
    syndicated: Bool? = nil,
    savedToLibrary: Bool? = nil,
    sharedMoment: Bool? = nil,
    sharedLibrary: Bool? = nil,
    hasComment: Bool? = nil,
    hasLikes: Bool? = nil,
    inAlbum: Bool? = nil,
    edited: Bool? = nil,
    externalEdit: Bool? = nil,
    duplicate: Bool? = nil,
    missing: Bool? = nil,
    exif: [PhotosExifPredicate] = [],
    selected: Bool = false,
    limit: Int? = nil
  ) {
    self.libraryPath = libraryPath
    self.albums = photosQueryValues(single: album, many: albums)
    self.album = self.albums.first
    self.folders = photosQueryValues(single: folder, many: folders)
    self.folder = self.folders.first
    self.uuids = uuids
    self.keywords = photosQueryValues(single: keyword, many: keywords)
    self.persons = photosQueryValues(single: person, many: persons)
    self.titles = photosQueryValues(single: title, many: titles)
    self.descriptions = photosQueryValues(single: description, many: descriptions)
    self.noKeyword = noKeyword
    self.noTitle = noTitle
    self.noDescription = noDescription
    self.filenames = photosQueryValues(single: filename, many: filenames)
    self.filename = self.filenames.first
    self.originalPath = originalPath
    self.places = photosQueryValues(single: place, many: places)
    self.noPlace = noPlace
    self.location = location
    self.hasLocation = hasLocation
    self.label = label
    self.regex = regex
    self.regexFields = regexFields
    self.ignoreCase = ignoreCase
    self.newestFirst = newestFirst
    self.uti = uti
    self.mediaType = mediaType
    self.dateFrom = dateFrom
    self.dateTo = dateTo
    self.years = years
    self.timeFrom = timeFrom
    self.timeTo = timeTo
    self.dateAddedFrom = dateAddedFrom
    self.dateAddedTo = dateAddedTo
    self.addedAfter = addedAfter
    self.addedBefore = addedBefore
    self.addedInLast = addedInLast
    self.minSize = minSize
    self.maxSize = maxSize
    self.traits = traits
    self.excludedTraits = excludedTraits
    self.favorite = favorite
    self.hidden = hidden
    self.shared = shared
    self.iCloud = iCloud
    self.inCloud = inCloud
    self.syndicated = syndicated
    self.savedToLibrary = savedToLibrary
    self.sharedMoment = sharedMoment
    self.sharedLibrary = sharedLibrary
    self.hasComment = hasComment
    self.hasLikes = hasLikes
    self.inAlbum = inAlbum
    self.edited = edited
    self.externalEdit = externalEdit
    self.duplicate = duplicate
    self.missing = missing
    self.exif = exif
    self.selected = selected
    self.limit = limit
  }
}

public struct PhotosExifPredicate: Codable, Equatable, Sendable {
  public var tag: String
  public var value: String

  public init(tag: String, value: String) {
    self.tag = tag
    self.value = value
  }
}

private func photosQueryValues(single: String?, many: [String]) -> [String] {
  var values = many.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }
  if let single = single?.trimmingCharacters(in: .whitespacesAndNewlines), !single.isEmpty {
    values.insert(single, at: 0)
  }
  return values
}

public struct PhotosExportPlan: Codable, Equatable, Sendable {
  public var query: PhotosQuery
  public var destination: String
  public var options: [String: String]

  public init(query: PhotosQuery, destination: String, options: [String: String] = [:]) {
    self.query = query
    self.destination = destination
    self.options = options
  }
}

public struct PhotosExportResult: Codable, Equatable, Sendable {
  public var exported: Int
  public var skipped: Int
  public var missing: Int
  public var destination: String
  public var reportPath: String?
  public var exportedUUIDs: [String]?
  public var skippedUUIDs: [String]?
  public var missingUUIDs: [String]?
  public var albumAdds: [PhotosExportAlbumAddRecord]?
  public var cleanup: PhotosExportCleanupSummary?
  public var metadataWrites: [PhotosExifWriteRecord]?
  public var fileMetadataWrites: [PhotosFileMetadataWriteRecord]?

  public init(
    exported: Int,
    skipped: Int = 0,
    missing: Int = 0,
    destination: String,
    reportPath: String? = nil,
    exportedUUIDs: [String]? = nil,
    skippedUUIDs: [String]? = nil,
    missingUUIDs: [String]? = nil,
    albumAdds: [PhotosExportAlbumAddRecord]? = nil,
    cleanup: PhotosExportCleanupSummary? = nil,
    metadataWrites: [PhotosExifWriteRecord]? = nil,
    fileMetadataWrites: [PhotosFileMetadataWriteRecord]? = nil
  ) {
    self.exported = exported
    self.skipped = skipped
    self.missing = missing
    self.destination = destination
    self.reportPath = reportPath
    self.exportedUUIDs = exportedUUIDs
    self.skippedUUIDs = skippedUUIDs
    self.missingUUIDs = missingUUIDs
    self.albumAdds = albumAdds
    self.cleanup = cleanup
    self.metadataWrites = metadataWrites
    self.fileMetadataWrites = fileMetadataWrites
  }
}

public struct PhotosExportAlbumAddRecord: Codable, Equatable, Sendable {
  public var category: String
  public var album: String
  public var itemUUIDs: [String]
  public var submitted: Bool
  public var albumCreated: Bool

  public init(
    category: String,
    album: String,
    itemUUIDs: [String],
    submitted: Bool,
    albumCreated: Bool = false
  ) {
    self.category = category
    self.album = album
    self.itemUUIDs = itemUUIDs
    self.submitted = submitted
    self.albumCreated = albumCreated
  }
}

public struct PhotosExportReport: Codable, Equatable, Sendable {
  public var runID: String
  public var exported: Int
  public var skipped: Int
  public var missing: Int
  public var errors: [String]
  public var exportedUUIDs: [String]?
  public var skippedUUIDs: [String]?
  public var missingUUIDs: [String]?
  public var resources: [PhotosExportResourceRecord]?
  public var cleanup: PhotosExportCleanupSummary?
  public var metadataWrites: [PhotosExifWriteRecord]?
  public var fileMetadataWrites: [PhotosFileMetadataWriteRecord]?

  public init(
    runID: String,
    exported: Int,
    skipped: Int = 0,
    missing: Int = 0,
    errors: [String] = [],
    exportedUUIDs: [String]? = nil,
    skippedUUIDs: [String]? = nil,
    missingUUIDs: [String]? = nil,
    resources: [PhotosExportResourceRecord]? = nil,
    cleanup: PhotosExportCleanupSummary? = nil,
    metadataWrites: [PhotosExifWriteRecord]? = nil,
    fileMetadataWrites: [PhotosFileMetadataWriteRecord]? = nil
  ) {
    self.runID = runID
    self.exported = exported
    self.skipped = skipped
    self.missing = missing
    self.errors = errors
    self.exportedUUIDs = exportedUUIDs
    self.skippedUUIDs = skippedUUIDs
    self.missingUUIDs = missingUUIDs
    self.resources = resources
    self.cleanup = cleanup
    self.metadataWrites = metadataWrites
    self.fileMetadataWrites = fileMetadataWrites
  }
}

public struct PhotosExportResourceRecord: Codable, Equatable, Sendable {
  public var uuid: String
  public var kind: String
  public var path: String
  public var sourceSignature: String
  public var destinationSignature: String
  public var semanticSignature: String
  public var exportedAt: String

  public init(
    uuid: String,
    kind: String,
    path: String,
    sourceSignature: String,
    destinationSignature: String,
    semanticSignature: String,
    exportedAt: String
  ) {
    self.uuid = uuid
    self.kind = kind
    self.path = path
    self.sourceSignature = sourceSignature
    self.destinationSignature = destinationSignature
    self.semanticSignature = semanticSignature
    self.exportedAt = exportedAt
  }
}

public struct PhotosExportCleanupSummary: Codable, Equatable, Sendable {
  public var deletedFiles: [String]
  public var deletedDirectories: [String]
  public var commandRuns: [PhotosExportCleanupCommandRun]

  public init(
    deletedFiles: [String] = [],
    deletedDirectories: [String] = [],
    commandRuns: [PhotosExportCleanupCommandRun] = []
  ) {
    self.deletedFiles = deletedFiles
    self.deletedDirectories = deletedDirectories
    self.commandRuns = commandRuns
  }
}

public struct PhotosExportCleanupCommandRun: Codable, Equatable, Sendable {
  public var path: String
  public var command: String
  public var exitCode: Int32

  public init(path: String, command: String, exitCode: Int32) {
    self.path = path
    self.command = command
    self.exitCode = exitCode
  }
}

public struct PhotosExifWriteRecord: Codable, Equatable, Sendable {
  public var path: String
  public var fields: [String]
  public var exitCode: Int32

  public init(path: String, fields: [String], exitCode: Int32) {
    self.path = path
    self.fields = fields
    self.exitCode = exitCode
  }
}

public struct PhotosFileMetadataWriteRecord: Codable, Equatable, Sendable {
  public var path: String
  public var resourceKind: String
  public var finderTags: [String]
  public var xattrs: [String]

  public init(
    path: String,
    resourceKind: String,
    finderTags: [String] = [],
    xattrs: [String] = []
  ) {
    self.path = path
    self.resourceKind = resourceKind
    self.finderTags = finderTags
    self.xattrs = xattrs
  }
}

public struct PhotosLibraryCompareReport: Codable, Equatable, Sendable {
  public var libraryA: String
  public var libraryB: String
  public var onlyInA: [PhotosLibraryCompareEntry]
  public var onlyInB: [PhotosLibraryCompareEntry]
  public var same: [PhotosLibraryComparePair]
  public var different: [PhotosLibraryComparePair]
  public var comparedCount: Int
  public var differenceCount: Int

  public init(
    libraryA: String,
    libraryB: String,
    onlyInA: [PhotosLibraryCompareEntry] = [],
    onlyInB: [PhotosLibraryCompareEntry] = [],
    same: [PhotosLibraryComparePair] = [],
    different: [PhotosLibraryComparePair] = []
  ) {
    self.libraryA = libraryA
    self.libraryB = libraryB
    self.onlyInA = onlyInA
    self.onlyInB = onlyInB
    self.same = same
    self.different = different
    self.comparedCount = onlyInA.count + onlyInB.count + same.count + different.count
    self.differenceCount = onlyInA.count + onlyInB.count + different.count
  }
}

public struct PhotosLibraryCompareEntry: Codable, Equatable, Sendable {
  public var uuid: String
  public var filename: String
  public var signature: String

  public init(uuid: String, filename: String, signature: String) {
    self.uuid = uuid
    self.filename = filename
    self.signature = signature
  }
}

public struct PhotosLibraryComparePair: Codable, Equatable, Sendable {
  public var uuidA: String
  public var uuidB: String
  public var filename: String
  public var signature: String
  public var differences: [String]

  public init(
    uuidA: String,
    uuidB: String,
    filename: String,
    signature: String,
    differences: [String] = []
  ) {
    self.uuidA = uuidA
    self.uuidB = uuidB
    self.filename = filename
    self.signature = signature
    self.differences = differences
  }
}

public struct PhotoHookInput: Codable, Equatable, Sendable {
  public var category: String
  public var photos: [PhotosMediaItemRecord]
  public var exportPlan: PhotosExportPlan?
  public var context: [String: String]

  public init(
    category: String,
    photos: [PhotosMediaItemRecord],
    exportPlan: PhotosExportPlan? = nil,
    context: [String: String] = [:]
  ) {
    self.category = category
    self.photos = photos
    self.exportPlan = exportPlan
    self.context = context
  }
}

public struct PhotoHookOutput: Codable, Equatable, Sendable {
  public var accepted: Bool
  public var values: [String: String]
  public var messages: [String]

  public init(accepted: Bool, values: [String: String] = [:], messages: [String] = []) {
    self.accepted = accepted
    self.values = values
    self.messages = messages
  }
}


public struct PhotosActionResult: Codable, Equatable, Sendable {
  public var operation: String
  public var submitted: Bool
  public var summaryFields: [String: String]

  public init(operation: String, submitted: Bool, summaryFields: [String: String] = [:]) {
    self.operation = operation
    self.submitted = submitted
    self.summaryFields = summaryFields
  }
}

public struct PhotosSlideshowStatus: Codable, Equatable, Sendable {
  public var running: Bool

  public init(running: Bool) {
    self.running = running
  }
}

public struct PhotosMetadataMutationReport: Codable, Equatable, Sendable {
  public var operation: String
  public var query: PhotosQuery?
  public var sourceSHA256: String?
  public var planned: Int
  public var updated: Int
  public var skipped: Int
  public var records: [PhotosMetadataMutationRecord]

  public init(
    operation: String,
    query: PhotosQuery? = nil,
    sourceSHA256: String? = nil,
    records: [PhotosMetadataMutationRecord]
  ) {
    self.operation = operation
    self.query = query
    self.sourceSHA256 = sourceSHA256
    self.planned = records.count
    self.updated = records.filter(\.submitted).count
    self.skipped = records.filter { !$0.submitted }.count
    self.records = records
  }
}

public struct PhotosMetadataMutationRecord: Codable, Equatable, Sendable {
  public var uuid: String
  public var filename: String
  public var fields: [String: String]
  public var submitted: Bool
  public var skippedReason: String?

  public init(
    uuid: String,
    filename: String,
    fields: [String: String],
    submitted: Bool,
    skippedReason: String? = nil
  ) {
    self.uuid = uuid
    self.filename = filename
    self.fields = fields
    self.submitted = submitted
    self.skippedReason = skippedReason
  }
}

public struct PhotosLibrariesResponse: Codable, Equatable, Sendable {
  public var libraries: [PhotosLibraryRecord]
  public var count: Int

  public init(libraries: [PhotosLibraryRecord]) {
    self.libraries = libraries
    self.count = libraries.count
  }
}

public struct PhotosLibraryResponse: Codable, Equatable, Sendable {
  public var library: PhotosLibraryRecord
}

public struct PhotosAlbumsResponse: Codable, Equatable, Sendable {
  public var albums: [PhotosAlbumRecord]
  public var count: Int

  public init(albums: [PhotosAlbumRecord]) {
    self.albums = albums
    self.count = albums.count
  }
}

public struct PhotosAlbumResponse: Codable, Equatable, Sendable {
  public var album: PhotosAlbumRecord
}

public struct PhotosFoldersResponse: Codable, Equatable, Sendable {
  public var folders: [PhotosFolderRecord]
  public var count: Int

  public init(folders: [PhotosFolderRecord]) {
    self.folders = folders
    self.count = folders.count
  }
}

public struct PhotosFolderResponse: Codable, Equatable, Sendable {
  public var folder: PhotosFolderRecord
}

public struct PhotosMediaItemsResponse: Codable, Equatable, Sendable {
  public var items: [PhotosMediaItemRecord]
  public var count: Int
  public var query: PhotosQuery?

  public init(items: [PhotosMediaItemRecord], query: PhotosQuery?) {
    self.items = items
    self.count = items.count
    self.query = query
  }
}

public struct PhotosMediaItemResponse: Codable, Equatable, Sendable {
  public var item: PhotosMediaItemRecord
  public var undoID: String?

  public init(item: PhotosMediaItemRecord, undoID: String? = nil) {
    self.item = item
    self.undoID = undoID
  }
}

public struct PhotosMediaItemsUpdateResponse: Codable, Equatable, Sendable {
  public var items: [PhotosMediaItemRecord]
  public var count: Int
  public var query: PhotosQuery?
  public var undoIDs: [String]
  public var item: PhotosMediaItemRecord?
  public var undoID: String?

  public init(items: [PhotosMediaItemRecord], query: PhotosQuery?, undoIDs: [String] = []) {
    self.items = items
    self.count = items.count
    self.query = query
    self.undoIDs = undoIDs
    self.item = items.count == 1 ? items.first : nil
    self.undoID = undoIDs.count == 1 ? undoIDs.first : nil
  }
}

public struct PhotosMediaItemDumpRecord: Codable, Equatable, Sendable {
  enum CodingKeys: String, CodingKey, CaseIterable {
    case albums, burst, date, dateModified, description, externalEdit, favorite
    case filename, hasAdjustments, hasRaw, hdr, hidden, inCloud, inTrash
    case isCloudAsset, isMissing, isMovie, isPhoto, keywords, latitude, livePhoto
    case longitude, originalFilename, panorama, path, pathEdited, pathLivePhoto
    case pathRaw, persons, portrait, screenRecording, screenshot, selfie, shared
    case slowMo, timeLapse, title, uti, utiRaw, uuid
  }

  public var uuid: String
  public var filename: String
  public var originalFilename: String
  public var date: String?
  public var description: String?
  public var title: String?
  public var keywords: [String]
  public var albums: [String]
  public var persons: [String]
  public var path: String?
  public var isMissing: Bool
  public var hasAdjustments: Bool
  public var externalEdit: Bool
  public var favorite: Bool
  public var hidden: Bool
  public var shared: Bool?
  public var latitude: Double?
  public var longitude: Double?
  public var pathEdited: String?
  public var isPhoto: Bool
  public var isMovie: Bool
  public var uti: String?
  public var burst: Bool
  public var livePhoto: Bool
  public var pathLivePhoto: String?
  public var isCloudAsset: Bool?
  public var inCloud: Bool?
  public var dateModified: String?
  public var portrait: Bool
  public var screenshot: Bool
  public var screenRecording: Bool
  public var slowMo: Bool
  public var timeLapse: Bool
  public var hdr: Bool
  public var selfie: Bool
  public var panorama: Bool
  public var hasRaw: Bool
  public var utiRaw: String?
  public var pathRaw: String?
  public var inTrash: Bool
}

public struct PhotosMediaItemsDumpResponse: Codable, Equatable, Sendable {
  public var query: PhotosQuery?
  public var items: [PhotosMediaItemDumpRecord]
}

public struct PhotosMediaItemInspectionResponse: Codable, Equatable, Sendable {
  public var query: PhotosQuery?
  public var item: PhotosMediaItemRecord
  public var dump: PhotosMediaItemDumpRecord
}

public struct PhotosMetadataValuesResponse: Codable, Equatable, Sendable {
  public var kind: String
  public var values: [String]
  public var counts: [String: Int]

  public init(kind: String, values: [String], counts: [String: Int] = [:]) {
    self.kind = kind
    self.values = values
    self.counts = counts
  }
}

public struct PhotosMetadataAggregate: Codable, Equatable, Sendable {
  public var values: [String]
  public var counts: [String: Int]

  public init(values: [String], counts: [String: Int]) {
    self.values = values
    self.counts = counts
  }
}

public struct PhotosExifReportResponse: Codable, Equatable, Sendable {
  public var query: PhotosQuery?
  public var items: [PhotosExifItemReport]
}

public struct PhotosExifItemReport: Codable, Equatable, Sendable {
  public var uuid: String
  public var filename: String
  public var values: [String: String]

  public init(uuid: String, filename: String, values: [String: String]) {
    self.uuid = uuid
    self.filename = filename
    self.values = values
  }
}

public struct PhotosPushExifReport: Codable, Equatable, Sendable {
  public var operation: String
  public var query: PhotosQuery?
  public var planned: Int
  public var submitted: Int
  public var skipped: Int
  public var records: [PhotosPushExifRecord]

  public init(
    operation: String,
    query: PhotosQuery? = nil,
    records: [PhotosPushExifRecord]
  ) {
    self.operation = operation
    self.query = query
    self.records = records
    self.planned = records.count
    self.submitted = records.filter(\.submitted).count
    self.skipped = records.filter { !$0.submitted }.count
  }
}

public struct PhotosPushExifRecord: Codable, Equatable, Sendable {
  public var uuid: String
  public var filename: String
  public var path: String
  public var fields: [String]
  public var submitted: Bool
  public var skippedReason: String?

  public init(
    uuid: String,
    filename: String,
    path: String,
    fields: [String],
    submitted: Bool,
    skippedReason: String? = nil
  ) {
    self.uuid = uuid
    self.filename = filename
    self.path = path
    self.fields = fields
    self.submitted = submitted
    self.skippedReason = skippedReason
  }
}

public struct PhotosTemplateRenderResponse: Codable, Equatable, Sendable {
  public var rendered: [String]
}

public struct PhotosDatabaseQueryResponse: Codable, Equatable, Sendable {
  public var query: PhotosQuery?
  public var rows: [[String: String]]
}

public struct PhotosDatabaseGrepMatch: Codable, Equatable, Sendable {
  public var table: String
  public var column: String
  public var rowID: String
  public var value: String
  public var truncated: Bool

  public init(
    table: String,
    column: String,
    rowID: String,
    value: String,
    truncated: Bool = false
  ) {
    self.table = table
    self.column = column
    self.rowID = rowID
    self.value = value
    self.truncated = truncated
  }
}

public struct PhotosDatabaseGrepResponse: Codable, Equatable, Sendable {
  public var query: PhotosQuery?
  public var patternSHA256: String
  public var matches: [PhotosDatabaseGrepMatch]
}

public struct PhotosDatabaseDebugDumpSection: Codable, Equatable, Sendable {
  public var name: String
  public var records: [[String: String]]
  public var truncated: Bool

  public init(name: String, records: [[String: String]], truncated: Bool = false) {
    self.name = name
    self.records = records
    self.truncated = truncated
  }
}

public struct PhotosDatabaseDebugDumpResponse: Codable, Equatable, Sendable {
  public var query: PhotosQuery?
  public var sections: [PhotosDatabaseDebugDumpSection]
}

public struct PhotosDatabaseOrphansReport: Codable, Equatable, Sendable {
  public var query: PhotosQuery?
  public var libraryPath: String
  public var records: [PhotosDatabaseOrphanRecord]
  public var truncated: Bool

  public init(
    query: PhotosQuery?,
    libraryPath: String,
    records: [PhotosDatabaseOrphanRecord],
    truncated: Bool = false
  ) {
    self.query = query
    self.libraryPath = libraryPath
    self.records = records
    self.truncated = truncated
  }
}

public struct PhotosDatabaseOrphanRecord: Codable, Equatable, Sendable {
  public var kind: String
  public var resourceKind: String
  public var path: String
  public var relativePath: String?
  public var uuid: String?
  public var filename: String?
  public var reason: String

  public init(
    kind: String,
    resourceKind: String,
    path: String,
    relativePath: String? = nil,
    uuid: String? = nil,
    filename: String? = nil,
    reason: String
  ) {
    self.kind = kind
    self.resourceKind = resourceKind
    self.path = path
    self.relativePath = relativePath
    self.uuid = uuid
    self.filename = filename
    self.reason = reason
  }
}
