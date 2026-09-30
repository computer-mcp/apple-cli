import CryptoKit
import Foundation
import Utility

enum PhotosGate: String, Sendable {
  case boundedRead = "bounded-read"
  case dryRun
  case strongGate = "strong-gate"
  case proofFailed = "proof-failed"
}

func validatePhotosReadOnly(_ options: CLIOptions) throws {
  if options.dryRun {
    throw CLIError(
      code: .validationError,
      message:
        "`--dry-run` is only valid for mutation, external-action, or strong-gate commands."
    )
  }
}

func validatePhotosDryRunOptions(_ options: CLIOptions) throws {}

func validatePhotosDryRunIntent(_ options: CLIOptions, description: String) throws {}

func validatePhotosTargetOptions(
  _ options: CLIOptions,
  allowedOptions: Set<String>,
  allowedFlags: Set<String> = []
) throws {
  let unknownOptions = Set(options.targetOptions.keys).subtracting(allowedOptions)
  let unknownFlags = options.targetFlags.subtracting(allowedFlags)
  if !unknownOptions.isEmpty || !unknownFlags.isEmpty {
    let unsupported = (unknownOptions.map { "--\($0)" } + unknownFlags.map { "--\($0)" }).sorted()
    throw CLIError(
      code: .validationError,
      message: "Unsupported option for this command.",
      details: ["options": unsupported.joined(separator: ",")]
    )
  }
}

func photosRequiredOption(_ name: String, options: CLIOptions) throws -> String {
  guard let value = options.targetOption(name)?.trimmingCharacters(in: .whitespacesAndNewlines),
    !value.isEmpty
  else {
    throw CLIError(code: .validationError, message: "`--\(name)` is required.")
  }
  return value
}

func photosOptionalPositiveInt(_ name: String, options: CLIOptions) throws -> Int? {
  guard let value = options.targetOption(name) else {
    return nil
  }
  return try photosPositiveInt(value, flag: "--\(name)")
}

func photosRequiredPositiveInt(_ name: String, options: CLIOptions) throws -> Int {
  try photosPositiveInt(try photosRequiredOption(name, options: options), flag: "--\(name)")
}

func photosPositiveInt(_ value: String, flag: String) throws -> Int {
  guard let parsed = Int(value), parsed > 0 else {
    throw CLIError(code: .validationError, message: "`\(flag)` requires a positive integer value.")
  }
  return parsed
}

func photosOptionalNonNegativeInt(_ name: String, options: CLIOptions) throws -> Int? {
  guard let value = options.targetOption(name) else {
    return nil
  }
  guard let parsed = Int(value), parsed >= 0 else {
    throw CLIError(
      code: .validationError,
      message: "`--\(name)` requires a non-negative integer value."
    )
  }
  return parsed
}

func photosOptionalDouble(_ name: String, options: CLIOptions) throws -> Double? {
  guard let value = options.targetOption(name) else {
    return nil
  }
  guard let parsed = Double(value), parsed.isFinite else {
    throw CLIError(
      code: .validationError,
      message: "`--\(name)` requires a finite number."
    )
  }
  return parsed
}

func photosJPEGExtension(_ value: String) throws -> String {
  let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  let allowed = CharacterSet.alphanumerics
  guard !normalized.isEmpty,
    !normalized.hasPrefix("."),
    normalized.rangeOfCharacter(from: allowed.inverted) == nil
  else {
    throw CLIError(
      code: .validationError,
      message:
        "`--jpeg-extension` must be a non-empty alphanumeric extension without a leading dot."
    )
  }
  return normalized
}

func photosMaxBytes(_ options: CLIOptions, default defaultValue: Int = 16 * 1024) throws -> Int {
  guard let value = options.targetOption("max-bytes") else {
    return defaultValue
  }
  let parsed = try photosPositiveInt(value, flag: "--max-bytes")
  guard parsed <= 4 * 1024 * 1024 else {
    throw CLIError(code: .validationError, message: "`--max-bytes` cannot exceed 4194304.")
  }
  return parsed
}

func photosTimeoutSeconds(_ options: CLIOptions, default defaultValue: Int = 10) throws -> Int {
  guard let value = options.targetOption("timeout-seconds") else {
    return defaultValue
  }
  let parsed = try photosPositiveInt(value, flag: "--timeout-seconds")
  guard parsed <= 300 else {
    throw CLIError(code: .validationError, message: "`--timeout-seconds` cannot exceed 300.")
  }
  return parsed
}

func photosOutputCap(_ options: CLIOptions, default defaultValue: Int = 64 * 1024) throws -> Int {
  guard let value = options.targetOption("output-cap") else {
    return defaultValue
  }
  let parsed = try photosPositiveInt(value, flag: "--output-cap")
  guard parsed <= 4 * 1024 * 1024 else {
    throw CLIError(code: .validationError, message: "`--output-cap` cannot exceed 4194304.")
  }
  return parsed
}

func photosRequireFlag(_ flag: String, options: CLIOptions) throws {
  guard options.hasTargetFlag(flag) else {
    throw CLIError(
      code: .validationError,
      message: "`--\(flag)` is required for this strong-gate command.",
      details: ["gate": PhotosGate.strongGate.rawValue]
    )
  }
}

func photosProofFailed(_ command: String, reason: String) -> CLIError {
  CLIError(
    code: .unsupportedOperation,
    message: "Photos proof failed for this command.",
    details: [
      "command": command, "proof_status": PhotosGate.proofFailed.rawValue, "reason": reason,
    ]
  )
}

func photosSHA256Hex(_ value: String) -> String {
  let digest = SHA256.hash(data: Data(value.utf8))
  return digest.map { String(format: "%02x", $0) }.joined()
}

