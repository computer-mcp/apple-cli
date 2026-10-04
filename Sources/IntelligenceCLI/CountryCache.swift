import CoreFoundation
import Foundation
import Utility

struct IntelligenceCountryCacheRewrite {
  let originalData: Data
  let updatedData: Data
  let changedEstimateCount: Int
  private let expectedValue: CountryArchiveValue
  private let country: String

  init(data: Data, country: String) throws {
    guard try validatedCountryCode(country) == country else {
      throw intelligenceError(code: .validationError, failure: .invalidCountryCode)
    }
    let archive = try CountryArchive(data: data)
    var envelope = archive.envelope
    var objects = archive.objects
    var root = archive.root
    var combined = archive.combined
    var references = archive.estimates
    var replacements: [Int: Int] = [:]
    var countryIndex: Int?
    var changedCount = 0
    for (position, estimateIndex) in archive.estimateIndices.enumerated() {
      let estimate = try archive.dictionary(at: estimateIndex)
      guard try archive.countryCode(in: estimate) != country else { continue }
      changedCount += 1
      if let replacement = replacements[estimateIndex] {
        references[position] = try archive.uid.make(replacement)
        continue
      }
      let destinationCountry: Int
      if let countryIndex {
        destinationCountry = countryIndex
      } else {
        destinationCountry = objects.count
        countryIndex = destinationCountry
        objects.append(country)
      }
      var copy = estimate
      copy["CountryCode"] = try archive.uid.make(destinationCountry)
      let replacement = objects.count
      objects.append(copy)
      replacements[estimateIndex] = replacement
      references[position] = try archive.uid.make(replacement)
    }
    if changedCount > 0 {
      // Existing nodes may also belong to history, local observations, or another top-level root.
      combined["NS.objects"] = references
      let combinedIndex = objects.count
      objects.append(combined)
      root["CombinedEstimate"] = try archive.uid.make(combinedIndex)
      let rootIndex = objects.count
      objects.append(root)
      var top = archive.top
      top["root"] = try archive.uid.make(rootIndex)
      envelope["$top"] = top
      envelope["$objects"] = objects
    }
    let expected = try archive.uid.value(envelope)
    let output = changedCount == 0 ? data : try PropertyListSerialization.data(
      fromPropertyList: envelope, format: .binary, options: 0)
    let decoded = try CountryArchive(data: output)
    guard decoded.value == expected,
      try decoded.activeCountries().allSatisfy({ $0 == country }),
      Array(decoded.objectValues.prefix(archive.objects.count)) == archive.objectValues
    else { throw countryCacheError("copy_preservation_failed") }
    self.originalData = data
    self.updatedData = output
    self.changedEstimateCount = changedCount
    self.expectedValue = expected
    self.country = country
  }

  func verify(_ data: Data) throws {
    do {
      let archive = try CountryArchive(data: data)
      guard archive.value == expectedValue,
        try archive.activeCountries().allSatisfy({ $0 == country })
      else { throw countryCacheError("readback_differs") }
    } catch {
      throw intelligenceError(
        code: .backendUnavailable, failure: .countryCacheVerificationFailed,
        details: ["verification": "unconfirmed"])
    }
  }
}

private struct CountryArchive {
  let uid: CountryArchiveUID
  let envelope: [String: Any]
  let top: [String: Any]
  let objects: [Any]
  let objectValues: [CountryArchiveValue]
  let value: CountryArchiveValue
  let root: [String: Any]
  let combined: [String: Any]
  let estimates: [Any]
  let estimateIndices: [Int]

