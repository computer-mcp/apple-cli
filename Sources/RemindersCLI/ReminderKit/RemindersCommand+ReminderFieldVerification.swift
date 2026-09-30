import Foundation
import Utility

extension RemindersCommand {
  func verifyVisibleURL(reminder: ReminderDetail, expectedURL: String?) throws {
    let deadline = Date().addingTimeInterval(10)
    var lastDebug: RemindersItemDebugResponse?
    var lastError: Error?

    repeat {
      do {
        let debug = try sqliteReader.debugItem(reminder: reminder)
        lastDebug = debug
        if visibleURLSatisfied(debug: debug, expectedURL: expectedURL) {
          return
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "reminder_id": reminder.id,
      "expected_url": expectedURL ?? "",
    ]
    if let lastDebug {
      details["visible_urls"] = lastDebug.visibleURLObjects.compactMap(\.url).joined(separator: ",")
      details["private_store_match_count"] = "\(lastDebug.privateStoreMatches.count)"
      details["warning_count"] = "\(lastDebug.warnings.count)"
    }
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: expectedURL == nil
        ? "Reminders.app visible URL/link-card clear could not be verified."
        : "Reminders.app visible URL/link-card update could not be verified.",
      details: details
    )
  }

  func verifyFlagged(reminder: ReminderDetail, expectedFlagged: Bool) throws {
    let deadline = Date().addingTimeInterval(10)
    var lastDebug: RemindersItemDebugResponse?
    var lastError: Error?

    repeat {
      do {
        let debug = try sqliteReader.debugItem(reminder: reminder)
        lastDebug = debug
        if flaggedSatisfied(debug: debug, expectedFlagged: expectedFlagged) {
          return
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "reminder_id": reminder.id,
      "expected_flagged": "\(expectedFlagged)",
    ]
    if let lastDebug {
      details["private_store_match_count"] = "\(lastDebug.privateStoreMatches.count)"
      details["flagged_values"] = lastDebug.privateStoreMatches
        .compactMap(\.flagged)
        .map(String.init)
        .joined(separator: ",")
      details["warning_count"] = "\(lastDebug.warnings.count)"
    }
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app flag state update could not be verified.",
      details: details
    )
  }

  func flaggedSatisfied(
    debug: RemindersItemDebugResponse,
    expectedFlagged: Bool
  ) -> Bool {
    debug.privateStoreMatches.contains { $0.flagged == expectedFlagged }
  }

  func verifyUrgent(reminder: ReminderDetail, expectedUrgent: Bool) throws {
    let deadline = Date().addingTimeInterval(10)
    var lastDebug: RemindersItemDebugResponse?
    var lastError: Error?

    repeat {
      do {
        let debug = try sqliteReader.debugItem(reminder: reminder)
        lastDebug = debug
        if urgentSatisfied(debug: debug, expectedUrgent: expectedUrgent) {
          return
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "reminder_id": reminder.id,
      "expected_urgent": "\(expectedUrgent)",
    ]
    if let lastDebug {
      details["private_store_match_count"] = "\(lastDebug.privateStoreMatches.count)"
      details["urgent_values"] = lastDebug.privateStoreMatches
        .compactMap(\.isUrgent)
        .map(String.init)
        .joined(separator: ",")
      details["warning_count"] = "\(lastDebug.warnings.count)"
    }
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app urgent state update could not be verified.",
      details: details
    )
  }

  func urgentSatisfied(
    debug: RemindersItemDebugResponse,
    expectedUrgent: Bool
  ) -> Bool {
    debug.privateStoreMatches.contains { $0.isUrgent == expectedUrgent }
  }

  func verifyMessagingPerson(reminder: ReminderDetail, expectedPresent: Bool) throws {
    let deadline = Date().addingTimeInterval(10)
    var lastDebug: RemindersItemDebugResponse?
    var lastError: Error?

    repeat {
      do {
        let debug = try sqliteReader.debugItem(reminder: reminder)
        lastDebug = debug
        if messagingPersonSatisfied(debug: debug, expectedPresent: expectedPresent) {
          return
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "reminder_id": reminder.id,
      "expected_messaging_person_present": "\(expectedPresent)",
    ]
    if let lastDebug {
      details["private_store_match_count"] = "\(lastDebug.privateStoreMatches.count)"
      details["messaging_contact_handle_lengths"] = lastDebug.privateStoreMatches
        .flatMap(\.messagingContactHandles)
        .compactMap(\.lengthBytes)
        .map(String.init)
        .joined(separator: ",")
      details["warning_count"] = "\(lastDebug.warnings.count)"
    }
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app When Messaging update could not be verified.",
      details: details
    )
  }

  func messagingPersonSatisfied(
    debug: RemindersItemDebugResponse,
    expectedPresent: Bool
  ) -> Bool {
    debug.privateStoreMatches.contains { match in
      match.messagingContactHandles.isEmpty != expectedPresent
    }
  }

  func expectedTagsAfterMutation(id: String, patch: ReminderPatch) throws -> [String] {
    if let tags = patch.tags {
      return normalizedTags(tags)
    }
    if patch.clearTags {
      return []
    }
    guard !patch.addTags.isEmpty || !patch.removeTags.isEmpty else {
      return []
    }
    guard let reminder = try readReminderKitReminder(id: id) else {
      throw CLIError(code: .notFound, message: "Reminder was not found.", details: ["id": id])
    }
    let current = try sqliteReader.enrichReminder(reminder).tags
    var next = normalizedTags(current)
    let removeKeys = Set(patch.removeTags.map { $0.lowercased() })
    next.removeAll { removeKeys.contains($0.lowercased()) }
    for tag in patch.addTags
    where !next.contains(where: {
      $0.localizedCaseInsensitiveCompare(tag) == .orderedSame
    }) {
      next.append(tag)
    }
    return normalizedTags(next)
  }

  func verifyTags(reminder: ReminderDetail, expectedTags: [String]) throws {
    let expected = Set(expectedTags.map { $0.lowercased() })
    let deadline = Date().addingTimeInterval(10)
    var lastDebug: RemindersItemDebugResponse?
    var lastError: Error?

    repeat {
      do {
        let debug = try sqliteReader.debugItem(reminder: reminder)
        lastDebug = debug
        if Set(tagSet(debug).map { $0.lowercased() }) == expected {
          return
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "reminder_id": reminder.id,
      "expected_tags": expected.sorted().joined(separator: ","),
    ]
    if let lastDebug {
      details["actual_tags"] = tagSet(lastDebug).map { $0.lowercased() }.sorted().joined(
        separator: ",")
      details["private_store_match_count"] = "\(lastDebug.privateStoreMatches.count)"
      details["warning_count"] = "\(lastDebug.warnings.count)"
    }
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app tag update could not be verified.",
      details: details
    )
  }

  func tagSet(_ debug: RemindersItemDebugResponse) -> Set<String> {
    Set(
      debug.privateStoreMatches
        .flatMap(\.objects)
        .compactMap { $0.tagCanonicalName ?? $0.tagName }
    )
  }

  func verifySection(reminder: ReminderDetail, expectedSectionTitle: String) throws {
    let deadline = Date().addingTimeInterval(10)
    var lastDebug: RemindersItemDebugResponse?
    var lastError: Error?

    repeat {
      do {
        let debug = try sqliteReader.debugItem(reminder: reminder)
        lastDebug = debug
        if sectionSatisfied(debug: debug, expectedSectionTitle: expectedSectionTitle) {
          return
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "reminder_id": reminder.id,
      "expected_section": expectedSectionTitle,
    ]
    if let lastDebug {
      details["actual_sections"] = lastDebug.privateStoreMatches
        .compactMap(\.sectionTitle)
        .joined(separator: ",")
      details["private_store_match_count"] = "\(lastDebug.privateStoreMatches.count)"
      details["warning_count"] = "\(lastDebug.warnings.count)"
    }
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app section assignment could not be verified.",
      details: details
    )
  }

  func sectionSatisfied(
    debug: RemindersItemDebugResponse,
    expectedSectionTitle: String
  ) -> Bool {
    debug.privateStoreMatches.contains { match in
      guard let sectionTitle = match.sectionTitle else {
        return false
      }
      return sectionTitle.localizedCaseInsensitiveCompare(expectedSectionTitle) == .orderedSame
    }
  }

  func normalizedTags(_ tags: [String]) -> [String] {
    var seen: Set<String> = []
    var normalized: [String] = []
    for tag in tags {
      let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else {
        continue
      }
      if seen.insert(trimmed.lowercased()).inserted {
        normalized.append(trimmed)
      }
    }
    return normalized.sorted { lhs, rhs in
      lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
    }
  }

  func verifyListMetadata(list: ReminderListRecord, patch: ReminderListPatch) throws {
    guard patch.requiresReadOnlyVerification else {
      return
    }

    let deadline = Date().addingTimeInterval(10)
    var lastDebug: RemindersListDebugResponse?
    var lastError: Error?

    repeat {
      do {
        let debug = try sqliteReader.debugList(list: list)
        lastDebug = debug
        if listMetadataSatisfied(debug: debug, patch: patch) {
          return
        }
      } catch {
        lastError = error
      }

      Thread.sleep(forTimeInterval: 0.4)
    } while Date() < deadline

    var details: [String: String] = [
      "verifier": "reminders_store_readonly",
      "list_id": list.id,
      "expected_type": patch.listType ?? "",
      "expected_pinned": patch.pinned.map(String.init) ?? "",
      "expected_sort": patch.sortingStyle ?? "",
      "expected_show_large_attachments": patch.showingLargeAttachments.map(String.init) ?? "",
      "expected_has_color": patch.color == nil ? "" : "true",
    ]
    if let lastDebug {
      details["private_store_match_count"] = "\(lastDebug.privateStoreMatches.count)"
      details["actual_types"] = lastDebug.privateStoreMatches.compactMap(\.listType)
        .joined(separator: ",")
      details["actual_pinned"] = lastDebug.privateStoreMatches.compactMap(\.isPinned)
        .map(String.init)
        .joined(separator: ",")
      details["actual_sorts"] = lastDebug.privateStoreMatches.compactMap(\.sortingStyle)
        .joined(separator: ",")
      details["actual_show_large_attachments"] = lastDebug.privateStoreMatches
        .compactMap(\.showingLargeAttachments)
        .map(String.init)
        .joined(separator: ",")
      details["actual_has_color"] = lastDebug.privateStoreMatches.compactMap(\.hasColor)
        .map(String.init)
        .joined(separator: ",")
      details["warning_count"] = "\(lastDebug.warnings.count)"
    }
    if let lastError {
      details["last_error"] = String(describing: lastError)
    }

    throw CLIError(
      code: .backendUnavailable,
      message: "Reminders.app list metadata update could not be verified.",
      details: details
    )
  }

  func listMetadataSatisfied(
    debug: RemindersListDebugResponse,
    patch: ReminderListPatch
  ) -> Bool {
    debug.privateStoreMatches.contains { match in
      if let listType = patch.listType, match.listType != listType {
        return false
      }
      if let pinned = patch.pinned, match.isPinned != pinned {
        return false
      }
      if let sortingStyle = patch.sortingStyle, match.sortingStyle != sortingStyle {
        return false
      }
      if let showingLargeAttachments = patch.showingLargeAttachments,
        match.showingLargeAttachments != showingLargeAttachments
      {
        return false
      }
      if patch.color != nil, match.hasColor != true {
        return false
      }
      return true
    }
  }

  func visibleURLSatisfied(
    debug: RemindersItemDebugResponse,
    expectedURL: String?
  ) -> Bool {
    let visibleURLs = debug.visibleURLObjects.compactMap(\.url)
    guard let expectedURL else {
      return visibleURLs.isEmpty
    }

    return visibleURLs.contains { visibleURLEquivalent($0, expectedURL) }
  }

  func visibleURLEquivalent(_ lhs: String, _ rhs: String) -> Bool {
    if lhs == rhs {
      return true
    }

    return lhs.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
      == rhs.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
  }
}