func photosListOption(_ name: String, options: CLIOptions) -> [String] {
  guard let raw = options.targetOption(name), !raw.isEmpty else {
    return []
  }
  return
    raw
    .split(whereSeparator: { $0 == "," || $0 == "\n" })
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }
}

func photosRepeatedOption(_ name: String, options: CLIOptions) -> [String] {
  guard let raw = options.targetOption(name), !raw.isEmpty else {
    return []
  }
  return
    raw
    .split(whereSeparator: \.isNewline)
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }
}

func photosExifPredicates(from values: [String]) throws -> [PhotosExifPredicate] {
  try values.map { raw in
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    let parts: (String, String)?
    if let separator = trimmed.firstIndex(of: "=") {
      parts = (
        String(trimmed[..<separator]),
        String(trimmed[trimmed.index(after: separator)...])
      )
    } else if let separator = trimmed.firstIndex(where: \.isWhitespace) {
      parts = (
        String(trimmed[..<separator]),
        String(trimmed[separator...]).trimmingCharacters(in: .whitespacesAndNewlines)
      )
    } else {
      parts = nil
    }

    guard
      let (tag, value) = parts,
      !tag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
      !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
      throw CLIError(
        code: .validationError,
        message: "`--exif` requires `TAG=VALUE` or `TAG VALUE`."
      )
    }

    return PhotosExifPredicate(
      tag: tag.trimmingCharacters(in: .whitespacesAndNewlines),
      value: value.trimmingCharacters(in: .whitespacesAndNewlines)
    )
  }
}

func photosUUIDList(options: CLIOptions) throws -> [String] {
  try photosUUIDList(option: "uuid", fileOption: "uuid-from-file", options: options)
}

func photosSkipUUIDList(options: CLIOptions) throws -> [String] {
  try photosUUIDList(option: "skip-uuid", fileOption: "skip-uuid-from-file", options: options)
}

private func photosUUIDList(option: String, fileOption: String, options: CLIOptions) throws
  -> [String]
{
  var uuids = photosListOption(option, options: options).map(photosNormalizeUUIDSelector)
  if let source = options.targetOption(fileOption)?.trimmingCharacters(
    in: .whitespacesAndNewlines),
    !source.isEmpty
  {
    let contents: String
    if source == "-" {
      let data = FileHandle.standardInput.readDataToEndOfFile()
      guard let decoded = String(data: data, encoding: .utf8) else {
        throw CLIError(
          code: .validationError,
          message: "`--\(fileOption) -` requires UTF-8 input."
        )
      }
      contents = decoded
    } else {
      guard FileManager.default.fileExists(atPath: source) else {
        throw CLIError(
          code: .notFound,
          message: "UUID selector file was not found.",
          details: ["path": source]
        )
      }
      do {
        contents = try String(contentsOfFile: source, encoding: .utf8)
      } catch {
        throw CLIError(
          code: .permissionDenied,
          message: CLIPermissionWording.fileNotReadable(resource: "UUID selector file"),
          details: ["path": source, "error": String(describing: error)]
        )
      }
    }
    uuids.append(contentsOf: photosUUIDLines(contents).map(photosNormalizeUUIDSelector))
  }

  var seen: Set<String> = []
  return uuids.filter { uuid in
    guard !seen.contains(uuid) else {
      return false
    }
    seen.insert(uuid)
    return true
  }
}

private func photosUUIDLines(_ contents: String) -> [String] {
  contents
    .split(whereSeparator: \.isNewline)
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty && !$0.hasPrefix("#") }
}

private func photosNormalizeUUIDSelector(_ value: String) -> String {
  let standardUUIDPattern =
    #"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"#
  if value.range(of: standardUUIDPattern, options: .regularExpression) != nil {
    return value.uppercased()
  }
  return value
}

func photosTraitListOption(_ name: String, options: CLIOptions) -> [String] {
  photosListOption(name, options: options).map(photosNormalizedTrait)
}

func photosNormalizedTrait(_ value: String) -> String {
  value
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .lowercased()
    .replacingOccurrences(of: "_", with: "-")
}

func photosIncludeOptions(_ options: CLIOptions, allowed: Set<String>) throws -> Set<String> {
  guard let value = options.targetOption("include"), !value.isEmpty else {
    return []
  }
  let parts = value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
  let include = Set(parts)
  guard include.isSubset(of: allowed) else {
    throw CLIError(
      code: .validationError,
      message: "`--include` contains unsupported values.",
      details: ["include": parts.joined(separator: ",")]
    )
  }
  return include
}

func photosBoolOption(_ name: String, options: CLIOptions) -> Bool? {
  guard let value = options.targetOption(name) else {
    return nil
  }
  switch value.lowercased() {
  case "true", "yes", "1":
    return true
  case "false", "no", "0":
    return false
  default:
    return nil
  }
}

func validatePhotosQueryFlagPairs(_ options: CLIOptions) throws {
  let pairs = [
    ("favorite", "not-favorite"),
    ("hidden", "not-hidden"),
    ("shared", "not-shared"),
    ("icloud", "not-icloud"),
    ("incloud", "not-incloud"),
    ("syndicated", "not-syndicated"),
    ("saved-to-library", "not-saved-to-library"),
    ("shared-moment", "not-shared-moment"),
    ("shared-library", "not-shared-library"),
    ("has-comment", "no-comment"),
    ("has-likes", "no-likes"),
    ("in-album", "not-in-album"),
    ("edited", "not-edited"),
    ("external-edit", "not-external-edit"),
    ("duplicate", "not-duplicate"),
    ("missing", "not-missing"),
    ("has-location", "no-location"),
  ]
  for (positive, negative) in pairs
  where options.hasTargetFlag(positive) && options.hasTargetFlag(negative) {
    throw CLIError(
      code: .validationError,
      message: "`--\(positive)` cannot be combined with `--\(negative)`."
    )
  }
}