  init(data: Data) throws {
    guard data.count <= 8 * 1_024 * 1_024 else { throw countryCacheError("archive_size_limit") }
    let uid = try CountryArchiveUID()
    let plist: Any
    do {
      plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
    } catch { throw countryCacheError("invalid_plist") }
    guard let envelope = plist as? [String: Any],
      envelope["$archiver"] as? String == "NSKeyedArchiver",
      countryArchiveInteger(envelope["$version"]) == 100_000,
      let objects = envelope["$objects"] as? [Any],
      (1...4_096).contains(objects.count), objects[0] as? String == "$null",
      let top = envelope["$top"] as? [String: Any], let rootReference = top["root"]
    else { throw countryCacheError("unsupported_archive") }
    let value = try uid.value(envelope)
    let objectValues = try objects.map { try uid.value($0) }
    try validateCountryArchiveGraph(value: value, objects: objectValues)
    let rootIndex = try uid.requiredIndex(rootReference, objectCount: objects.count)
    guard let root = objects[rootIndex] as? [String: Any],
      countryArchiveInteger(root["Version"]) == 5
    else { throw countryCacheError("unsupported_cached_data_version") }
    try validateCountryArchiveClass(root, name: "RDCachedData", objects: objects, uid: uid)
    guard let combinedReference = root["CombinedEstimate"] else {
      throw countryCacheError("missing_combined_estimate")
    }
    let combinedIndex = try uid.requiredIndex(combinedReference, objectCount: objects.count)
    guard let combined = objects[combinedIndex] as? [String: Any],
      let estimates = combined["NS.objects"] as? [Any], !estimates.isEmpty
    else { throw countryCacheError("unavailable_combined_estimate") }
    try validateCountryArchiveClass(combined, name: "NSArray", objects: objects, uid: uid)
    let indices = try estimates.map { try uid.requiredIndex($0, objectCount: objects.count) }
    for index in indices {
      guard let estimate = objects[index] as? [String: Any], let reference = estimate["CountryCode"] else {
        throw countryCacheError("invalid_estimate")
      }
      try validateCountryArchiveClass(estimate, name: "RDEstimate", objects: objects, uid: uid)
      let countryIndex = try uid.requiredIndex(reference, objectCount: objects.count)
      guard let country = objects[countryIndex] as? String, isCountryArchiveCode(country) else {
        throw countryCacheError("invalid_country_field")
      }
    }
    self.uid = uid
    self.envelope = envelope
    self.top = top
    self.objects = objects
    self.value = value
    self.objectValues = objectValues
    self.root = root
    self.combined = combined
    self.estimates = estimates
    self.estimateIndices = indices
  }

  func dictionary(at index: Int) throws -> [String: Any] {
    guard let record = objects[index] as? [String: Any] else { throw countryCacheError("invalid_estimate") }
    return record
  }

  func countryCode(in estimate: [String: Any]) throws -> String {
    guard let reference = estimate["CountryCode"] else { throw countryCacheError("missing_country_field") }
    let index = try uid.requiredIndex(reference, objectCount: objects.count)
    guard let country = objects[index] as? String else { throw countryCacheError("invalid_country_field") }
    return country
  }

  func activeCountries() throws -> [String] {
    try estimateIndices.map { try countryCode(in: dictionary(at: $0)) }
  }
}

private func validateCountryArchiveClass(
  _ record: [String: Any], name: String, objects: [Any], uid: CountryArchiveUID
) throws {
  guard let reference = record["$class"] else { throw countryCacheError("missing_class") }
  let index = try uid.requiredIndex(reference, objectCount: objects.count)
  guard let metadata = objects[index] as? [String: Any],
    let className = metadata["$classname"] as? String, let hierarchy = metadata["$classes"] as? [String]
  else { throw countryCacheError("invalid_class") }
  let expected = name == "NSArray" && className == "NSMutableArray"
    ? ["NSMutableArray", "NSArray", "NSObject"] : [name, "NSObject"]
  guard hierarchy == expected, className == expected.first else {
    throw countryCacheError("unsupported_class")
  }
}

private indirect enum CountryArchiveValue: Equatable {
  case uid(Int), dictionary([String: CountryArchiveValue]), array([CountryArchiveValue])
  case string(String), data(Data), date(Date), boolean(Bool), integer(String), real(UInt64)

  var references: [Int] {
    switch self {
    case .uid(let index): return [index]
    case .dictionary(let values): return values.values.flatMap(\.references)
    case .array(let values): return values.flatMap(\.references)
    default: return []
    }
  }
}

private struct CountryArchiveUID {
  private let typeID: CFTypeID

  init() throws { self.typeID = CFGetTypeID(try Self.create(0) as AnyObject) }
  func make(_ index: Int) throws -> Any { try Self.create(index) }

