import Foundation
import Utility

public struct NotesAppleScriptParityReader: NotesReading {
  public init() {}

  public func listAccounts() throws -> [NotesAccountRecord] {
    try runRows(
      """
      set output to {}
      tell application "Notes"
        repeat with eachAccount in accounts
          set end of output to {id of eachAccount as text, name of eachAccount as text}
        end repeat
      end tell
      return output
      """
    ).map { row in
      NotesAccountRecord(id: row[safe: 0] ?? "", name: row[safe: 1] ?? "")
    }
  }

  public func listFolders(account: String?, limit: Int) throws -> [NotesFolderRecord] {
    try runRows(
      """
      set output to {}
      tell application "Notes"
        repeat with eachAccount in accounts
          set accountName to name of eachAccount as text
          if \(appleScriptEqualsOrTrue("accountName", selector: account)) then
            repeat with eachFolder in folders of eachAccount
              if (count of output) is greater than or equal to \(limit) then return output
              set end of output to {id of eachFolder as text, name of eachFolder as text, accountName}
              if (count of output) is greater than or equal to \(limit) then return output
            end repeat
          end if
        end repeat
      end tell
      return output
      """
    ).map { row in
      NotesFolderRecord(
        id: row[safe: 0] ?? "",
        name: row[safe: 1] ?? "",
        accountName: row[safe: 2] ?? ""
      )
    }
  }

  public func listNotes(folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    try noteRows(folder: folder, query: nil, limit: limit, includeBody: false).map(noteSummary)
  }

  public func searchNotes(query: String, folder: String?, limit: Int) throws -> [NotesNoteSummary] {
    try noteRows(folder: folder, query: query, limit: limit, includeBody: false).map(noteSummary)
  }

  public func readNote(id: String) throws -> NotesNoteDetail? {
    try noteRowsById(id, includeBody: true).first.map(noteDetail)
  }

  public func readNotesByTitle(_ title: String, folder: String?, limit: Int) throws
    -> [NotesNoteDetail]
  {
    try noteRowsByTitle(title, folder: folder, limit: limit, includeBody: true).map(noteDetail)
  }

  private func noteRows(folder: String?, query: String?, limit: Int, includeBody: Bool) throws
    -> [[String]]
  {
    try runRows(
      """
      set output to {}
      tell application "Notes"
        repeat with eachAccount in accounts
          set accountName to name of eachAccount as text
          repeat with eachFolder in folders of eachAccount
            set folderName to name of eachFolder as text
            if \(appleScriptEqualsOrTrue("folderName", selector: folder)) then
              repeat with eachNote in notes of eachFolder
                if (count of output) is greater than or equal to \(limit) then return output
                set noteName to name of eachNote as text
                \(noteBodyAssignment(query: query, includeBody: includeBody))
                if \(appleScriptNoteMatches(query)) then
                  set end of output to {id of eachNote as text, noteName, folderName, accountName, creation date of eachNote as text, modification date of eachNote as text, \(includeBody ? "noteBody" : "\"\"")}
                  if (count of output) is greater than or equal to \(limit) then return output
                end if
              end repeat
            end if
          end repeat
        end repeat
      end tell
      return output
      """)
  }

  private func noteRowsById(_ id: String, includeBody: Bool) throws -> [[String]] {
    try runRows(
      """
      set output to {}
      tell application "Notes"
        repeat with eachAccount in accounts
          set accountName to name of eachAccount as text
          repeat with eachFolder in folders of eachAccount
            set folderName to name of eachFolder as text
            repeat with eachNote in notes of eachFolder
              if (id of eachNote as text) is equal to "\(appleScriptString(id))" then
                \(noteBodyAssignment(query: nil, includeBody: includeBody))
                set end of output to {id of eachNote as text, name of eachNote as text, folderName, accountName, creation date of eachNote as text, modification date of eachNote as text, \(includeBody ? "noteBody" : "\"\"")}
                return output
              end if
            end repeat
          end repeat
        end repeat
      end tell
      return output
      """)
  }

  private func noteRowsByTitle(_ title: String, folder: String?, limit: Int, includeBody: Bool)
    throws -> [[String]]
  {
    try runRows(
      """
      set output to {}
      tell application "Notes"
        repeat with eachAccount in accounts
          set accountName to name of eachAccount as text
          repeat with eachFolder in folders of eachAccount
            set folderName to name of eachFolder as text
            if \(appleScriptEqualsOrTrue("folderName", selector: folder)) then
              repeat with eachNote in notes of eachFolder
                if (count of output) is greater than or equal to \(limit) then return output
                set noteName to name of eachNote as text
                if noteName is equal to "\(appleScriptString(title))" then
                  \(noteBodyAssignment(query: nil, includeBody: includeBody))
                  set end of output to {id of eachNote as text, noteName, folderName, accountName, creation date of eachNote as text, modification date of eachNote as text, \(includeBody ? "noteBody" : "\"\"")}
                  if (count of output) is greater than or equal to \(limit) then return output
                end if
              end repeat
            end if
          end repeat
        end repeat
      end tell
      return output
      """)
  }
}