func validatePhotosQueryValues(_ options: CLIOptions) throws {
  let exclusiveOptionFlags = [
    ("keyword", "no-keyword"),
    ("title", "no-title"),
    ("description", "no-description"),
    ("place", "no-place"),
  ]
  for (option, flag) in exclusiveOptionFlags
  where options.targetOption(option) != nil && options.hasTargetFlag(flag) {
    throw CLIError(
      code: .validationError,
      message: "`--\(option)` cannot be combined with `--\(flag)`."
    )
  }
  if options.hasTargetFlag("only-photos") && options.hasTargetFlag("only-movies") {
    throw CLIError(
      code: .validationError,
      message: "`--only-photos` cannot be combined with `--only-movies`."
    )
  }
  if options.targetOption("media-type") != nil,
    options.hasTargetFlag("only-photos") || options.hasTargetFlag("only-movies")
  {
    throw CLIError(
      code: .validationError,
      message: "`--media-type` cannot be combined with `--only-photos` or `--only-movies`."
    )
  }

  for name in ["from-time", "to-time"] {
    guard let value = options.targetOption(name), photosValidTimeOfDay(value) == false else {
      continue
    }
    throw CLIError(
      code: .validationError,
      message: "`--\(name)` requires HH:mm or HH:mm:ss in 24-hour time."
    )
  }
  if let pattern = options.targetOption("regex") {
    do {
      _ = try NSRegularExpression(pattern: pattern)
    } catch {
      throw CLIError(
        code: .validationError,
        message: "`--regex` must be a valid ICU regular expression.",
        details: ["error": String(describing: error)]
      )
    }
  }
  let allowedRegexFields: Set<String> = [
    "uuid", "filename", "title", "description", "keyword", "person", "album", "folder",
    "media-type", "uti", "trait",
  ]
  let regexFields = Set(photosListOption("regex-field", options: options))
  if !regexFields.isSubset(of: allowedRegexFields) {
    throw CLIError(
      code: .validationError,
      message: "`--regex-field` contains unsupported fields.",
      details: ["allowed": allowedRegexFields.sorted().joined(separator: ",")]
    )
  }
  if let addedInLast = options.targetOption("added-in-last"),
    photosTimeInterval(from: addedInLast) == nil
  {
    throw CLIError(
      code: .validationError,
      message: "`--added-in-last` requires a positive duration such as `7d`, `1 week`, or `12 hrs`."
    )
  }
  _ = try photosExifPredicates(from: photosRepeatedOption("exif", options: options))
}

private func photosValidTimeOfDay(_ value: String) -> Bool {
  let parts = value.split(separator: ":").compactMap { Int($0) }
  guard parts.count == 2 || parts.count == 3 else {
    return false
  }
  let hour = parts[0]
  let minute = parts[1]
  let second = parts.count == 3 ? parts[2] : 0
  return (0..<24).contains(hour) && (0..<60).contains(minute) && (0..<60).contains(second)
}

func photosTimeInterval(from value: String) -> TimeInterval? {
  let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  guard !trimmed.isEmpty else {
    return nil
  }

  let timeParts = trimmed.split(separator: ":")
  if timeParts.count == 2 || timeParts.count == 3 {
    let parts = timeParts.compactMap(Double.init)
    guard parts.count == timeParts.count else {
      return nil
    }
    let seconds = parts[0] * 3600 + parts[1] * 60 + (parts.count == 3 ? parts[2] : 0)
    return seconds > 0 ? seconds : nil
  }

  var number = ""
  var unit = ""
  for character in trimmed {
    if character.isNumber || character == "." {
      number.append(character)
    } else if character.isLetter {
      unit.append(character)
    } else if character.isWhitespace {
      continue
    } else {
      return nil
    }
  }
  guard let amount = Double(number), amount > 0 else {
    return nil
  }

  switch unit {
  case "", "s", "sec", "secs", "second", "seconds":
    return amount
  case "m", "min", "mins", "minute", "minutes":
    return amount * 60
  case "h", "hr", "hrs", "hour", "hours":
    return amount * 60 * 60
  case "d", "day", "days":
    return amount * 24 * 60 * 60
  case "w", "wk", "wks", "week", "weeks":
    return amount * 7 * 24 * 60 * 60
  case "mo", "mon", "month", "months":
    return amount * 30 * 24 * 60 * 60
  case "y", "yr", "yrs", "year", "years":
    return amount * 365 * 24 * 60 * 60
  default:
    return nil
  }
}

