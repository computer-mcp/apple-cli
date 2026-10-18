import CryptoKit
import Foundation
import Utility

public struct SafariCommand: Sendable {
  private let backend: any SafariAutomating
  private let tabGroupBackend: any SafariTabGroupReading & SafariTabGroupMutating
  private let target = "safari"

  public init(
    backend: any SafariAutomating = SafariAppleScriptBackend(),
    tabGroupBackend: any SafariTabGroupReading & SafariTabGroupMutating =
      SafariTabGroupsSQLiteBackend()
  ) {
    self.backend = backend
    self.tabGroupBackend = tabGroupBackend
  }

  public func run(options: CLIOptions) throws -> CLICommandResult? {
    switch options.positionals {
    case ["windows", "list"]:
      try validateSafariReadOnly(options)
      try validateSafariTargetOptions(options, allowedOptions: [])
      let windows = try backend.listWindows()
      return try result(
        SafariWindowsResponse(windows: windows),
        human: windows.map { "\($0.index)\ttabs=\($0.tabCount)" }.joined(separator: "\n"),
        options: options
      )
    case ["window", "list"]:
      try validateSafariReadOnly(options)
      try validateSafariTargetOptions(
        options, allowedOptions: [], allowedFlags: ["include-restorable"])
      let response = try tabGroupBackend.listWindows(
        includeRestorable: options.hasTargetFlag("include-restorable"),
        verbose: options.verbose
      )
      return try result(
        response, human: snapshotWindowsHumanOutput(response), options: options)
    case ["window", "read"]:
      try validateSafariReadOnly(options)
      try validateSafariTargetOptions(options, allowedOptions: ["id"])
      let id = try safariRequiredOption("id", options: options)
      guard let response = try tabGroupBackend.readWindow(id: id, verbose: options.verbose) else {
        throw CLIError(
          code: .notFound, message: "Safari snapshot window was not found.", details: ["id": id])
      }
      return try result(
        response, human: snapshotWindowResponseHumanOutput(response), options: options)
    case ["window", "profile"]:
      try validateSafariReadOnly(options)
      try validateSafariTargetOptions(options, allowedOptions: ["id"])
      let id = try safariRequiredOption("id", options: options)
      guard let profile = try tabGroupBackend.windowProfile(id: id, verbose: options.verbose) else {
        throw CLIError(
          code: .notFound, message: "Safari snapshot window was not found.", details: ["id": id])
      }
      return try result(
        SafariProfileResponse(profile: profile), human: profileHumanOutput(profile),
        options: options)
    case ["window", "tab", "list"]:
      try validateSafariReadOnly(options)
      try validateSafariTargetOptions(options, allowedOptions: ["window-id"])
      let windowID = try safariRequiredOption("window-id", options: options)
      guard
        let response = try tabGroupBackend.listWindowTabs(
          windowID: windowID,
          verbose: options.verbose)
      else {
        throw CLIError(
          code: .notFound,
          message: "Safari snapshot window was not found.",
          details: ["window_id": windowID])
      }
      return try result(
        response, human: snapshotWindowTabsHumanOutput(response), options: options)
    case ["tabs", "list"], ["tab", "list"]:
      try validateSafariReadOnly(options)
      try validateSafariTargetOptions(options, allowedOptions: ["window-index"])
      let tabs = try backend.listTabs(
        windowIndex: try safariOptionalPositiveInt("window-index", options: options))
      return try result(
        SafariTabsResponse(tabs: tabs), human: tabsHumanOutput(tabs), options: options)
    case ["tabs", "current"], ["tab", "current"]:
      try validateSafariReadOnly(options)
      try validateSafariTargetOptions(options, allowedOptions: ["window-index"])
      guard
        let tab = try backend.currentTab(
          windowIndex: try safariOptionalPositiveInt("window-index", options: options))
      else {
        throw CLIError(code: .notFound, message: "Safari current tab was not found.")
      }
      return try result(SafariTabResponse(tab: tab), human: tabHumanOutput(tab), options: options)
    case ["tabs", "read"], ["tab", "read"]:
      try validateSafariReadOnly(options)
      try validateSafariTargetOptions(
        options, allowedOptions: ["window-index", "tab-index", "include", "max-bytes"])
      let page = try readPage(options: options)
      return try result(
        SafariPageResponse(page: page), human: pageHumanOutput(page), options: options)
    case ["pages", "read"]:
      try validateSafariReadOnly(options)
      try validateSafariTargetOptions(
        options, allowedOptions: ["window-index", "tab-index", "include", "max-bytes"])
      let page = try readPage(options: options)
      return try result(
        SafariPageResponse(page: page), human: pageHumanOutput(page), options: options)
    case ["tabs", "select"], ["tab", "select"]:
      try validateSafariStateActionOptions(options, allowedOptions: ["window-index", "tab-index"])
      let windowIndex = try safariRequiredPositiveInt("window-index", options: options)
      let tabIndex = try safariRequiredPositiveInt("tab-index", options: options)
      let tab = try backend.selectTab(windowIndex: windowIndex, tabIndex: tabIndex)
      return try result(SafariTabResponse(tab: tab), human: tabHumanOutput(tab), options: options)
    case ["tabs", "open"], ["tab", "open"]:
      try validateSafariStateActionOptions(options, allowedOptions: ["url", "window-index"])
      let tab = try backend.openTab(
        url: safariValidatedURL(try safariRequiredOption("url", options: options)),
        windowIndex: try safariOptionalPositiveInt("window-index", options: options)
      )
      return try result(SafariTabResponse(tab: tab), human: tabHumanOutput(tab), options: options)
    case ["tabs", "navigate"], ["tab", "navigate"]:
      try validateSafariStateActionOptions(
        options, allowedOptions: ["window-index", "tab-index", "url"])
      let tab = try backend.navigateTab(
        windowIndex: try safariRequiredPositiveInt("window-index", options: options),
        tabIndex: try safariRequiredPositiveInt("tab-index", options: options),
        url: safariValidatedURL(try safariRequiredOption("url", options: options))
      )
      return try result(SafariTabResponse(tab: tab), human: tabHumanOutput(tab), options: options)
    case ["search", "web"]:
      try validateSafariStateActionOptions(
        options, allowedOptions: ["query", "window-index", "tab-index"])
      let submitted = try backend.searchWeb(
        query: safariQuery(options),
        windowIndex: try safariOptionalPositiveInt("window-index", options: options),
        tabIndex: try safariOptionalPositiveInt("tab-index", options: options)
      )
      return try actionResult(
        operation: "safari.search.web",
        submitted: submitted,
        summary: ["query_sha256": safariSHA256Hex(safariQuery(options))],
        options: options
      )
    case ["tabs", "close"], ["tab", "close"]:
      try validateSafariTargetOptions(options, allowedOptions: ["window-index", "tab-index"])
      try validateSafariDryRunIntent(options, description: "Closing a Safari tab")
      return try dryRunAction(
        operation: "safari.tabs.close",
        scope: "safari-tab-close",
        summary: try tabSelectorSummary(options),
        options: options
      ) {
        try backend.closeTab(
          windowIndex: try safariRequiredPositiveInt("window-index", options: options),
          tabIndex: try safariRequiredPositiveInt("tab-index", options: options)
        )
      }
    case ["profile", "list"]:
      try validateSafariReadOnly(options)
      try validateSafariTargetOptions(options, allowedOptions: [])
      let profiles = try tabGroupBackend.listProfiles(verbose: options.verbose)
      return try result(
        SafariProfilesResponse(profiles: profiles),
        human: profilesHumanOutput(profiles),
        options: options
      )
    case ["profile", "read"]:
      try validateSafariReadOnly(options)
      try validateSafariTargetOptions(options, allowedOptions: ["id"])
      let id = try safariRequiredOption("id", options: options)
      guard let profile = try tabGroupBackend.readProfile(id: id, verbose: options.verbose) else {
        throw CLIError(
          code: .notFound, message: "Safari profile was not found.", details: ["id": id])
      }
      return try result(
        SafariProfileResponse(profile: profile), human: profileHumanOutput(profile),
        options: options)
    case ["tab", "group", "diagnose"]:
      try validateSafariReadOnly(options)
      try validateSafariTargetOptions(options, allowedOptions: [])
      let diagnostic = try tabGroupBackend.diagnoseTabGroups()
      return try result(
        diagnostic, human: tabGroupsDiagnoseHumanOutput(diagnostic), options: options)
    case ["tab", "group", "list"]:
      try validateSafariReadOnly(options)
      try validateSafariTargetOptions(
        options, allowedOptions: ["profile-id"], allowedFlags: ["include-hidden"])
      let response = try tabGroupBackend.listTabGroups(
        profileID: options.targetOption("profile-id"),
        includeHidden: options.hasTargetFlag("include-hidden"),
        verbose: options.verbose
      )
      return try result(
        response, human: tabGroupsHumanOutput(response.tabGroups), options: options)
    case ["tab", "group", "read"]:
      try validateSafariReadOnly(options)
      try validateSafariTargetOptions(options, allowedOptions: ["id"])
      let id = try safariRequiredOption("id", options: options)
      guard let response = try tabGroupBackend.readTabGroup(id: id, verbose: options.verbose) else {
        throw CLIError(
          code: .notFound, message: "Safari Tab Group was not found.", details: ["id": id])
      }
      return try result(
        response, human: tabGroupResponseHumanOutput(response), options: options)
    case ["tab", "group", "create"]:
      try validateSafariTargetOptions(options, allowedOptions: ["name", "url", "profile-id"])
      try validateSafariDryRunIntent(options, description: "Creating a Safari Tab Group")
      let name = try safariRequiredOption("name", options: options)
      let url = try options.targetOption("url").map { try safariValidatedURL($0) }
      let profileID = options.targetOption("profile-id")
      return try dryRunAction(
        operation: "safari.tab-group.create",
        scope: "safari-tab-group-create",
        summary: [
          "name_sha256": safariSHA256Hex(name),
          "url": url?.absoluteString ?? "",
          "profile_id": profileID ?? "",
        ],
        options: options
      ) {
        try tabGroupBackend.createTabGroup(name: name, url: url, profileID: profileID)
      }
    case ["tab", "group", "rename"]:
      try validateSafariTargetOptions(options, allowedOptions: ["id", "name"])
      try validateSafariDryRunIntent(options, description: "Renaming a Safari Tab Group")
      let id = try safariRequiredOption("id", options: options)
      let name = try safariRequiredOption("name", options: options)
      return try dryRunAction(
        operation: "safari.tab-group.rename",
        scope: "safari-tab-group-rename",
        summary: ["id": id, "name_sha256": safariSHA256Hex(name)],
        options: options
      ) {
        try tabGroupBackend.renameTabGroup(id: id, name: name)
      }
    case ["tab", "group", "delete"]:
      try validateSafariTargetOptions(options, allowedOptions: ["id"])
      try validateSafariDryRunIntent(options, description: "Deleting a Safari Tab Group")
      let id = try safariRequiredOption("id", options: options)
      return try dryRunAction(
        operation: "safari.tab-group.delete",
        scope: "safari-tab-group-delete",
        summary: ["id": id],
        options: options
      ) {
        try tabGroupBackend.deleteTabGroup(id: id)
      }
    case ["tab", "group", "add-tab"]:
      try validateSafariTargetOptions(options, allowedOptions: ["id", "url", "title"])
      try validateSafariDryRunIntent(options, description: "Adding a tab to a Safari Tab Group")
      let id = try safariRequiredOption("id", options: options)
      let url = try safariValidatedURL(try safariRequiredOption("url", options: options))
      let title = options.targetOption("title")
      return try dryRunAction(
        operation: "safari.tab-group.add-tab",
        scope: "safari-tab-group-add-tab",
        summary: [
          "id": id, "url": url.absoluteString, "title_sha256": safariSHA256Hex(title ?? ""),
        ],
        options: options
      ) {
        try tabGroupBackend.addTabToGroup(id: id, url: url, title: title)
      }
    case ["tab", "group", "remove-tab"]:
      try validateSafariTargetOptions(options, allowedOptions: ["id", "tab-id"])
      try validateSafariDryRunIntent(
        options, description: "Removing a tab from a Safari Tab Group")
      let id = try safariRequiredOption("id", options: options)
      let tabID = try safariRequiredOption("tab-id", options: options)
      return try dryRunAction(
        operation: "safari.tab-group.remove-tab",
        scope: "safari-tab-group-remove-tab",
        summary: ["id": id, "tab_id": tabID],
        options: options
      ) {
        try tabGroupBackend.removeTabFromGroup(id: id, tabID: tabID)
      }
    case ["tab", "group", "select"]:
      try validateSafariTargetOptions(options, allowedOptions: ["id", "window-index"])
      try validateSafariDryRunIntent(options, description: "Selecting a Safari Tab Group")
      let id = try safariRequiredOption("id", options: options)
      let windowIndex = try safariOptionalPositiveInt("window-index", options: options)
      return try dryRunAction(
        operation: "safari.tab-group.select",
        scope: "safari-tab-group-select",
        summary: ["id": id, "window_index": windowIndex.map(String.init) ?? ""],
        options: options
      ) {
        try tabGroupBackend.selectTabGroup(id: id, windowIndex: windowIndex)
      }
    case ["tab", "group", "open"]:
      try validateSafariTargetOptions(options, allowedOptions: ["id", "window-index"])
      try validateSafariDryRunIntent(options, description: "Opening a Safari Tab Group")
      let id = try safariRequiredOption("id", options: options)
      let windowIndex = try safariOptionalPositiveInt("window-index", options: options)
      return try dryRunAction(
        operation: "safari.tab-group.open",
        scope: "safari-tab-group-open",
        summary: ["id": id, "window_index": windowIndex.map(String.init) ?? ""],
        options: options
      ) {
        try tabGroupBackend.openTabGroup(id: id, windowIndex: windowIndex)
      }
    case ["reading-list", "add"]:
      try validateSafariTargetOptions(options, allowedOptions: ["url", "title", "preview-text"])
      try validateSafariDryRunIntent(options, description: "Adding a Safari Reading List item")
      let url = try safariValidatedURL(try safariRequiredOption("url", options: options))
      let summary = [
        "url": url.absoluteString,
        "title": options.targetOption("title") ?? "",
        "preview_text_sha256": safariSHA256Hex(options.targetOption("preview-text") ?? ""),
      ]
      return try dryRunAction(
        operation: "safari.reading-list.add",
        scope: "safari-reading-list-add",
        summary: summary,
        options: options
      ) {
        try backend.addReadingListItem(
          url: url,
          title: options.targetOption("title"),
          previewText: options.targetOption("preview-text")
        )
      }
    case ["bookmarks", "show"]:
      try validateSafariTargetOptions(
        options, allowedOptions: [], allowedFlags: ["allow-bookmarks"])
      try safariRequireFlag("allow-bookmarks", options: options)
      try validateSafariDryRunIntent(options, description: "Showing Safari bookmarks")
      return try dryRunAction(
        operation: "safari.bookmarks.show",
        scope: "safari-bookmarks-show",
        summary: ["gate": "strong-gate"],
        options: options
      ) {
        try backend.showBookmarks()
      }
    case ["pages", "email-contents"]:
      try validateSafariTargetOptions(
        options,
        allowedOptions: ["window-index", "tab-index"],
        allowedFlags: ["allow-email-contents"]
      )
      try safariRequireFlag("allow-email-contents", options: options)
      try validateSafariDryRunIntent(options, description: "Emailing Safari page contents")
      return try dryRunAction(
        operation: "safari.pages.email-contents",
        scope: "safari-email-contents",
        summary: try tabSelectorSummary(options).merging(["gate": "strong-gate"]) { current, _ in
          current
        },
        options: options
      ) {
        try backend.emailContents(
          windowIndex: try safariRequiredPositiveInt("window-index", options: options),
          tabIndex: try safariRequiredPositiveInt("tab-index", options: options)
        )
      }
    case ["pages", "evaluate-javascript"]:
      try validateSafariTargetOptions(
        options,
        allowedOptions: ["window-index", "tab-index", "script", "max-bytes"],
        allowedFlags: ["allow-javascript"]
      )
      try safariRequireFlag("allow-javascript", options: options)
      try validateSafariDryRunIntent(options, description: "Evaluating Safari JavaScript")
      return try javaScript(options)
    case ["extensions", "preferences", "show"]:
      try validateSafariTargetOptions(
        options, allowedOptions: ["extension-id"], allowedFlags: ["allow-hidden-sdef"])
      try safariRequireFlag("allow-hidden-sdef", options: options)
      try validateSafariDryRunIntent(options, description: "Showing Safari extension preferences")
      return try dryRunAction(
        operation: "safari.extensions.preferences.show",
        scope: "safari-hidden-sdef",
        summary: [
          "gate": "strong-gate",
          "extension_id_sha256": safariSHA256Hex(
            try safariRequiredOption("extension-id", options: options)),
        ],
        options: options
      ) {
        try backend.showExtensionsPreferences(
          extensionID: try safariRequiredOption("extension-id", options: options))
      }
    case ["extensions", "dispatch-message"]:
      try validateSafariTargetOptions(
        options, allowedOptions: ["payload-json"], allowedFlags: ["allow-hidden-sdef"])
      try safariRequireFlag("allow-hidden-sdef", options: options)
      try validateSafariDryRunIntent(
        options, description: "Dispatching a Safari extension message")
      let payload = try safariRequiredOption("payload-json", options: options)
      return try dryRunAction(
        operation: "safari.extensions.dispatch-message",
        scope: "safari-hidden-sdef",
        summary: ["gate": "strong-gate", "payload_sha256": safariSHA256Hex(payload)],
        options: options
      ) {
        try backend.dispatchMessageToExtension(payloadJSON: payload)
      }
    case ["privacy-report", "show"]:
      try validateSafariTargetOptions(
        options, allowedOptions: [], allowedFlags: ["allow-privacy-report"])
      try safariRequireFlag("allow-privacy-report", options: options)
      try validateSafariDryRunIntent(options, description: "Showing Safari Privacy Report")
      return try dryRunAction(
        operation: "safari.privacy-report.show",
        scope: "safari-privacy-report",
        summary: ["gate": "strong-gate"],
        options: options
      ) {
        try backend.showPrivacyReport()
      }
    case ["internals", "sync-plist"]:
      throw safariProofFailed(
        "safari internals sync-plist",
        reason: "Safari marks this command hidden and private-access-group protected.")
    case ["credit-card-settings", "show"]:
      throw safariProofFailed(
        "safari credit-card-settings show",
        reason: "Credential-adjacent Safari settings are not accepted production behavior.")
    default:
      return nil
    }
  }

