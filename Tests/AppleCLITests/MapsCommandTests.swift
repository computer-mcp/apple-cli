import Foundation
import MapKit
import Testing
import Utility

@testable import MapsCLI

@Suite
struct MapsCommandTests {
  @Test func mapsPlacesSearchReturnsJSON() throws {
    let reader = FakeMapsReader()
    let command = MapsCommand(reader: reader, opener: FakeMapsOpener())
    let options = try CLIOptionsFixture.parse([
      "places", "search", "--query", "Cupertino", "--kind", "poi",
      "--region-latitude", "37.3349", "--region-longitude", "-122.0090", "--limit", "1", "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let places = data?["places"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(places?.first?["name"] as? String == "Apple Park")
    #expect(data?["returnedByService"] as? Int == 1)
    #expect(data?["truncated"] as? Bool == false)
    #expect(reader.request?.kind == .poi)
    #expect(
      reader.request?.region
        == MapsSearchRegion(latitude: 37.3349, longitude: -122.0090, spanMeters: 10000))
    #expect(reader.request?.limit == 1)
  }

  @Test func mapsPlacesSearchRequiresNonTrivialQuery() throws {
    let command = MapsCommand(reader: FakeMapsReader(), opener: FakeMapsOpener())
    let options = try CLIOptionsFixture.parse(["places", "search", "--query", "a", "--json"])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected short Maps query to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
    #expect(
      throws: CLIError(code: .validationError, message: "`--limit` must be between 1 and 50.")
    ) {
      _ = try command.run(
        options: CLIOptions(
          json: true, limit: 0, targetOptions: ["query": "Cupertino"],
          positionals: ["places", "search"]))
    }
    for extra in [
      ["kind": "coffee"], ["region-latitude": "0"],
      ["region-span-meters": "500"],
      ["region-latitude": "0", "region-longitude": "0", "region-span-meters": "nan"],
    ] {
      #expect(throws: CLIError.self) {
        _ = try command.run(
          options: CLIOptions(
            targetOptions: ["query": "Cupertino"].merging(extra) { _, value in value },
            positionals: ["places", "search"]))
      }
    }
  }

  @Test func mapsPlaceReadValidatesCoordinates() throws {
    let command = MapsCommand(reader: FakeMapsReader(), opener: FakeMapsOpener())
    let options = try CLIOptionsFixture.parse([
      "places",
      "read",
      "--latitude",
      "91",
      "--longitude",
      "0",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected invalid latitude to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func mapsDirectionsPreviewReturnsNoActionURL() throws {
    let command = MapsCommand(reader: FakeMapsReader(), opener: FakeMapsOpener())
    let options = try CLIOptionsFixture.parse([
      "directions",
      "preview",
      "--from",
      "Cupertino",
      "--to",
      "San Francisco",
      "--mode",
      "transit",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let directions = data?["directions"] as? [String: Any]

    #expect(directions?["externalAction"] as? Bool == false)
    #expect(directions?["mode"] as? String == "transit")
    #expect((directions?["mapsURL"] as? String)?.hasPrefix("maps:") == true)
  }

  @Test func mapsDirectionsPreviewAcceptsCoordinateEndpoints() throws {
    let command = MapsCommand(reader: FakeMapsReader(), opener: FakeMapsOpener())
    let options = try CLIOptionsFixture.parse([
      "directions",
      "preview",
      "--from-latitude",
      "37.3318",
      "--from-longitude",
      "-122.0312",
      "--from-name",
      "Home",
      "--to-latitude",
      "37.3349",
      "--to-longitude",
      "-122.0090",
      "--to-name",
      "Apple Park",
      "--json",
    ])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let directions = data?["directions"] as? [String: Any]
    let sourceEndpoint = directions?["sourceEndpoint"] as? [String: Any]
    let destinationEndpoint = directions?["destinationEndpoint"] as? [String: Any]
    let mapsURL = directions?["mapsURL"] as? String

    #expect(directions?["source"] as? String == "Home")
    #expect(directions?["destination"] as? String == "Apple Park")
    #expect(sourceEndpoint?["id"] as? String != nil)
    #expect(sourceEndpoint?["latitude"] as? Double == 37.3318)
    #expect(sourceEndpoint?["longitude"] as? Double == -122.0312)
    #expect(destinationEndpoint?["id"] as? String != nil)
    #expect(destinationEndpoint?["latitude"] as? Double == 37.3349)
    #expect(destinationEndpoint?["longitude"] as? Double == -122.0090)
    #expect(mapsURL?.contains("saddr=37.331800,-122.031200") == true)
    #expect(mapsURL?.contains("daddr=37.334900,-122.009000") == true)
    #expect(directions?["externalAction"] as? Bool == false)
  }

  @Test func mapsDirectionsPreviewRejectsMixedDestinationSelectors() throws {
    let command = MapsCommand(reader: FakeMapsReader(), opener: FakeMapsOpener())
    let options = try CLIOptionsFixture.parse([
      "directions",
      "preview",
      "--to",
      "Apple Park",
      "--to-latitude",
      "37.3349",
      "--to-longitude",
      "-122.0090",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected mixed Maps destination selectors to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func mapsDirectionsPreviewRequiresCoordinatePairs() throws {
    let command = MapsCommand(reader: FakeMapsReader(), opener: FakeMapsOpener())
    let options = try CLIOptionsFixture.parse([
      "directions",
      "preview",
      "--to-latitude",
      "37.3349",
      "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected incomplete Maps coordinate destination to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func mapsOpenRejectsNonMapsURL() throws {
    let command = MapsCommand(reader: FakeMapsReader(), opener: FakeMapsOpener())
    let options = try CLIOptionsFixture.parse([
      "maps", "open", "--url", "https://example.com", "--dry-run", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected non-maps URL to throw.")
    } catch let error as CLIError {
      #expect(error.code == .validationError)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func mapsOpenRequiresAllowExternalDispatch() throws {
    let command = MapsCommand(reader: FakeMapsReader(), opener: FakeMapsOpener())
    let options = try CLIOptionsFixture.parse([
      "maps", "open", "--url", "maps:?q=Cupertino", "--json",
    ])

    do {
      _ = try command.run(options: options)
      Issue.record("Expected Maps open execution to throw.")
    } catch let error as CLIError {
      #expect(error.code == .unsafeMutationRefused)
    } catch {
      Issue.record("Expected CLIError, got \(error).")
    }
  }

  @Test func mapsOpenDryRunAndAllowFlagExecutesOpen() throws {
    let opener = FakeMapsOpener()
    let command = MapsCommand(reader: FakeMapsReader(), opener: opener)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "maps", "open", "--url", "maps:?q=Cupertino", "--dry-run", "--json",
    ])

    _ = try #require(try command.run(options: dryRunOptions))

    let executeOptions = try CLIOptionsFixture.parse([
      "maps",
      "open",
      "--url",
      "maps:?q=Cupertino",
      "--allow-external-dispatch",
      "--json",
    ])
    let executed = try #require(try command.run(options: executeOptions))
    let object = try jsonObject(executed.stdout ?? "")
    let data = object["data"] as? [String: Any]

    #expect(data?["submitted"] as? Bool == true)
    #expect(opener.openedURLs() == ["maps:?q=Cupertino"])
  }

  @Test func mapsOpenAllowExecutionUsesCurrentURL() throws {
    let opener = FakeMapsOpener()
    let command = MapsCommand(reader: FakeMapsReader(), opener: opener)
    let dryRunOptions = try CLIOptionsFixture.parse([
      "maps", "open", "--url", "maps:?q=Cupertino", "--dry-run", "--json",
    ])
    _ = try #require(try command.run(options: dryRunOptions))

    let executeOptions = try CLIOptionsFixture.parse([
      "maps",
      "open",
      "--url",
      "maps:?q=San%20Francisco",
      "--allow-external-dispatch",
      "--json",
    ])

    _ = try #require(try command.run(options: executeOptions))

    #expect(opener.openedURLs() == ["maps:?q=San%20Francisco"])
  }

  @Test func mapsNativePlaceProjectionPreservesDetailsAndFailures() throws {
    let item = coordinateMapItem(latitude: 37.3349, longitude: -122.0090, name: "Selected place")
    item.phoneNumber = "+1 555 0100"
    item.url = URL(string: "https://example.com/place")
    item.pointOfInterestCategory = .cafe
    item.timeZone = TimeZone(identifier: "America/Los_Angeles")
    let record = try placeRecord(item, fallbackName: "Fallback")
    #expect(record.name == "Selected place")
    #expect(record.latitude == 37.3349 && record.longitude == -122.0090)
    #expect(record.phoneNumber == item.phoneNumber)
    #expect(record.website == item.url?.absoluteString)
    #expect(record.category == MKPointOfInterestCategory.cafe.rawValue)
    #expect(record.timeZone == item.timeZone?.identifier)
    #expect(record.nativeIdentifier == nil)
    #expect(record.id.hasPrefix("maps-place:"))
    #expect(try uniqueMapItem([item], label: "from") === item)
    #expect(throws: CLIError.self) { _ = try uniqueMapItem([item, item], label: "from") }
    #expect(throws: CLIError.self) { _ = try uniqueMapItem([], label: "from") }
    #expect(throws: CLIError.self) { try requireTransportType(.automobile, mode: .walking) }
    try requireTransportType(.cycling, mode: .cycling)
    let native = NSError(
      domain: MKErrorDomain, code: Int(MKError.Code.loadingThrottled.rawValue),
      userInfo: [NSLocalizedDescriptionKey: "synthetic-private-content"])
    do {
      let result: Result<Int, any Error> = nativeMapsResponse(
        1, error: native, phase: "place_search")
      _ = try result.get()
      Issue.record("A native error must take precedence over a response.")
    } catch let error as CLIError {
      #expect(error.code == .backendUnavailable)
      #expect(error.details["error_code"] == String(native.code))
      #expect(!String(describing: error).contains("synthetic-private-content"))
    }
    let missing: Result<Int, any Error> = nativeMapsResponse(nil, error: nil, phase: "place_search")
    #expect(throws: CLIError.self) { _ = try missing.get() }
  }

  @Test func mapsFavoritesPreserveNativeStateAndValidateBeforeReading() throws {
    let reader = RecordingMapsFavoritesReader()
    let command = MapsCommand(favorites: reader)
    let response = try #require(
      try command.run(
        options: CLIOptions(
          json: true, limit: 1, targetOptions: ["offset": "3"], positionals: ["favorites", "list"]))
    )
    let data = try #require(try jsonObject(response.stdout ?? "")["data"] as? [String: Any])
    let favorites = try #require(data["favorites"] as? [[String: Any]])
    #expect(favorites.first?["id"] as? String == reader.favorite.id)
    #expect(favorites.first?["hidden"] as? Bool == true)
    #expect(favorites.first?["position"] as? Int == 4)
    #expect(favorites.first?["customName"] as? String == "")
    #expect(favorites.first?["latitude"] == nil)
    #expect(data["limit"] as? Int == 1 && data["hasMore"] as? Bool == true)
    #expect(data["offset"] as? Int == 3 && data["nextOffset"] as? Int == 4)
    #expect(reader.requests == [MapsSavedListRequest(limit: 1, offset: 3)])
    let id = try #require(
      UUID(uuidString: String(reader.favorite.id.dropFirst("maps-favorite:".count))))
    let selected = try #require(
      try command.run(
        options: CLIOptions(
          json: true,
          targetOptions: ["id": reader.favorite.id], positionals: ["favorites", "read"])))
    let selectedData = try #require(try jsonObject(selected.stdout ?? "")["data"] as? [String: Any])
    #expect((selectedData["favorite"] as? [String: Any])?["id"] as? String == reader.favorite.id)
    #expect(reader.selectedIDs == [id])
    for options in [
      CLIOptions(limit: 0, positionals: ["favorites", "list"]),
      CLIOptions(limit: 101, positionals: ["favorites", "list"]),
      CLIOptions(dryRun: true, positionals: ["favorites", "list"]),
      CLIOptions(targetOptions: ["query": "name"], positionals: ["favorites", "list"]),
      CLIOptions(targetFlags: ["alternatives"], positionals: ["favorites", "list"]),
      CLIOptions(targetOptions: ["offset": "-1"], positionals: ["favorites", "list"]),
      CLIOptions(targetOptions: ["offset": "1000001"], positionals: ["favorites", "list"]),
      CLIOptions(targetOptions: ["offset": "later"], positionals: ["favorites", "list"]),
      CLIOptions(
        targetOptions: ["id": "maps-favorite:invalid"], positionals: ["favorites", "read"]),
      CLIOptions(
        targetOptions: ["id": "maps-collection:\(id)"], positionals: ["favorites", "read"]),
      CLIOptions(
        limit: 1, targetOptions: ["id": reader.favorite.id], positionals: ["favorites", "read"]),
    ] {
      #expect(throws: CLIError.self) { _ = try command.run(options: options) }
    }
    #expect(reader.requests == [MapsSavedListRequest(limit: 1, offset: 3)])
    #expect(reader.selectedIDs == [id])
    let error = CLIError(code: .backendUnavailable, message: "Configured native store failure.")
    reader.error = error
    #expect(throws: error) {
      _ = try command.run(options: CLIOptions(positionals: ["favorites", "list"]))
    }
    #expect(reader.requests == [MapsSavedListRequest(limit: 1, offset: 3), MapsSavedListRequest()])
  }

  @Test func mapsCollectionsBindNativeIDAndMemberScope() throws {
    let reader = RecordingMapsCollectionsReader()
    let command = MapsCommand(collections: reader)
    let id = try #require(
      UUID(uuidString: String(reader.collection.id.dropFirst("maps-collection:".count))))
    let listed = try #require(
      try command.run(
        options: CLIOptions(
          json: true, limit: 1,
          targetOptions: ["offset": "2"], positionals: ["collections", "list"])))
    let data = try #require(try jsonObject(listed.stdout ?? "")["data"] as? [String: Any])
    #expect(
      (data["collections"] as? [[String: Any]])?.first?["id"] as? String == reader.collection.id)
    #expect(data["offset"] as? Int == 2 && data["nextOffset"] as? Int == 3)
    #expect(reader.requests == [MapsSavedListRequest(limit: 1, offset: 2)])
    let selected = try #require(
      try command.run(
        options: CLIOptions(
          json: true,
          targetOptions: ["id": reader.collection.id], positionals: ["collections", "read"])))
    let selectedData = try #require(try jsonObject(selected.stdout ?? "")["data"] as? [String: Any])
    #expect((selectedData["collection"] as? [String: Any])?["reportedPlaceCount"] as? Int == 4)
    #expect(reader.selectedIDs == [id])
    let members = try #require(
      try command.run(
        options: CLIOptions(
          json: true, limit: 1,
          targetOptions: ["id": reader.collection.id, "offset": "2"],
          positionals: ["collections", "places", "list"])))
    let memberData = try #require(try jsonObject(members.stdout ?? "")["data"] as? [String: Any])
    #expect((memberData["collection"] as? [String: Any])?["id"] as? String == reader.collection.id)
    #expect(
      (memberData["items"] as? [[String: Any]])?.first?["note"] as? String == "Configured note")
    #expect(memberData["hasMore"] as? Bool == true)
    #expect(
      reader.memberID == id && reader.memberRequest == MapsSavedListRequest(limit: 1, offset: 2))
    for options in [
      CLIOptions(
        targetOptions: ["id": "maps-favorite:\(id)"], positionals: ["collections", "read"]),
      CLIOptions(
        targetOptions: ["id": "maps-collection:invalid"],
        positionals: ["collections", "places", "list"]),
      CLIOptions(dryRun: true, positionals: ["collections", "list"]),
      CLIOptions(
        targetOptions: ["id": reader.collection.id, "offset": "-1"],
        positionals: ["collections", "places", "list"]),
      CLIOptions(
        limit: 1, targetOptions: ["id": reader.collection.id], positionals: ["collections", "read"]),
    ] {
      #expect(throws: CLIError.self) { _ = try command.run(options: options) }
    }
    #expect(reader.selectedIDs == [id])
    let missing = CLIError(code: .notFound, message: "Configured missing collection.")
    reader.error = missing
    #expect(throws: missing) {
      _ = try command.run(
        options: CLIOptions(
          targetOptions: ["id": reader.collection.id],
          positionals: ["collections", "places", "list"]))
    }
  }

  @Test func mapsCollectionMutationsBindIDsPreserveTextAndSeparateDryRun() throws {
    let reader = RecordingMapsCollectionsReader()
    let writer = RecordingMapsCollectionsWriter()
    let command = MapsCommand(collections: reader, collectionWriter: writer)
    let id = reader.collection.id
    let itemID = reader.item.id
    let title = "  literal e\u{301} 👩🏽‍💻  "
    for (path, fields, flags) in [
      (["collections", "create"], ["id": id, "title": title, "description": ""], Set<String>()),
      (["collections", "update"], ["id": id, "title": title], Set(["clear-description"])),
      (["collections", "delete"], ["id": id], Set<String>()),
      (["collections", "places", "add"], ["id": id, "item": itemID], Set<String>()),
      (["collections", "places", "remove"], ["id": id, "item": itemID], Set<String>()),
      (
        ["collections", "places", "create"],
        ["id": id, "item": itemID, "place": "maps-item:opaque-ID", "name": title, "note": ""],
        Set<String>()
      ),
    ] {
      let result = try #require(
        try command.run(
          options: CLIOptions(
            json: true, dryRun: true,
            targetOptions: fields, targetFlags: flags, positionals: path)))
      let data = try #require(try jsonObject(result.stdout ?? "")["data"] as? [String: Any])
      #expect(data["mode"] as? String == "dry-run")
    }
    #expect(writer.calls.isEmpty)
    #expect(
      reader.readItemID == UUID(uuidString: String(itemID.dropFirst("maps-collection-item:".count)))
    )
    _ = try command.run(
      options: CLIOptions(
        json: true, targetOptions: ["id": id, "title": title],
        positionals: ["collections", "create"]))
    #expect(writer.draft?.id == UUID(uuidString: String(id.dropFirst("maps-collection:".count))))
    #expect(writer.draft?.title.utf8.elementsEqual(title.utf8) == true)
    _ = try command.run(
      options: CLIOptions(
        json: true, targetOptions: ["id": id],
        targetFlags: ["clear-description"], positionals: ["collections", "update"]))
    #expect(writer.patch?.clearDescription == true && writer.current == reader.collection)
    _ = try command.run(
      options: CLIOptions(
        json: true, targetOptions: ["id": id, "item": itemID],
        positionals: ["collections", "places", "add"]))
    #expect(writer.member == reader.item && writer.linked == true)
    _ = try command.run(
      options: CLIOptions(
        json: true, targetOptions: ["id": id, "item": itemID],
        positionals: ["collections", "places", "remove"]))
    #expect(writer.linked == false)
    _ = try command.run(
      options: CLIOptions(
        json: true,
        targetOptions: [
          "id": id, "item": itemID, "place": "maps-item:opaque-ID", "name": title,
          "note": "",
        ],
        positionals: ["collections", "places", "create"]))
    #expect(writer.current == reader.collection)
    #expect(
      writer.placeDraft?.id
        == UUID(uuidString: String(itemID.dropFirst("maps-collection-item:".count))))
    #expect(writer.placeDraft?.source == .identifier("opaque-ID"))
    #expect(writer.placeDraft?.customName?.utf8.elementsEqual(title.utf8) == true)
    #expect(writer.placeDraft?.note == "")
    _ = try command.run(
      options: CLIOptions(
        targetOptions: ["id": id, "latitude": "39.9338", "longitude": "116.4552", "note": title],
        positionals: ["collections", "places", "create"]))
    #expect(writer.placeDraft?.source == .coordinate(latitude: 39.9338, longitude: 116.4552))
    #expect(writer.placeDraft?.customName == nil)
    #expect(writer.placeDraft?.note?.utf8.elementsEqual(title.utf8) == true)
    _ = try command.run(
      options: CLIOptions(
        json: true, targetOptions: ["id": id],
        positionals: ["collections", "delete"]))
    let calls = writer.calls
    let selected = reader.selectedIDs
    for options in [
      CLIOptions(targetOptions: ["title": "   "], positionals: ["collections", "create"]),
      CLIOptions(
        targetOptions: ["title": "Valid", "position": "-1"], positionals: ["collections", "create"]),
      CLIOptions(
        targetOptions: ["title": "Valid", "id": reader.item.id],
        positionals: ["collections", "create"]),
      CLIOptions(targetOptions: ["id": id], positionals: ["collections", "update"]),
      CLIOptions(
        targetOptions: ["id": id, "description": "text"], targetFlags: ["clear-description"],
        positionals: ["collections", "update"]),
      CLIOptions(limit: 1, targetOptions: ["id": id], positionals: ["collections", "delete"]),
    ] {
      #expect(throws: CLIError.self) { _ = try command.run(options: options) }
    }
    #expect(writer.calls == calls && reader.selectedIDs == selected)
    for fields in [
      ["id": id],
      ["id": id, "latitude": "39"],
      ["id": id, "latitude": "nan", "longitude": "116"],
      ["id": id, "latitude": "91", "longitude": "116"],
      ["id": id, "place": itemID],
      ["id": id, "place": "maps-item:"],
      ["id": id, "place": "maps-item: opaque-ID"],
      ["id": id, "place": "maps-item:opaque-ID", "latitude": "39", "longitude": "116"],
      ["id": id, "place": "maps-item:opaque-ID", "item": id],
      ["id": itemID, "place": "maps-item:opaque-ID"],
      ["id": id, "place": "maps-item:opaque-ID", "note": "bad\0text"],
    ] {
      #expect(throws: CLIError.self) {
        _ = try command.run(
          options: CLIOptions(
            targetOptions: fields, positionals: ["collections", "places", "create"]))
      }
    }
    #expect(writer.calls == calls && reader.selectedIDs == selected)
    for action in ["create", "update", "delete"] {
      #expect(throws: CLIError.self) {
        let fields = ["id": "maps-collection:00000000-0000-0000-0000-000000000001", "title": title]
        _ = try command.run(
          options: CLIOptions(
            dryRun: true,
            targetOptions: fields.filter { action != "delete" || $0.key == "id" },
            positionals: ["collections", action]))
      }
    }
    #expect(writer.calls == calls && reader.selectedIDs == selected)
    var before = reader.collection
    var equivalent = before
    before.title = "e\u{301}"
    equivalent.title = "\u{e9}"
    #expect(before.title == equivalent.title)
    #expect(!mapsCollectionMatches(before, equivalent, ignoringModificationTime: true))
    #expect(
      MapsCollectionPatch(clearDescription: true).applying(to: reader.collection).description == nil
    )
  }

  @concurrent @Test func mapsCallbackDeliveryAndCancellationAreBounded() async throws {
    let value: Int = try waitForMapsCallback(
      deadline: MapsDeadline(seconds: 1), phase: "test", cancel: {},
      start: { finish in
        DispatchQueue.main.async {
          #expect(Thread.isMainThread)
          finish(.success(7))
          finish(.success(8))
        }
      })
    #expect(value == 7)
    var canceled = false
    var late: (@Sendable (Result<Int, any Error>) -> Void)?
    #expect(
      throws: CLIError(
        code: .timeout, message: "Maps request timed out.", details: ["phase": "test"])
    ) {
      let _: Int = try waitForMapsCallback(
        deadline: MapsDeadline(seconds: 0.03), phase: "test", cancel: { canceled = true },
        start: { finish in
          late = finish
        })
    }
    #expect(canceled)
    late?(.success(99))
  }

  @Test func mapsDirectionsForwardCurrentRequestAndRejectUnsupportedChoices() throws {
    let router = RecordingMapsRouter()
    let command = MapsCommand(reader: FakeMapsReader(), opener: FakeMapsOpener(), router: router)
    let endpoints = [
      "from-latitude": "39.9338", "from-longitude": "116.4552",
      "to-latitude": "39.9419", "to-longitude": "116.4552",
    ]
    let response = try #require(
      try command.run(
        options: CLIOptions(
          json: true, limit: 2,
          targetOptions: endpoints.merging([
            "mode": "cycling", "departure": "2026-10-05T10:00:00+08:00",
          ]) { _, value in value },
          targetFlags: ["alternatives"], positionals: ["directions", "calculate"])))
    let routeData = try #require(try jsonObject(response.stdout ?? "")["data"] as? [String: Any])
    #expect(routeData["mode"] as? String == "cycling")
    let routes = try #require(routeData["routes"] as? [[String: Any]])
    #expect(routes.first?["distanceMeters"] as? Double == 1200)
    #expect(routes.first?["expectedTravelTimeSeconds"] as? Double == 300)
    #expect(routes.first?["advisoryNotices"] as? [String] == ["Configured notice"])
    #expect(router.request?.mode == .cycling)
    #expect(router.request?.alternatives == true)
    #expect(router.request?.limit == 2)
    #expect(router.request?.source.latitude == 39.9338)
    #expect(router.request?.destination.latitude == 39.9419)
    #expect(router.request?.departure == ISO8601DateFormatter().date(from: "2026-10-05T02:00:00Z"))
    let eta = try #require(
      try command.run(
        options: CLIOptions(
          json: true, targetOptions: endpoints.merging(["mode": "transit"]) { _, value in value },
          positionals: ["directions", "eta"])))
    let etaData = try #require(try jsonObject(eta.stdout ?? "")["data"] as? [String: Any])
    #expect(etaData["mode"] as? String == "transit")
    #expect(etaData["distanceMeters"] as? Double == 900)
    #expect(etaData["expectedTravelTimeSeconds"] as? Double == 800)
    #expect(router.request?.mode == .transit)
    #expect(router.request?.departure == nil && router.request?.alternatives == false)
    for (path, extra, limit, flags) in [
      ("calculate", ["mode": "transit"], nil, Set<String>()),
      (
        "calculate", ["arrival": "2026-10-05T10:00:00Z", "departure": "2026-10-05T09:00:00Z"], nil,
        []
      ),
      ("calculate", ["arrival": "tomorrow"], nil, []),
      ("calculate", ["from": "Ambiguous place"], nil, []),
      ("calculate", [:], 0, []),
      ("eta", [:], 1, []),
      ("eta", [:], nil, ["alternatives"]),
    ] {
      #expect(throws: CLIError.self) {
        _ = try command.run(
          options: CLIOptions(
            limit: limit, targetOptions: endpoints.merging(extra) { _, value in value },
            targetFlags: flags, positionals: ["directions", path]))
      }
    }
    #expect(throws: CLIError.self) {
      _ = try command.run(
        options: CLIOptions(
          targetOptions: ["to": "Cupertino"], positionals: ["directions", "calculate"]))
    }
  }
}