func photosQuery(from options: CLIOptions) throws -> PhotosQuery {
  PhotosQuery(
    libraryPath: options.targetOption("library"),
    albums: photosRepeatedOption("album", options: options)
      + photosRepeatedOption("album-id", options: options),
    folders: photosRepeatedOption("folder", options: options)
      + photosRepeatedOption("folder-id", options: options),
    uuids: try photosUUIDList(options: options),
    keywords: photosListOption("keyword", options: options),
    persons: photosListOption("person", options: options),
    titles: photosListOption("title", options: options),
    descriptions: photosListOption("description", options: options),
    noKeyword: options.hasTargetFlag("no-keyword"),
    noTitle: options.hasTargetFlag("no-title"),
    noDescription: options.hasTargetFlag("no-description"),
    filenames: photosRepeatedOption("filename", options: options),
    originalPath: options.targetOption("original-path"),
    places: photosRepeatedOption("place", options: options),
    noPlace: options.hasTargetFlag("no-place"),
    location: options.targetOption("location"),
    hasLocation: photosFlagState(
      positive: "has-location", negative: "no-location", options: options),
    label: options.targetOption("label"),
    regex: options.targetOption("regex"),
    regexFields: photosListOption("regex-field", options: options),
    ignoreCase: options.hasTargetFlag("ignore-case"),
    newestFirst: options.hasTargetFlag("newest-first"),
    uti: options.targetOption("uti"),
    mediaType: photosMediaType(from: options),
    dateFrom: options.targetOption("date-from"),
    dateTo: options.targetOption("date-to"),
    years: photosListOption("year", options: options).compactMap(Int.init),
    timeFrom: options.targetOption("from-time"),
    timeTo: options.targetOption("to-time"),
    dateAddedFrom: options.targetOption("date-added-from"),
    dateAddedTo: options.targetOption("date-added-to"),
    addedAfter: options.targetOption("added-after"),
    addedBefore: options.targetOption("added-before"),
    addedInLast: options.targetOption("added-in-last"),
    minSize: options.targetOption("min-size").flatMap(Int64.init),
    maxSize: options.targetOption("max-size").flatMap(Int64.init),
    traits: photosTraitListOption("trait", options: options),
    excludedTraits: photosTraitListOption("not-trait", options: options),
    favorite: photosFlagState(positive: "favorite", negative: "not-favorite", options: options),
    hidden: photosFlagState(positive: "hidden", negative: "not-hidden", options: options),
    shared: photosFlagState(positive: "shared", negative: "not-shared", options: options),
    iCloud: photosFlagState(positive: "icloud", negative: "not-icloud", options: options),
    inCloud: photosFlagState(positive: "incloud", negative: "not-incloud", options: options),
    syndicated: photosFlagState(
      positive: "syndicated", negative: "not-syndicated", options: options),
    savedToLibrary: photosFlagState(
      positive: "saved-to-library", negative: "not-saved-to-library", options: options),
    sharedMoment: photosFlagState(
      positive: "shared-moment", negative: "not-shared-moment", options: options),
    sharedLibrary: photosFlagState(
      positive: "shared-library", negative: "not-shared-library", options: options),
    hasComment: photosFlagState(positive: "has-comment", negative: "no-comment", options: options),
    hasLikes: photosFlagState(positive: "has-likes", negative: "no-likes", options: options),
    inAlbum: photosFlagState(positive: "in-album", negative: "not-in-album", options: options),
    edited: photosFlagState(positive: "edited", negative: "not-edited", options: options),
    externalEdit: photosFlagState(
      positive: "external-edit",
      negative: "not-external-edit",
      options: options
    ),
    duplicate: photosFlagState(positive: "duplicate", negative: "not-duplicate", options: options),
    missing: photosFlagState(positive: "missing", negative: "not-missing", options: options),
    exif: try photosExifPredicates(from: photosRepeatedOption("exif", options: options)),
    selected: options.hasTargetFlag("selected"),
    limit: options.limit
  )
}

private func photosMediaType(from options: CLIOptions) -> String? {
  if options.hasTargetFlag("only-photos") {
    return "image"
  }
  if options.hasTargetFlag("only-movies") {
    return "video"
  }
  return options.targetOption("media-type")
}

func photosFlagState(positive: String, negative: String, options: CLIOptions) -> Bool? {
  if options.hasTargetFlag(positive) {
    return true
  }
  if options.hasTargetFlag(negative) {
    return false
  }
  return photosBoolOption(positive, options: options)
}

func validatePhotosExclusiveFlags(_ first: String, _ second: String, options: CLIOptions) throws {
  guard options.hasTargetFlag(first) && options.hasTargetFlag(second) else {
    return
  }
  throw CLIError(
    code: .validationError,
    message: "`--\(first)` and `--\(second)` cannot be used together."
  )
}

