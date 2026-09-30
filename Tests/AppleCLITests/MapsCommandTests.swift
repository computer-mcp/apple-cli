import Foundation
import MapsCLI
import Testing
import Utility

@Suite
struct MapsCommandTests {
  @Test func mapsPlacesSearchReturnsJSON() throws {
    let command = MapsCommand(reader: FakeMapsReader(), opener: FakeMapsOpener())
    let options = try CLIOptionsFixture.parse(["places", "search", "--query", "Cupertino", "--json"])

    let result = try #require(try command.run(options: options))
    let object = try jsonObject(result.stdout ?? "")
    let data = object["data"] as? [String: Any]
    let places = data?["places"] as? [[String: Any]]

    #expect(object["ok"] as? Bool == true)
    #expect(places?.first?["name"] as? String == "Apple Park")
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
}

private struct FakeMapsReader: MapsReading {
  func searchPlaces(query: String, limit: Int) throws -> [MapsPlaceRecord] {
    [place()].prefix(limit).map { $0 }
  }

  func readPlace(latitude: Double, longitude: Double, name: String?) throws -> MapsPlaceRecord {
    MapsPlaceRecord(
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