private final class FakeMapsReader: MapsReading, @unchecked Sendable {
  var request: MapsSearchRequest?
  func searchPlaces(_ request: MapsSearchRequest) throws -> MapsPlacesResponse {
    self.request = request
    return MapsPlacesResponse(places: [place()], returnedByService: 1, truncated: false)
  }

  func readPlace(_ selection: MapsPlaceSelection) throws -> MapsPlaceRecord {
    guard case .coordinate(let latitude, let longitude, let name) = selection else {
      throw CLIError(code: .notFound, message: "No configured place ID.")
    }
    return MapsPlaceRecord(
      id: "maps-place:test",
      name: name ?? "Coordinate",
      latitude: latitude,
      longitude: longitude,
      mapsURL: "maps:?q=Coordinate&ll=\(latitude),\(longitude)"
    )
  }

  private func place() -> MapsPlaceRecord {
    MapsPlaceRecord(
      id: "maps-place:apple-park",
      name: "Apple Park",
      address: "One Apple Park Way",
      latitude: 37.3349,
      longitude: -122.0090,
      mapsURL: "maps:?q=Apple%20Park&ll=37.3349,-122.009"
    )
  }
}

private final class RecordingMapsRouter: MapsRouting, @unchecked Sendable {
  var request: MapsDirectionsRequest?
  let routes: MapsRoutesResponse
  let eta: MapsETAResponse
  init() {
    let place = MapsPlaceRecord(
      id: "maps-place:configured", name: "Configured", mapsURL: "maps:?q=Configured")
    routes = MapsRoutesResponse(
      source: place, destination: place, mode: .cycling,
      routes: [
        MapsRouteRecord(
          name: "Configured route", distanceMeters: 1200, expectedTravelTimeSeconds: 300,
          mode: "cycling", advisoryNotices: ["Configured notice"], hasTolls: false,
          hasHighways: false,
          steps: [], stepCount: 0, stepsTruncated: false, polyline: [], polylinePointCount: 0,
          polylineTruncated: false)
      ], returnedByService: 1, truncated: false)
    eta = MapsETAResponse(
      source: place, destination: place, mode: .transit, distanceMeters: 900,
      expectedTravelTimeSeconds: 800, expectedDeparture: Date(timeIntervalSince1970: 1_000),
      expectedArrival: Date(timeIntervalSince1970: 1_800))
  }
  func calculateDirections(_ request: MapsDirectionsRequest) throws -> MapsRoutesResponse {
    self.request = request
    return routes
  }
  func calculateETA(_ request: MapsDirectionsRequest) throws -> MapsETAResponse {
    self.request = request
    return eta
  }
}