func photosQuerySummary(_ query: PhotosQuery) -> [String: String] {
  var summary: [String: String] = [:]
  if let libraryPath = query.libraryPath {
    summary["library_sha256"] = photosSHA256Hex(libraryPath)
  }
  if !query.albums.isEmpty {
    summary["album"] = query.albums.joined(separator: ",")
  }
  if !query.folders.isEmpty {
    summary["folder"] = query.folders.joined(separator: ",")
  }
  if !query.uuids.isEmpty {
    summary["uuid_sha256"] = photosSHA256Hex(query.uuids.joined(separator: ","))
  }
  if !query.keywords.isEmpty {
    summary["keyword"] = query.keywords.joined(separator: ",")
  }
  if !query.persons.isEmpty {
    summary["person"] = query.persons.joined(separator: ",")
  }
  if !query.titles.isEmpty {
    summary["title"] = query.titles.joined(separator: ",")
  }
  if !query.descriptions.isEmpty {
    summary["description"] = query.descriptions.joined(separator: ",")
  }
  if let mediaType = query.mediaType {
    summary["media_type"] = mediaType
  }
  if let regex = query.regex {
    summary["regex_sha256"] = photosSHA256Hex(regex)
  }
  if !query.regexFields.isEmpty {
    summary["regex_field"] = query.regexFields.joined(separator: ",")
  }
  if query.ignoreCase {
    summary["ignore_case"] = "true"
  }
  if query.newestFirst {
    summary["newest_first"] = "true"
  }
  if !query.filenames.isEmpty {
    summary["filename"] = query.filenames.joined(separator: ",")
  }
  if let originalPath = query.originalPath {
    summary["original_path_sha256"] = photosSHA256Hex(originalPath)
  }
  if let uti = query.uti {
    summary["uti"] = uti
  }
  if let hasLocation = query.hasLocation {
    summary["has_location"] = "\(hasLocation)"
  }
  if !query.traits.isEmpty {
    summary["trait"] = query.traits.joined(separator: ",")
  }
  if !query.excludedTraits.isEmpty {
    summary["not_trait"] = query.excludedTraits.joined(separator: ",")
  }
  if let dateAddedFrom = query.dateAddedFrom {
    summary["date_added_from"] = dateAddedFrom
  }
  if let dateAddedTo = query.dateAddedTo {
    summary["date_added_to"] = dateAddedTo
  }
  if !query.years.isEmpty {
    summary["year"] = query.years.map(String.init).joined(separator: ",")
  }
  if let timeFrom = query.timeFrom {
    summary["from_time"] = timeFrom
  }
  if let timeTo = query.timeTo {
    summary["to_time"] = timeTo
  }
  if let shared = query.shared {
    summary["shared"] = "\(shared)"
  }
  if let iCloud = query.iCloud {
    summary["icloud"] = "\(iCloud)"
  }
  if let inAlbum = query.inAlbum {
    summary["in_album"] = "\(inAlbum)"
  }
  if !query.exif.isEmpty {
    summary["exif_tag"] = query.exif.map(\.tag).joined(separator: ",")
    summary["exif_value_sha256"] = photosSHA256Hex(query.exif.map(\.value).joined(separator: "\n"))
  }
  if let hasComment = query.hasComment {
    summary["has_comment"] = "\(hasComment)"
  }
  if let hasLikes = query.hasLikes {
    summary["has_likes"] = "\(hasLikes)"
  }
  if query.selected {
    summary["selected"] = "true"
  }
  if let limit = query.limit {
    summary["limit"] = "\(limit)"
  }
  return summary
}

func photosTruncate(_ value: String, maxBytes: Int) -> (String, Bool) {
  let data = Data(value.utf8)
  guard data.count > maxBytes else {
    return (value, false)
  }
  var prefix = data.prefix(maxBytes)
  while String(data: prefix, encoding: .utf8) == nil, !prefix.isEmpty {
    prefix = prefix.dropLast()
  }
  return (String(data: prefix, encoding: .utf8) ?? "", true)
}

func photosRenderTemplate(
  _ template: String,
  item: PhotosMediaItemRecord,
  resourcePath: String? = nil,
  resourceKind: String? = nil,
  additionalValues: [String: [String]] = [:]
) -> String {
  var values = photosTemplateValues(
    item: item, resourcePath: resourcePath, resourceKind: resourceKind)
  for (key, value) in additionalValues {
    values[key] = value
  }
  return photosRenderTemplateString(
    template,
    values: values,
    depth: 0
  )
}

func photosTemplateHookValues(_ values: [String: String]) -> [String: [String]] {
  var templateValues: [String: [String]] = [:]
  for (key, value) in values {
    let normalizedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
    let normalizedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalizedKey.isEmpty, !normalizedValue.isEmpty else {
      continue
    }
    templateValues["hook.\(normalizedKey)"] = [normalizedValue]
  }
  return templateValues
}

private func photosTemplateValues(
  item: PhotosMediaItemRecord,
  resourcePath: String?,
  resourceKind: String?
) -> [String: [String]] {
  let resourceFilename =
    resourcePath.map { URL(fileURLWithPath: $0).lastPathComponent }.flatMap {
      $0.isEmpty ? nil : $0
    }
    ?? item.filename
  let resourceStem = URL(fileURLWithPath: resourceFilename).deletingPathExtension()
    .lastPathComponent
  let resourceExtension = URL(fileURLWithPath: resourceFilename).pathExtension
  let itemStem = URL(fileURLWithPath: item.filename).deletingPathExtension().lastPathComponent

  return [
    "uuid": photosTemplateScalar(item.uuid),
    "id": photosTemplateScalar(item.id),
    "filename": photosTemplateScalar(item.filename),
    "stem": photosTemplateScalar(itemStem),
    "title": photosTemplateScalar(item.title),
    "description": photosTemplateScalar(item.description),
    "media_type": photosTemplateScalar(item.mediaType),
    "date": photosTemplateScalar(photosTemplateDate(item.date)),
    "date_added": photosTemplateScalar(photosTemplateDate(item.dateAdded)),
    "year": photosTemplateScalar(photosTemplateYear(item.date)),
    "month": photosTemplateScalar(photosTemplateDateComponent(item.date, .month)),
    "day": photosTemplateScalar(photosTemplateDateComponent(item.date, .day)),
    "keyword": photosTemplateScalar(item.keywords.first),
    "keywords": item.keywords,
    "person": photosTemplateScalar(item.persons.first),
    "persons": item.persons,
    "album": photosTemplateScalar(item.albumIDs.first),
    "albums": item.albumIDs,
    "folder": photosTemplateScalar(item.folderPaths.first),
    "folders": item.folderPaths,
    "label": photosTemplateScalar(item.labels.first),
    "labels": item.labels,
    "place": photosTemplateScalar(item.placeName ?? item.placeNames.first),
    "places": item.placeNames,
    "favorite": [String(item.favorite)],
    "hidden": [String(item.hidden)],
    "edited": [String(item.edited)],
    "external_edit": [String(item.externalEdit)],
    "missing": [String(item.missingState ?? false)],
    "width": photosTemplateScalar(item.width.map(String.init)),
    "height": photosTemplateScalar(item.height.map(String.init)),
    "size": photosTemplateScalar(item.fileSize.map(String.init)),
    "latitude": photosTemplateScalar(item.location.map { String($0.latitude) }),
    "longitude": photosTemplateScalar(item.location.map { String($0.longitude) }),
    "altitude": photosTemplateScalar(item.location?.altitude.map { String($0) }),
    "uti": photosTemplateScalar(item.uti ?? item.originalUTI),
    "raw_uti": photosTemplateScalar(item.rawUTI),
    "path": photosTemplateScalar(item.originalPath),
    "path_edited": photosTemplateScalar(item.editedPath),
    "edited_path": photosTemplateScalar(item.editedPath),
    "path_live_photo": photosTemplateScalar(item.livePhotoMoviePath),
    "live_photo_path": photosTemplateScalar(item.livePhotoMoviePath),
    "path_edited_live_photo": photosTemplateScalar(item.editedLivePhotoMoviePath),
    "edited_live_photo_path": photosTemplateScalar(item.editedLivePhotoMoviePath),
    "raw_path": photosTemplateScalar(item.rawPath),
    "resource_filename": photosTemplateScalar(resourceFilename),
    "resource_stem": photosTemplateScalar(resourceStem),
    "resource_kind": photosTemplateScalar(resourceKind),
    "ext": photosTemplateScalar(resourceExtension),
    "extension": photosTemplateScalar(resourceExtension),
  ]
}

