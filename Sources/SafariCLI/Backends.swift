import Foundation
import Utility

public struct SafariAppleScriptBackend: SafariAutomating {
  public init() {}

  public func listWindows() throws -> [SafariWindowRecord] {
    let rows = try safariRunRows(
      """
      tell application "Safari"
        set output to {}
        set windowIndex to 0
        repeat with eachWindow in windows
          set windowIndex to windowIndex + 1
          set currentIndex to 0
          try
            set currentIndex to index of current tab of eachWindow as integer
          end try
          set tabCount to count of tabs of eachWindow
          set end of output to {windowIndex as text, currentIndex as text, tabCount as text}
        end repeat
        return output
      end tell
      """
    )
    return rows.compactMap { row in
      guard let index = safariInt(row[safariSafe: 0]) else {
        return nil
      }
      let current = safariInt(row[safariSafe: 1])
      return SafariWindowRecord(
        id: "safari-window:\(index)",
        index: index,
        currentTabIndex: current == 0 ? nil : current,
        tabCount: safariInt(row[safariSafe: 2]) ?? 0
      )
    }
  }

  public func listTabs(windowIndex: Int?) throws -> [SafariTabRecord] {
    let filter = windowIndex.map { "windowIndex is \(String($0))" } ?? "true"
    let rows = try safariRunRows(
      """
      tell application "Safari"
        set output to {}
        set windowIndex to 0
        repeat with eachWindow in windows
          set windowIndex to windowIndex + 1
          if \(filter) then
            set currentIndex to 0
            try
              set currentIndex to index of current tab of eachWindow as integer
            end try
            repeat with eachTab in tabs of eachWindow
              set tabIndex to index of eachTab as integer
              set tabName to name of eachTab as text
              set tabURL to URL of eachTab as text
              set tabVisible to visible of eachTab as boolean
              set tabCurrent to tabIndex is currentIndex
              set end of output to {windowIndex as text, tabIndex as text, tabName, tabURL, tabVisible as text, tabCurrent as text}
            end repeat
          end if
        end repeat
        return output
      end tell
      """
    )
    return rows.compactMap(safariTabRecord)
  }

  public func currentTab(windowIndex: Int?) throws -> SafariTabRecord? {
    let tabs = try listTabs(windowIndex: windowIndex)
    return tabs.first(where: \.current) ?? tabs.first
  }

  public func readPage(
    windowIndex: Int,
    tabIndex: Int,
    includeText: Bool,
    includeSource: Bool,
    maxBytes: Int
  ) throws -> SafariPageRecord {
    let rows = try safariRunRows(
      """
      tell application "Safari"
        set targetWindow to window \(windowIndex)
        set targetTab to tab \(tabIndex) of targetWindow
        set tabName to name of targetTab as text
        set tabURL to URL of targetTab as text
        set tabVisible to visible of targetTab as boolean
        set textValue to ""
        set sourceValue to ""
        if \(includeText ? "true" : "false") then
          set textValue to text of targetTab as text
        end if
        if \(includeSource ? "true" : "false") then
          set sourceValue to source of targetTab as text
        end if
        return {{\(windowIndex) as text, \(tabIndex) as text, tabName, tabURL, tabVisible as text, "true", textValue, sourceValue}}
      end tell
      """
    )
    guard let row = rows.first, let tab = safariTabRecord(Array(row.prefix(6))) else {
      throw CLIError(code: .notFound, message: "Safari tab was not found.")
    }

    var truncated = false
    var text: String?
    var source: String?
    if includeText {
      let clipped = safariTruncate(row[safariSafe: 6] ?? "", maxBytes: maxBytes)
      text = clipped.0
      truncated = truncated || clipped.1
    }
    if includeSource {
      let clipped = safariTruncate(row[safariSafe: 7] ?? "", maxBytes: maxBytes)
      source = clipped.0
      truncated = truncated || clipped.1
    }
    return SafariPageRecord(
      tab: tab,
      text: text,
      source: source,
      truncated: truncated,
      maxBytes: includeText || includeSource ? maxBytes : nil
    )
  }

  public func selectTab(windowIndex: Int, tabIndex: Int) throws -> SafariTabRecord {
    try safariRunVoid(
      """
      tell application "Safari"
        set current tab of window \(windowIndex) to tab \(tabIndex) of window \(windowIndex)
      end tell
      """
    )
    return try readTab(windowIndex: windowIndex, tabIndex: tabIndex)
  }

  public func openTab(url: URL, windowIndex: Int?) throws -> SafariTabRecord {
    let escapedURL = safariAppleScriptString(url.absoluteString)
    let windowScript: String
    if let windowIndex {
      windowScript = """
          set targetWindow to window \(windowIndex)
          set targetTab to make new tab at end of tabs of targetWindow with properties {URL:"\(escapedURL)"}
          set current tab of targetWindow to targetTab
          set tabIndex to index of targetTab as integer
          return {{\(windowIndex) as text, tabIndex as text, name of targetTab as text, URL of targetTab as text, visible of targetTab as text, "true"}}
        """
    } else {
      windowScript = """
          set targetDocument to make new document with properties {URL:"\(escapedURL)"}
          set targetTab to current tab of front window
          set tabIndex to index of targetTab as integer
          return {{"1", tabIndex as text, name of targetTab as text, URL of targetTab as text, visible of targetTab as text, "true"}}
        """
    }
    let rows = try safariRunRows(
      """
      tell application "Safari"
      \(windowScript)
      end tell
      """
    )
    guard let tab = rows.first.flatMap(safariTabRecord) else {
      throw CLIError(code: .backendUnavailable, message: "Safari did not report the opened tab.")
    }
    return tab
  }

