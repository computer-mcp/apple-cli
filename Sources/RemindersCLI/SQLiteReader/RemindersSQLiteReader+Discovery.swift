import Foundation
import Utility

extension RemindersSQLiteReader {
  var remindersContainerURL: URL {
    homeDirectory
      .appendingPathComponent("Library", isDirectory: true)
      .appendingPathComponent("Group Containers", isDirectory: true)
      .appendingPathComponent("group.com.apple.reminders", isDirectory: true)
  }

  var remindersStoresURL: URL {
    remindersContainerURL
      .appendingPathComponent("Container_v1", isDirectory: true)
      .appendingPathComponent("Stores", isDirectory: true)
  }

  func directoryExists(_ url: URL) -> Bool {
    var isDirectory: ObjCBool = false
    return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
      && isDirectory.boolValue
  }

  func sqliteStoreFiles(in directory: URL) -> [RemindersStoreFileRecord] {
    guard
      let urls = try? FileManager.default.contentsOfDirectory(
        at: directory,
        includingPropertiesForKeys: [.fileSizeKey, .isReadableKey],
        options: [.skipsHiddenFiles])
    else {
      return []
    }

    return
      urls
      .filter { url in
        let name = url.lastPathComponent
        return name.hasPrefix("Data-") && name.hasSuffix(".sqlite")
      }
      .sorted { $0.lastPathComponent < $1.lastPathComponent }
      .map { url in
        let values = try? url.resourceValues(forKeys: [.fileSizeKey, .isReadableKey])
        return RemindersStoreFileRecord(
          path: url.path,
          sizeBytes: Int64(values?.fileSize ?? 0),
          isReadable: values?.isReadable ?? FileManager.default.isReadableFile(atPath: url.path)
        )
      }
  }
}