private func photosRenderTemplateString(
  _ template: String,
  values: [String: [String]],
  depth: Int
) -> String {
  guard depth < 6 else { return template }

  var rendered = ""
  var index = template.startIndex
  while index < template.endIndex {
    guard template[index] == "{" else {
      rendered.append(template[index])
      index = template.index(after: index)
      continue
    }

    let expressionStart = template.index(after: index)
    guard let expressionEnd = photosFindTemplateExpressionEnd(in: template, from: expressionStart)
    else {
      rendered.append(template[index])
      index = template.index(after: index)
      continue
    }

    let expression = String(template[expressionStart..<expressionEnd])
    rendered += photosEvaluateTemplateExpression(expression, values: values, depth: depth)
    index = template.index(after: expressionEnd)
  }
  return rendered
}

private func photosFindTemplateExpressionEnd(in template: String, from start: String.Index)
  -> String.Index?
{
  var depth = 1
  var index = start
  while index < template.endIndex {
    if template[index] == "{" {
      depth += 1
    } else if template[index] == "}" {
      depth -= 1
      if depth == 0 {
        return index
      }
    }
    index = template.index(after: index)
  }
  return nil
}

private func photosEvaluateTemplateExpression(
  _ expression: String,
  values: [String: [String]],
  depth: Int
) -> String {
  let defaultSplit = photosSplitFirstTopLevel(expression, delimiter: ",")
  let body = defaultSplit.head.trimmingCharacters(in: .whitespacesAndNewlines)
  let defaultValue = defaultSplit.tail
  let conditionalSplit = photosSplitFirstTopLevel(body, delimiter: "?")
  let valueSpec = conditionalSplit.head.trimmingCharacters(in: .whitespacesAndNewlines)
  let trueTemplate = conditionalSplit.tail

  let parsed = photosParseTemplateValueSpec(valueSpec)
  let rawValues = values[parsed.field] ?? []
  let filteredValues = photosApplyTemplateFilters(parsed.filters, to: rawValues)

  if let trueTemplate {
    let matched =
      parsed.predicate.map { photosTemplateValues(filteredValues, match: $0) }
      ?? photosTemplateTruthy(filteredValues)
    let branch = matched ? trueTemplate : (defaultValue ?? "")
    return photosRenderTemplateString(branch, values: values, depth: depth + 1)
  }

  var renderedValues = filteredValues
  if let predicate = parsed.predicate, !photosTemplateValues(filteredValues, match: predicate) {
    renderedValues = []
  }

  let rendered = photosJoinTemplateValues(renderedValues)
  if rendered.isEmpty, let defaultValue {
    return photosRenderTemplateString(defaultValue, values: values, depth: depth + 1)
  }
  return rendered
}

private func photosTemplateScalar(_ value: String?) -> [String] {
  guard let value, !value.isEmpty else { return [] }
  return [value]
}

private func photosJoinTemplateValues(_ values: [String]) -> String {
  values.joined(separator: ",")
}

private struct PhotosTemplateValueSpec {
  var field: String
  var filters: [String]
  var predicate: PhotosTemplatePredicate?
}

private func photosParseTemplateValueSpec(_ valueSpec: String) -> PhotosTemplateValueSpec {
  var parts = photosSplitTopLevel(valueSpec, delimiter: "|")
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }
  guard !parts.isEmpty else {
    return PhotosTemplateValueSpec(field: "", filters: [], predicate: nil)
  }

  let first = photosSplitFilterPredicate(parts.removeFirst())
  var field = first.filter
  var filters: [String] = []
  var predicate = first.predicate
  if field.contains(" ") {
    let split = photosSplitFilterPredicate(field)
    field = split.filter
    predicate = split.predicate ?? predicate
  }

  for part in parts {
    let split = photosSplitFilterPredicate(part)
    filters.append(split.filter)
    predicate = split.predicate ?? predicate
  }

  return PhotosTemplateValueSpec(field: field, filters: filters, predicate: predicate)
}

private func photosSplitFilterPredicate(_ value: String) -> (
  filter: String, predicate: PhotosTemplatePredicate?
) {
  guard let space = photosFirstTopLevelWhitespace(in: value) else {
    return (value, nil)
  }

  let filter = String(value[..<space]).trimmingCharacters(in: .whitespacesAndNewlines)
  let predicateText = String(value[value.index(after: space)...])
    .trimmingCharacters(in: .whitespacesAndNewlines)
  return (filter, photosParseTemplatePredicate(predicateText))
}

