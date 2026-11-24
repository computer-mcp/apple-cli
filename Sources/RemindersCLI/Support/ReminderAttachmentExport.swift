import Darwin
import Foundation
import UniformTypeIdentifiers
import Utility

struct ReminderAttachmentExportEntry {
  let name: String
  let original: ReminderAttachmentOriginal
  let receipt: ReminderAttachmentExportedFile
}

struct ReminderAttachmentExportDestination {
  let path: String
  let name: String
  let parentPath: String
  let all: Bool

  init(_ output: String, all: Bool, protectedDirectory: URL) throws {
    let expanded = (output as NSString).expandingTildeInPath
    let components = expanded.split(separator: "/")
    guard let basename = components.last, basename != ".", !components.contains(".."),
      !expanded.utf8.contains(0), all || !expanded.hasSuffix("/")
    else {
      throw CLIError(code: .validationError, message: "Supply a new output path without traversal.")
    }
    let absolute =
      expanded.hasPrefix("/") ? expanded : FileManager.default.currentDirectoryPath + "/" + expanded
    let physical = ReminderAttachmentFiles.physicalPath(absolute)
    let normalized = physical.lowercased()
    let dataMount = "/system/volumes/data"
    let checked =
      normalized.hasPrefix(dataMount + "/")
      ? String(normalized.dropFirst(dataMount.count)) : normalized
    let protectedPath = ReminderAttachmentFiles.physicalPath(protectedDirectory.path).lowercased()
    guard checked != protectedPath, !checked.hasPrefix(protectedPath + "/") else {
      throw CLIError(
        code: .unsafeMutationRefused, message: "Choose an output outside the Reminders container.")
    }
    path = physical
    name = String(basename)
    parentPath = (physical as NSString).deletingLastPathComponent
    self.all = all
  }

  func withParent<T>(_ body: (Int32) throws -> T) throws -> T {
    let parent: Int32
    do {
      parent = try ReminderAttachmentFiles.openDirectory(parentPath)
    } catch {
      throw CLIError(
        code: .validationError,
        message: "The output parent must be an existing accessible directory without symlinks.")
    }
    defer { close(parent) }
    var existing = stat()
    guard fstatat(parent, name, &existing, AT_SYMLINK_NOFOLLOW) != 0 else {
      throw attachmentDestinationExists()
    }
    guard errno == ENOENT else { throw attachmentOutputError(errno) }
    return try body(parent)
  }

  func entries(for resolutions: [ReminderAttachmentResolution]) throws
    -> [ReminderAttachmentExportEntry]
  {
    var names: Set<String> = []
    return try resolutions.map { resolution in
      let inspection = resolution.inspection
      guard let original = resolution.original else {
        throw CLIError(
          code: inspection.status == .unsupportedType ? .unsupportedOperation : .backendUnavailable,
          message: "Original attachment bytes are unavailable for export.",
          details: [
            "attachment_id": inspection.id.uuidString, "status": inspection.status.rawValue,
          ])
      }
      let fileName = all ? uniqueAttachmentName(inspection, taken: &names) : name
      return ReminderAttachmentExportEntry(
        name: fileName, original: original,
        receipt: ReminderAttachmentExportedFile(
          attachmentId: inspection.id, fileName: inspection.fileName,
          typeIdentifier: inspection.typeIdentifier, path: all ? path + "/" + fileName : path,
          sizeBytes: original.signature.sizeBytes, sha512: original.signature.sha512,
          integrity: original.integrity))
    }
  }