  public func navigateTab(windowIndex: Int, tabIndex: Int, url: URL) throws -> SafariTabRecord {
    let escapedURL = safariAppleScriptString(url.absoluteString)
    try safariRunVoid(
      """
      tell application "Safari"
        set URL of tab \(tabIndex) of window \(windowIndex) to "\(escapedURL)"
      end tell
      """
    )
    return try readTab(windowIndex: windowIndex, tabIndex: tabIndex)
  }

  public func closeTab(windowIndex: Int, tabIndex: Int) throws -> Bool {
    try safariRunVoid(
      """
      tell application "Safari"
        close tab \(tabIndex) of window \(windowIndex)
      end tell
      """
    )
    return true
  }

  public func addReadingListItem(url: URL, title: String?, previewText: String?) throws -> Bool {
    let titleClause = title.map { " with title \"\(safariAppleScriptString($0))\"" } ?? ""
    let previewClause =
      previewText.map { " and preview text \"\(safariAppleScriptString($0))\"" } ?? ""
    try safariRunVoid(
      """
      tell application "Safari"
        add reading list item "\(safariAppleScriptString(url.absoluteString))"\(titleClause)\(previewClause)
      end tell
      """
    )
    return true
  }

  public func searchWeb(query: String, windowIndex: Int?, tabIndex: Int?) throws -> Bool {
    let targetClause = safariTargetClause(
      commandParameter: "in", windowIndex: windowIndex, tabIndex: tabIndex)
    try safariRunVoid(
      """
      tell application "Safari"
        search the web\(targetClause) for "\(safariAppleScriptString(query))"
      end tell
      """
    )
    return true
  }

  public func showBookmarks() throws -> Bool {
    try safariRunVoid(
      """
      tell application "Safari"
        show bookmarks
      end tell
      """
    )
    return true
  }

  public func emailContents(windowIndex: Int, tabIndex: Int) throws -> Bool {
    try safariRunVoid(
      """
      tell application "Safari"
        email contents of tab \(tabIndex) of window \(windowIndex)
      end tell
      """
    )
    return true
  }

  public func evaluateJavaScript(
    windowIndex: Int,
    tabIndex: Int,
    script: String,
    maxBytes: Int
  ) throws -> SafariJavaScriptResult {
    let output = try safariRunString(
      """
      tell application "Safari"
        set jsResult to do JavaScript "\(safariAppleScriptString(script))" in tab \(tabIndex) of window \(windowIndex)
        try
          return jsResult as text
        on error
          return ""
        end try
      end tell
      """
    )
    let clipped = safariTruncate(output, maxBytes: maxBytes)
    return SafariJavaScriptResult(
      operation: "safari.pages.evaluate-javascript",
      result: clipped.0,
      truncated: clipped.1,
      resultSHA256: safariSHA256Hex(clipped.0)
    )
  }

  public func showExtensionsPreferences(extensionID: String) throws -> Bool {
    try safariRunVoid(
      """
      tell application "Safari"
        show extensions preferences "\(safariAppleScriptString(extensionID))"
      end tell
      """
    )
    return true
  }

  public func dispatchMessageToExtension(payloadJSON: String) throws -> Bool {
    try safariRunVoid(
      """
      tell application "Safari"
        dispatch message to extension {payloadJSON:"\(safariAppleScriptString(payloadJSON))"}
      end tell
      """
    )
    return true
  }

  public func showPrivacyReport() throws -> Bool {
    try safariRunVoid(
      """
      tell application "Safari"
        show privacy report
      end tell
      """
    )
    return true
  }

  private func readTab(windowIndex: Int, tabIndex: Int) throws -> SafariTabRecord {
    let rows = try safariRunRows(
      """
      tell application "Safari"
        set targetTab to tab \(tabIndex) of window \(windowIndex)
        set currentIndex to index of current tab of window \(windowIndex) as integer
        return {{\(windowIndex) as text, \(tabIndex) as text, name of targetTab as text, URL of targetTab as text, visible of targetTab as text, (\(tabIndex) is currentIndex) as text}}
      end tell
      """
    )
    guard let tab = rows.first.flatMap(safariTabRecord) else {
      throw CLIError(code: .notFound, message: "Safari tab was not found.")
    }
    return tab
  }
}

private func safariTargetClause(commandParameter: String, windowIndex: Int?, tabIndex: Int?)
  -> String
{
  guard let windowIndex, let tabIndex else {
    return ""
  }
  return " \(commandParameter) tab \(tabIndex) of window \(windowIndex)"
}

private func safariTabRecord(_ row: [String]) -> SafariTabRecord? {
  guard let windowIndex = safariInt(row[safariSafe: 0]),
    let tabIndex = safariInt(row[safariSafe: 1])
  else {
    return nil
  }
  return SafariTabRecord(
    id: "safari-tab:\(windowIndex):\(tabIndex)",
    windowIndex: windowIndex,
    index: tabIndex,
    title: row[safariSafe: 2] ?? "",
    url: (row[safariSafe: 3] ?? "").isEmpty ? nil : row[safariSafe: 3],
    visible: safariBool(row[safariSafe: 4]),
    current: safariBool(row[safariSafe: 5])
  )
}