private func photosFirstTopLevelWhitespace(in value: String) -> String.Index? {
  var parenDepth = 0
  var braceDepth = 0
  var index = value.startIndex
  while index < value.endIndex {
    let character = value[index]
    if character == "(" {
      parenDepth += 1
    } else if character == ")" {
      parenDepth = max(0, parenDepth - 1)
    } else if character == "{" {
      braceDepth += 1
    } else if character == "}" {
      braceDepth = max(0, braceDepth - 1)
    } else if character.isWhitespace, parenDepth == 0, braceDepth == 0 {
      return index
    }
    index = value.index(after: index)
  }
  return nil
}

private struct PhotosTemplatePredicate {
  var operation: String
  var value: String
  var negated: Bool
}

private func photosParseTemplatePredicate(_ text: String) -> PhotosTemplatePredicate? {
  var text = text.trimmingCharacters(in: .whitespacesAndNewlines)
  var negated = false
  if text.hasPrefix("not ") {
    negated = true
    text = String(text.dropFirst(4)).trimmingCharacters(in: .whitespacesAndNewlines)
  }

  for operation in [
    "startswith", "endswith", "contains", "matches", "==", "!=", ">=", "<=", ">", "<",
  ] {
    if text == operation {
      return PhotosTemplatePredicate(operation: operation, value: "", negated: negated)
    }
    if text.hasPrefix(operation + " ") {
      let value = String(text.dropFirst(operation.count + 1))
        .trimmingCharacters(in: .whitespacesAndNewlines)
      return PhotosTemplatePredicate(operation: operation, value: value, negated: negated)
    }
  }
  return nil
}

private func photosApplyTemplateFilters(_ filters: [String], to values: [String]) -> [String] {
  filters.reduce(values) { partial, filter in
    photosApplyTemplateFilter(filter, to: partial)
  }
}

private func photosApplyTemplateFilter(_ filter: String, to values: [String]) -> [String] {
  let parsed = photosParseTemplateFilter(filter)
  let name = parsed.name
  let argument = parsed.argument

  switch name {
  case "lower":
    return values.map { $0.lowercased() }
  case "upper":
    return values.map { $0.uppercased() }
  case "strip":
    return values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
  case "capitalize":
    return values.map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
  case "titlecase":
    return values.map { $0.capitalized }
  case "braces":
    return values.map { "{\($0)}" }
  case "parens":
    return values.map { "(\($0))" }
  case "brackets":
    return values.map { "[\($0)]" }
  case "shell_quote":
    return values.map { "'\($0.replacingOccurrences(of: "'", with: "'\\''"))'" }
  case "split":
    let separator = argument ?? ","
    return values.flatMap { $0.components(separatedBy: separator) }.filter { !$0.isEmpty }
  case "sort":
    return values.sorted()
  case "rsort":
    return values.sorted().reversed()
  case "reverse":
    return values.reversed()
  case "uniq":
    var seen: Set<String> = []
    return values.filter { seen.insert($0).inserted }
  case "join":
    return [values.joined(separator: argument ?? "")]
  case "append", "appends":
    return values.map { $0 + (argument ?? "") }
  case "prepend", "prepends":
    return values.map { (argument ?? "") + $0 }
  case "remove":
    guard let argument else { return values }
    return values.map { $0.replacingOccurrences(of: argument, with: "") }.filter { !$0.isEmpty }
  case "filter":
    guard let argument, let predicate = photosParseTemplatePredicate(argument) else {
      return values
    }
    return values.filter { photosTemplateValue($0, matches: predicate) }
  case "int":
    return values.compactMap { Double($0).map { String(Int($0)) } }
  case "float":
    return values.compactMap { Double($0).map { String($0) } }
  default:
    return values
  }
}

private func photosParseTemplateFilter(_ filter: String) -> (name: String, argument: String?) {
  let trimmed = filter.trimmingCharacters(in: .whitespacesAndNewlines)
  guard let open = trimmed.firstIndex(of: "("), trimmed.last == ")" else {
    return (trimmed, nil)
  }

  let name = String(trimmed[..<open]).trimmingCharacters(in: .whitespacesAndNewlines)
  let argumentStart = trimmed.index(after: open)
  let argumentEnd = trimmed.index(before: trimmed.endIndex)
  let argument = String(trimmed[argumentStart..<argumentEnd])
  return (name, argument)
}

private func photosTemplateTruthy(_ values: [String]) -> Bool {
  values.contains { value in
    let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    return !normalized.isEmpty && normalized != "false" && normalized != "0"
  }
}

private func photosTemplateValues(_ values: [String], match predicate: PhotosTemplatePredicate)
  -> Bool
{
  values.contains { photosTemplateValue($0, matches: predicate) }
}

private func photosTemplateValue(_ value: String, matches predicate: PhotosTemplatePredicate)
  -> Bool
{
  let candidate = value
  let expected = predicate.value
  let matched: Bool

  switch predicate.operation {
  case "startswith":
    matched = candidate.hasPrefix(expected)
  case "endswith":
    matched = candidate.hasSuffix(expected)
  case "contains":
    matched = candidate.contains(expected)
  case "matches":
    matched =
      (try? NSRegularExpression(pattern: expected))
      .map {
        $0.firstMatch(
          in: candidate,
          range: NSRange(candidate.startIndex..<candidate.endIndex, in: candidate)
        ) != nil
      } ?? false
  case "==":
    matched = candidate == expected
  case "!=":
    matched = candidate != expected
  case ">", ">=", "<", "<=":
    guard let left = Double(candidate), let right = Double(expected) else { return false }
    switch predicate.operation {
    case ">": matched = left > right
    case ">=": matched = left >= right
    case "<": matched = left < right
    default: matched = left <= right
    }
  default:
    matched = false
  }

  return predicate.negated ? !matched : matched
}