private final class RecordingMapsFavoritesReader: MapsFavoritesReading, @unchecked Sendable {
  var requests: [MapsSavedListRequest] = []
  var selectedIDs: [UUID] = []
  let favorite = MapsFavoriteRecord(
    id: "maps-favorite:01234567-89ab-cdef-0123-456789abcdef", customName: "", hidden: true,
    position: 4)
  var error: CLIError?
  func listFavorites(_ request: MapsSavedListRequest) throws -> MapsFavoritesResponse {
    requests.append(request)
    if let error { throw error }
    return MapsFavoritesResponse(
      favorites: [favorite], limit: 1, hasMore: true, offset: 3, nextOffset: 4)
  }
  func readFavorite(id: UUID) throws -> MapsFavoriteRecord {
    selectedIDs.append(id)
    if let error { throw error }
    return favorite
  }
}

private final class RecordingMapsCollectionsReader: MapsCollectionsReading, @unchecked Sendable {
  let collection = MapsCollectionRecord(
    id: "maps-collection:fedcba98-7654-3210-fedc-ba9876543210",
    title: "Configured", description: "", position: 7, reportedPlaceCount: 4)
  var requests: [MapsSavedListRequest] = []
  var selectedIDs: [UUID] = []
  var memberID: UUID?
  var memberRequest: MapsSavedListRequest?
  var error: CLIError?
  var readItemID: UUID?
  let item = MapsCollectionItemRecord(
    id: "maps-collection-item:01234567-89ab-cdef-0123-456789abcdef", kind: .place,
    customName: "Configured place", note: "Configured note", position: 0)
  func listCollections(_ request: MapsSavedListRequest) throws -> MapsCollectionsResponse {
    requests.append(request)
    if let error { throw error }
    return MapsCollectionsResponse(
      collections: [collection], limit: 1, offset: 2, hasMore: true, nextOffset: 3)
  }
  func readCollection(id: UUID) throws -> MapsCollectionRecord {
    selectedIDs.append(id)
    if let error { throw error }
    return collection
  }
  func readCollectionItem(id: UUID) throws -> MapsCollectionItemRecord {
    readItemID = id
    if let error { throw error }
    return item
  }
  func listCollectionItems(id: UUID, request: MapsSavedListRequest) throws
    -> MapsCollectionItemsResponse
  {
    memberID = id
    memberRequest = request
    if let error { throw error }
    return MapsCollectionItemsResponse(
      collection: collection,
      items: [item], limit: 1, offset: 2, hasMore: true, nextOffset: 3)
  }
}