  private static func create(_ index: Int) throws -> Any {
    guard (0...Int(UInt32.max)).contains(index) else { throw countryCacheError("invalid_uid") }
    // The public plist XML bridge preserves native UIDs without instantiating archived classes.
    let xml = try PropertyListSerialization.data(
      fromPropertyList: ["reference": ["CF$UID": index]], format: .xml, options: 0)
    guard let decoded = try PropertyListSerialization.propertyList(
      from: xml, options: [], format: nil) as? [String: Any], let reference = decoded["reference"],
      !(reference is [String: Any])
    else { throw countryCacheError("uid_codec_unavailable") }
    return reference
  }

  func index(_ object: Any) throws -> Int? {
    guard CFGetTypeID(object as AnyObject) == typeID else { return nil }
    let xml = try PropertyListSerialization.data(
      fromPropertyList: ["reference": object], format: .xml, options: 0)
    let document = try XMLDocument(data: xml, options: [.nodeLoadExternalEntitiesNever])
    let nodes = try document.nodes(forXPath: "/plist/dict/dict[key='CF$UID']/integer")
    guard nodes.count == 1, let text = nodes[0].stringValue, let index = Int(text),
      (0...Int(UInt32.max)).contains(index)
    else { throw countryCacheError("invalid_uid") }
    return index
  }

  func requiredIndex(_ object: Any, objectCount: Int) throws -> Int {
    guard let index = try index(object), (0..<objectCount).contains(index) else {
      throw countryCacheError("invalid_reference")
    }
    return index
  }

  func value(_ object: Any) throws -> CountryArchiveValue {
    var remaining = 100_000
    return try value(object, depth: 0, remaining: &remaining)
  }

  private func value(_ object: Any, depth: Int, remaining: inout Int) throws -> CountryArchiveValue {
    guard depth <= 128, remaining > 0 else { throw countryCacheError("archive_structure_limit") }
    remaining -= 1
    if let index = try index(object) { return .uid(index) }
    if let dictionary = object as? [String: Any] {
      guard dictionary["CF$UID"] == nil else { throw countryCacheError("non_native_uid") }
      var result: [String: CountryArchiveValue] = [:]
      for (key, child) in dictionary {
        result[key] = try value(child, depth: depth + 1, remaining: &remaining)
      }
      return .dictionary(result)
    }
    if let array = object as? [Any] {
      return .array(try array.map { try value($0, depth: depth + 1, remaining: &remaining) })
    }
    if let string = object as? String { return .string(string) }
    if let data = object as? Data { return .data(data) }
    if let date = object as? Date { return .date(date) }
    if let number = object as? NSNumber {
      if CFGetTypeID(number) == CFBooleanGetTypeID() { return .boolean(number.boolValue) }
      if ["d", "f"].contains(String(cString: number.objCType)) {
        guard number.doubleValue.isFinite else { throw countryCacheError("invalid_number") }
        return .real(number.doubleValue.bitPattern)
      }
      return .integer(number.stringValue)
    }
    throw countryCacheError("unsupported_value")
  }
}

private func validateCountryArchiveGraph(value: CountryArchiveValue, objects: [CountryArchiveValue]) throws {
  let edges = objects.map(\.references)
  guard value.references.allSatisfy({ (0..<objects.count).contains($0) }) else {
    throw countryCacheError("dangling_reference")
  }
  var state = [UInt8](repeating: 0, count: objects.count)
  func visit(_ index: Int, depth: Int) throws {
    guard depth <= 128 else { throw countryCacheError("archive_reference_depth_limit") }
    if state[index] == 2 { return }
    guard state[index] == 0 else { throw countryCacheError("cyclic_reference") }
    state[index] = 1
    for reference in edges[index] { try visit(reference, depth: depth + 1) }
    state[index] = 2
  }
  for index in objects.indices { try visit(index, depth: 0) }
}

private func countryArchiveInteger(_ object: Any?) -> Int? {
  guard let number = object as? NSNumber, CFGetTypeID(number) != CFBooleanGetTypeID(),
    !["d", "f"].contains(String(cString: number.objCType))
  else { return nil }
  return Int(number.stringValue)
}

private func isCountryArchiveCode(_ value: String) -> Bool {
  value.utf8.count == 2 && value.utf8.allSatisfy { (65...90).contains($0) }
}

private func countryCacheError(_ reason: String) -> CLIError {
  intelligenceError(
    code: .unsafeMutationRefused, failure: .countryCacheInvalid, details: ["reason": reason])
}