  func publish(_ entries: [ReminderAttachmentExportEntry], in parent: Int32) throws {
    let stageName = ".apple-reminders-export-" + UUID().uuidString
    guard mkdirat(parent, stageName, 0o700) == 0 else { throw attachmentOutputError(errno) }
    let stage = openat(parent, stageName, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
    guard stage >= 0 else {
      let error = errno
      unlinkat(parent, stageName, AT_REMOVEDIR)
      throw attachmentOutputError(error)
    }
    defer {
      var opened = stat()
      var named = stat()
      if fstat(stage, &opened) == 0, fstatat(parent, stageName, &named, AT_SYMLINK_NOFOLLOW) == 0,
        opened.st_ino == named.st_ino, opened.st_dev == named.st_dev
      {
        unlinkat(parent, stageName, AT_REMOVEDIR)
      }
      close(stage)
    }

    let batchName = "files"
    let stagingFiles: Int32
    if all {
      guard mkdirat(stage, batchName, 0o700) == 0 else { throw attachmentOutputError(errno) }
      stagingFiles = openat(stage, batchName, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
      guard stagingFiles >= 0 else {
        let error = errno
        unlinkat(stage, batchName, AT_REMOVEDIR)
        throw attachmentOutputError(error)
      }
    } else {
      stagingFiles = stage
    }
    var staged: [String] = []
    var publishedDirectory = false
    defer {
      if !publishedDirectory {
        for file in staged {
          unlinkat(stagingFiles, file, 0)
        }
      }
      if all {
        close(stagingFiles)
        if !publishedDirectory { unlinkat(stage, batchName, AT_REMOVEDIR) }
      }
    }

    for entry in entries {
      let descriptor = openat(
        stagingFiles, entry.name, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o600)
      guard descriptor >= 0 else { throw attachmentOutputError(errno) }
      staged.append(entry.name)
      let output = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
      do {
        let signature = try ReminderAttachmentFiles.signature(
          of: entry.original.url, copyingTo: output)
        guard signature == entry.original.signature else {
          throw ReminderAttachmentStatus.integrityMismatch
        }
        try output.close()
      } catch let status as ReminderAttachmentStatus {
        throw CLIError(
          code: .backendUnavailable, message: "The original could not be verified during export.",
          details: [
            "attachment_id": entry.receipt.attachmentId.uuidString, "status": status.rawValue,
          ])
      } catch {
        throw CLIError(
          code: .backendUnavailable, message: "The staged attachment could not be written.")
      }
    }

    // The final destination is created only after all bytes have been verified.
    // RENAME_EXCL also refuses a destination created after preflight.
    let result = renameatx_np(stage, all ? batchName : name, parent, name, UInt32(RENAME_EXCL))
    guard result == 0 else {
      let error = errno
      throw error == EEXIST || error == ENOTEMPTY
        ? attachmentDestinationExists() : attachmentOutputError(error)
    }
    publishedDirectory = all
  }

  private func uniqueAttachmentName(
    _ record: ReminderAttachmentInspection, taken: inout Set<String>
  ) -> String {
    let preferredExtension = record.typeIdentifier.flatMap {
      UTType($0)?.preferredFilenameExtension
    }
    let fallback =
      "attachment-" + record.id.uuidString
      + (preferredExtension.map { isSafeAttachmentName($0) ? "." + $0 : "" } ?? "")
    let original = record.fileName.flatMap { isSafeAttachmentName($0) ? $0 : nil } ?? fallback
    let ext = (original as NSString).pathExtension
    let suffix = ext.isEmpty ? "" : "." + ext
    let stem = (original as NSString).deletingPathExtension
    var candidate = original
    var index = 2
    while !taken.insert(candidate.precomposedStringWithCanonicalMapping.lowercased()).inserted {
      let numbered = "\(stem) (\(index))\(suffix)"
      candidate = isSafeAttachmentName(numbered) ? numbered : "\(fallback)-\(index)"
      index += 1
    }
    return candidate
  }

  private func isSafeAttachmentName(_ name: String) -> Bool {
    !name.isEmpty && name != "." && name != ".." && name.utf8.count <= Int(NAME_MAX)
      && !name.contains("/") && !name.contains("\\")
      && !name.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains)
  }
}

private func attachmentDestinationExists() -> CLIError {
  CLIError(code: .unsafeMutationRefused, message: "The attachment destination already exists.")
}

private func attachmentOutputError(_ error: Int32) -> CLIError {
  CLIError(
    code: error == EACCES || error == EPERM ? .permissionDenied : .backendUnavailable,
    message: "The attachment destination could not be written.",
    details: ["errno": String(error)])
}