private final class RecordingMapsCollectionsWriter: MapsCollectionsWriting, @unchecked Sendable {
  var calls: [String] = []
  var draft: MapsCollectionDraft?
  var placeDraft: MapsCollectionPlaceDraft?
  var patch: MapsCollectionPatch?
  var current: MapsCollectionRecord?
  var member: MapsCollectionItemRecord?
  var linked: Bool?
  private func result(_ operation: String) -> MapsCollectionMutationResult {
    calls.append(operation)
    return MapsCollectionMutationResult(operation: operation, changed: true)
  }
  func createCollection(_ draft: MapsCollectionDraft) throws -> MapsCollectionMutationResult {
    self.draft = draft
    return result("collections.create")
  }
  func createCollectionPlace(collection: MapsCollectionRecord, draft: MapsCollectionPlaceDraft)
    throws
    -> MapsCollectionMutationResult
  {
    current = collection
    placeDraft = draft
    return result("collections.places.create")
  }
  func updateCollection(current: MapsCollectionRecord, patch: MapsCollectionPatch) throws
    -> MapsCollectionMutationResult
  {
    self.current = current
    self.patch = patch
    return result("collections.update")
  }
  func deleteCollection(current: MapsCollectionRecord) throws -> MapsCollectionMutationResult {
    self.current = current
    return result("collections.delete")
  }
  func setCollectionMembership(
    collection: MapsCollectionRecord, item: MapsCollectionItemRecord, linked: Bool
  ) throws -> MapsCollectionMutationResult {
    current = collection
    member = item
    self.linked = linked
    return result(linked ? "collections.places.add" : "collections.places.remove")
  }
}

private final class FakeMapsOpener: MapsOpening, @unchecked Sendable {
  private var urls: [String] = []

  func open(_ url: URL) throws -> Bool {
    urls.append(url.absoluteString)
    return true
  }

  func openedURLs() -> [String] {
    urls
  }
}

private func jsonObject(_ json: String) throws -> [String: Any] {
  let data = Data(json.utf8)
  guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw MapsCommandTestError.notObject
  }
  return object
}

private enum MapsCommandTestError: Error {
  case notObject
}