  private func readPage(options: CLIOptions) throws -> SafariPageRecord {
    let include = try safariIncludeOptions(options)
    return try backend.readPage(
      windowIndex: try safariRequiredPositiveInt("window-index", options: options),
      tabIndex: try safariRequiredPositiveInt("tab-index", options: options),
      includeText: include.contains("text"),
      includeSource: include.contains("source"),
      maxBytes: try safariMaxBytes(options)
    )
  }

  private func validateSafariStateActionOptions(_ options: CLIOptions, allowedOptions: Set<String>)
    throws
  {
    try validateSafariReadOnly(options)
    try validateSafariTargetOptions(options, allowedOptions: allowedOptions)
  }

  private func dryRunAction(
    operation: String,
    scope: String,
    summary: [String: String],
    options: CLIOptions,
    submit: () throws -> Bool
  ) throws -> CLICommandResult {
    if options.dryRun {
      try validateSafariDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scope,
          category: .externalDispatch,
          allowFlags: ["--allow-external-dispatch"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-external-dispatch",
      in: options,
      category: .externalDispatch,
      message: "\(operation) dispatches to Safari and requires `--allow-external-dispatch`."
    )
    let submitted = try submit()
    return try actionResult(
      operation: operation, submitted: submitted, summary: summary, options: options)
  }

  private func javaScript(_ options: CLIOptions) throws -> CLICommandResult {
    let script = try safariRequiredOption("script", options: options)
    let summary = try tabSelectorSummary(options).merging([
      "gate": "strong-gate",
      "script_sha256": safariSHA256Hex(script),
    ]) { current, _ in current }
    return try dryRunJavaScript(summary: summary, script: script, options: options)
  }

  private func dryRunJavaScript(
    summary: [String: String],
    script: String,
    options: CLIOptions
  ) throws -> CLICommandResult {
    let operation = "safari.pages.evaluate-javascript"
    let scope = "safari-javascript"
    if options.dryRun {
      try validateSafariDryRunOptions(options)
      return try result(
        CLISafety.dryRun(
          target: target,
          operation: operation,
          summary: summary,
          scope: scope,
          category: .riskBoundSystemAction,
          allowFlags: ["--allow-external-dispatch"]
        ),
        human: "dry-run: \(operation)",
        options: options
      )
    }

    try CLISafety.requireFlag(
      "allow-external-dispatch",
      in: options,
      category: .riskBoundSystemAction,
      message:
        "Evaluating Safari JavaScript runs code in a browser context and requires `--allow-external-dispatch`."
    )
    let jsResult = try backend.evaluateJavaScript(
      windowIndex: try safariRequiredPositiveInt("window-index", options: options),
      tabIndex: try safariRequiredPositiveInt("tab-index", options: options),
      script: script,
      maxBytes: try safariMaxBytes(options, default: 4096)
    )
    return try result(jsResult, human: jsResult.result, options: options)
  }

  private func tabSelectorSummary(_ options: CLIOptions) throws -> [String: String] {
    [
      "window_index": "\(try safariRequiredPositiveInt("window-index", options: options))",
      "tab_index": "\(try safariRequiredPositiveInt("tab-index", options: options))",
    ]
  }

  private func actionResult(
    operation: String,
    submitted: Bool,
    summary: [String: String],
    options: CLIOptions
  ) throws -> CLICommandResult {
    try result(
      SafariActionResult(operation: operation, submitted: submitted, summaryFields: summary),
      human: "\(operation) submitted=\(submitted)",
      options: options
    )
  }

  private func result(_ payload: some Encodable, human: String, options: CLIOptions) throws
    -> CLICommandResult
  {
    if options.json {
      let envelope = CLISuccessEnvelope(data: payload, meta: ["target": target])
      return CLICommandResult(stdout: try CLIJSON.encodeString(envelope, pretty: options.pretty))
    }
    return CLICommandResult(stdout: human)
  }
}

private func safariIncludeOptions(_ options: CLIOptions) throws -> Set<String> {
  guard let value = options.targetOption("include"), !value.isEmpty else {
    return []
  }
  let parts = value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
  let include = Set(parts)
  let allowed: Set<String> = ["text", "source"]
  guard include.isSubset(of: allowed) else {
    throw CLIError(
      code: .validationError,
      message: "`--include` supports only `text` and `source`.",
      details: ["include": parts.joined(separator: ",")]
    )
  }
  return include
}

private func tabsHumanOutput(_ tabs: [SafariTabRecord]) -> String {
  tabs.map(tabHumanOutput).joined(separator: "\n")
}

private func tabHumanOutput(_ tab: SafariTabRecord) -> String {
  "\(tab.windowIndex):\(tab.index)\t\(tab.title)\t\(tab.url ?? "")"
}

private func pageHumanOutput(_ page: SafariPageRecord) -> String {
  var lines = [tabHumanOutput(page.tab)]
  if let text = page.text {
    lines.append(text)
  }
  if let source = page.source {
    lines.append(source)
  }
  return lines.joined(separator: "\n")
}

private func profilesHumanOutput(_ profiles: [SafariProfileRecord]) -> String {
  profiles.map(profileHumanOutput).joined(separator: "\n")
}

private func profileHumanOutput(_ profile: SafariProfileRecord) -> String {
  "\(profile.id)\t\(profile.name)\ttab_groups=\(profile.tabGroupCount)"
}

private func tabGroupsHumanOutput(_ groups: [SafariTabGroupRecord]) -> String {
  groups.map(tabGroupHumanOutput).joined(separator: "\n")
}

private func snapshotWindowsHumanOutput(_ response: SafariTabGroupWindowsResponse) -> String {
  var lines = response.windows.map(snapshotWindowHumanOutput)
  lines.append(contentsOf: response.warnings.map { "warning\t\($0)" })
  return lines.joined(separator: "\n")
}

private func snapshotWindowResponseHumanOutput(_ response: SafariSnapshotWindowResponse) -> String {
  var lines = [snapshotWindowHumanOutput(response.window)]
  lines.append(contentsOf: response.warnings.map { "warning\t\($0)" })
  return lines.joined(separator: "\n")
}

private func snapshotWindowTabsHumanOutput(_ response: SafariSnapshotWindowTabsResponse) -> String {
  var lines = [snapshotWindowHumanOutput(response.window)]
  lines.append(contentsOf: response.tabs.map(tabGroupTabHumanOutput))
  lines.append(contentsOf: response.warnings.map { "warning\t\($0)" })
  return lines.joined(separator: "\n")
}

private func snapshotWindowHumanOutput(_ window: SafariTabGroupWindowRecord) -> String {
  let sessionIndex = window.sessionIndex.map(String.init) ?? ""
  let profile = window.profile?.name ?? ""
  let group = window.activeTabGroup?.name ?? ""
  let groupId = window.activeTabGroup?.id ?? ""
  let hidden = window.activeTabGroup.map { "\($0.hidden)" } ?? ""
  return
    "\(sessionIndex)\twindow_id=\(window.id)\traw_id=\(window.rawId)\tprofile=\(profile)\tgroup=\(group)\tgroup_id=\(groupId)\thidden=\(hidden)\ttabs=\(window.resolvedTabCount)\tlast_session=\(window.isLastSession)\topen=\(window.open)"
}

private func tabGroupHumanOutput(_ group: SafariTabGroupRecord) -> String {
  let profile = group.profile.map { "\($0.id)" } ?? ""
  let sync = group.sync.map { "\($0.classification)" } ?? ""
  return
    "\(group.id)\t\(group.name)\ttabs=\(group.resolvedTabCount)\traw_children=\(group.tabCount)\tprofile=\(profile)\tstatus=\(sync)"
}

private func tabGroupResponseHumanOutput(_ response: SafariTabGroupResponse) -> String {
  var lines = [tabGroupHumanOutput(response.tabGroup)]
  lines.append(contentsOf: response.tabs.map(tabGroupTabHumanOutput))
  if !response.warnings.isEmpty {
    lines.append(contentsOf: response.warnings.map { "warning\t\($0)" })
  }
  return lines.joined(separator: "\n")
}

private func tabGroupTabHumanOutput(_ tab: SafariTabGroupTabRecord) -> String {
  "\(tab.id)\t\(tab.orderIndex)\t\(tab.title)\t\(tab.url ?? "")"
}

private func tabGroupsDiagnoseHumanOutput(_ diagnostic: SafariTabGroupsDiagnoseResponse) -> String {
  var lines = [
    "database\t\(diagnostic.databasePath)",
    "readable\t\(diagnostic.readable)",
    "schema_supported\t\(diagnostic.schemaSupported)",
  ]
  for table in diagnostic.tables {
    let count = diagnostic.counts[table].map(String.init) ?? ""
    lines.append("table\t\(table)\t\(count)")
  }
  if !diagnostic.missingRequiredColumns.isEmpty {
    lines.append(
      "missing_required_columns\t\(diagnostic.missingRequiredColumns.joined(separator: ","))")
  }
  lines.append(contentsOf: diagnostic.warnings.map { "warning\t\($0)" })
  return lines.joined(separator: "\n")
}