private func photosSplitFirstTopLevel(_ value: String, delimiter: Character) -> (
  head: String, tail: String?
) {
  var parenDepth = 0
  var braceDepth = 0
  var index = value.startIndex
  while index < value.endIndex {
    let character = value[index]
    if character == "(" {
      parenDepth += 1
    } else if character == ")" {
      parenDepth = max(0, parenDepth - 1)
    } else if character == "{" {
      braceDepth += 1
    } else if character == "}" {
      braceDepth = max(0, braceDepth - 1)
    } else if character == delimiter, parenDepth == 0, braceDepth == 0 {
      return (
        String(value[..<index]),
        String(value[value.index(after: index)...])
      )
    }
    index = value.index(after: index)
  }
  return (value, nil)
}

private func photosSplitTopLevel(_ value: String, delimiter: Character) -> [String] {
  var parts: [String] = []
  var current = ""
  var parenDepth = 0
  var braceDepth = 0

  for character in value {
    if character == "(" {
      parenDepth += 1
    } else if character == ")" {
      parenDepth = max(0, parenDepth - 1)
    } else if character == "{" {
      braceDepth += 1
    } else if character == "}" {
      braceDepth = max(0, braceDepth - 1)
    }

    if character == delimiter, parenDepth == 0, braceDepth == 0 {
      parts.append(current)
      current = ""
    } else {
      current.append(character)
    }
  }

  parts.append(current)
  return parts
}

func photosSanitizedFilename(_ value: String, fallback: String) -> String {
  let sanitized =
    value
    .replacingOccurrences(of: "/", with: "_")
    .replacingOccurrences(of: "\\", with: "_")
    .replacingOccurrences(of: ":", with: "_")
    .replacingOccurrences(of: "\0", with: "")
    .trimmingCharacters(in: .whitespacesAndNewlines)
  if sanitized.isEmpty || sanitized == "." || sanitized == ".." {
    return fallback
  }
  return sanitized
}

func photosSanitizedRelativeDirectory(_ value: String) -> [String] {
  value
    .split(separator: "/", omittingEmptySubsequences: true)
    .map(String.init)
    .map { photosSanitizedFilename($0, fallback: "") }
    .filter { !$0.isEmpty && $0 != "." && $0 != ".." }
}

private func photosTemplateDate(_ date: Date?) -> String {
  date.map { ISO8601DateFormatter().string(from: $0) } ?? ""
}

private func photosTemplateYear(_ date: Date?) -> String {
  photosTemplateDateComponent(date, .year)
}

private func photosTemplateDateComponent(_ date: Date?, _ component: Calendar.Component) -> String {
  guard let date else { return "" }
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
  let value = calendar.component(component, from: date)
  switch component {
  case .month, .day:
    return String(format: "%02d", value)
  default:
    return String(value)
  }
}

func photosDoctorChecks() -> [CLIDoctorCheck] {
  [
    .localPathExists(
      name: "photos_app",
      path: "/System/Applications/Photos.app",
      presentMessage: "Photos app bundle is present.",
      missingMessage: "Photos app bundle was not found at /System/Applications/Photos.app."
    ),
    photosAppBundleMetadataCheck(),
    CLIDoctorCheck(
      name: "photos_backend",
      status: .ok,
      message:
        "Photos uses read-only SQLite snapshots, target-local SDEF actions, file export/sidecar helpers, and gated hook backends."
    ),
    CLIDoctorCheck(
      name: "exiftool",
      status: FileManager.default.isExecutableFile(atPath: "/usr/local/bin/exiftool")
        || FileManager.default.isExecutableFile(atPath: "/opt/homebrew/bin/exiftool")
        ? .ok : .warning,
      message: "exiftool is optional and only required for doctor-gated metadata writer paths."
    ),
  ]
}

public func photosAppBundleMetadataCheck(
  appPath: String = "/System/Applications/Photos.app"
) -> CLIDoctorCheck {
  let url = URL(fileURLWithPath: appPath)
  guard let bundle = Bundle(url: url) else {
    return CLIDoctorCheck(
      name: "photos_app_metadata",
      status: .warning,
      message: "Photos app bundle metadata was not readable.",
      details: ["path": appPath]
    )
  }

  let name = photosBundleString(bundle, keys: ["CFBundleDisplayName", "CFBundleName"])
  let version = photosBundleString(
    bundle, keys: ["CFBundleShortVersionString", "CFBundleVersion"])
  let build = photosBundleString(bundle, keys: ["CFBundleVersion"]) ?? ""
  var details = [
    "path": appPath,
    "bundle_identifier": bundle.bundleIdentifier ?? "",
    "name": name ?? "",
    "version": version ?? "",
    "build": build,
  ]
  details = details.filter { !$0.value.isEmpty }

  guard name != nil, version != nil else {
    return CLIDoctorCheck(
      name: "photos_app_metadata",
      status: .warning,
      message: "Photos app bundle name or version metadata was not readable.",
      details: details
    )
  }

  return CLIDoctorCheck(
    name: "photos_app_metadata",
    status: .ok,
    message: "Photos app bundle name and version metadata are readable.",
    details: details
  )
}

private func photosBundleString(_ bundle: Bundle, keys: [String]) -> String? {
  for key in keys {
    if let value = bundle.object(forInfoDictionaryKey: key) as? String,
      !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    {
      return value
    }
  }
  return nil
}
