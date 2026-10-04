import CoreFoundation
import Foundation
import Testing

func intelligenceCountryUID(_ index: Int) throws -> Any {
  let xml = try PropertyListSerialization.data(
    fromPropertyList: ["reference": ["CF$UID": index]], format: .xml, options: 0)
  let decoded = try #require(
    PropertyListSerialization.propertyList(from: xml, options: [], format: nil) as? [String: Any])
  return try #require(decoded["reference"])
}

func intelligenceCountryUIDIndex(_ value: Any) throws -> Int {
  let uid = try intelligenceCountryUID(0)
  #expect(CFGetTypeID(value as AnyObject) == CFGetTypeID(uid as AnyObject))
  let xml = try PropertyListSerialization.data(
    fromPropertyList: ["reference": value], format: .xml, options: 0)
  let document = try XMLDocument(data: xml, options: [.nodeLoadExternalEntitiesNever])
  let nodes = try document.nodes(forXPath: "/plist/dict/dict[key='CF$UID']/integer")
  let text = try #require(nodes.first?.stringValue)
  return try #require(Int(text))
}

func intelligenceCountryArchiveFixture() throws -> [String: Any] {
  func uid(_ index: Int) throws -> Any { try intelligenceCountryUID(index) }
  func classRecord(_ name: String, _ classes: [String]) -> [String: Any] {
    ["$classname": name, "$classes": classes]
  }
  return [
    "$archiver": "NSKeyedArchiver", "$version": 100_000,
    "$top": ["root": try uid(1), "unrelated": try uid(21)],
    "$objects": [
      "$null",
      ["$class": try uid(20), "Version": 5,
       "CombinedEstimate": try uid(16), "LastKnownCombinedEstimate": try uid(17),
       "LocalEstimates": try uid(2), "LocalCountryEstimatesLocation": try uid(2),
       "LocalCountryEstimatesWiFiAPs": try uid(9), "LocalCountryEstimatesGeoIP": try uid(13),
       "LocalCountryEstimatesNearbyCells": try uid(0), "LocalCountryEstimatesServingCell": try uid(0),
       "PeerEstimates": try uid(18), "LocationInDisputedArea": false],
      ["$class": try uid(8), "NS.objects": [try uid(3)]],
      ["$class": try uid(7), "CountryCode": try uid(4), "Timestamp": try uid(5),
       "Priority": 7, "Disputed": false],
      "CN",
      ["$class": try uid(6), "NS.time": 800_000_000.25],
      classRecord("NSDate", ["NSDate", "NSObject"]),
      classRecord("RDEstimate", ["RDEstimate", "NSObject"]),
      classRecord("NSMutableArray", ["NSMutableArray", "NSArray", "NSObject"]),
      ["$class": try uid(8), "NS.objects": [try uid(10)]],
      ["$class": try uid(7), "CountryCode": try uid(11), "Timestamp": try uid(12),
       "Priority": 3, "Disputed": true],
      "JP",
      ["$class": try uid(6), "NS.time": 799_000_000.5],
      ["$class": try uid(8), "NS.objects": [try uid(14)]],
      ["$class": try uid(7), "CountryCode": try uid(4), "Timestamp": try uid(15),
       "Priority": 4, "Disputed": false],
      ["$class": try uid(6), "NS.time": 798_000_000.75],
      ["$class": try uid(8), "NS.objects": [try uid(3)]],
      ["$class": try uid(8), "NS.objects": [try uid(3)]],
      ["$class": try uid(19), "NS.keys": [], "NS.objects": []],
      classRecord("NSMutableDictionary", ["NSMutableDictionary", "NSDictionary", "NSObject"]),
      classRecord("RDCachedData", ["RDCachedData", "NSObject"]),
      ["CountryCode": "GB", "NonCountryTwoLetter": "CA", "Region": "LL/A", "Language": "en"],
    ],
    "metadata": ["billingCountry": "CA", "Other": "JP"],
  ]
}

func intelligenceCountryArchiveRoot(_ archive: [String: Any]) throws -> [String: Any] {
  let objects = try #require(archive["$objects"] as? [Any])
  let top = try #require(archive["$top"] as? [String: Any])
  let rootIndex = try intelligenceCountryUIDIndex(#require(top["root"]))
  return try #require(objects[rootIndex] as? [String: Any])
}

func intelligenceCountryArchiveCodes(
  _ archive: [String: Any], branch: String = "CombinedEstimate"
) throws -> [String] {
  let objects = try #require(archive["$objects"] as? [Any])
  let root = try intelligenceCountryArchiveRoot(archive)
  let collectionIndex = try intelligenceCountryUIDIndex(#require(root[branch]))
  let collection = try #require(objects[collectionIndex] as? [String: Any])
  let references = try #require(collection["NS.objects"] as? [Any])
  return try references.map {
    let estimate = try #require(objects[intelligenceCountryUIDIndex($0)] as? [String: Any])
    let countryIndex = try intelligenceCountryUIDIndex(#require(estimate["CountryCode"]))
    return try #require(objects[countryIndex] as? String)
  }
}

func intelligenceCountryArchiveComparable(_ archive: [String: Any]) throws -> [String: Any] {
  let uidType = CFGetTypeID(try intelligenceCountryUID(0) as AnyObject)
  func normalized(_ value: Any) throws -> Any {
    if CFGetTypeID(value as AnyObject) == uidType {
      return ["uid_index": try intelligenceCountryUIDIndex(value)]
    }
    if let dictionary = value as? [String: Any] {
      return try dictionary.mapValues(normalized)
    }
    if let array = value as? [Any] { return try array.map(normalized) }
    return value
  }
  return try #require(normalized(archive) as? [String: Any])
}
