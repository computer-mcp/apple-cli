import CryptoKit
import Darwin
import Foundation

struct ReminderAttachmentSignature: Equatable {
  let sizeBytes: Int64
  let sha512: String
}

func attachmentSHA512(_ value: String) -> String? {
  let lower = value.lowercased()
  guard lower.utf8.count == 128,
    lower.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) })
  else { return nil }
  return lower
}

enum ReminderAttachmentFiles {
  static func physicalPath(_ path: String) -> String {
    let components = path.split(separator: "/").filter { $0 != "." }
    let prefix = ["tmp", "var"].contains(components.first.map(String.init) ?? "") ? "/private" : ""
    return prefix + "/" + components.joined(separator: "/")
  }

  static func openDirectory(_ path: String) throws -> Int32 {
    let flags = O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
    var directory = open("/", flags)
    guard directory >= 0 else { throw attachmentPOSIXError(errno) }
    for component in physicalPath(path).split(separator: "/") {
      guard component != ".." else {
        close(directory)
        throw POSIXError(.EINVAL)
      }
      let next = openat(directory, String(component), flags)
      let error = errno
      close(directory)
      guard next >= 0 else { throw attachmentPOSIXError(error) }
      directory = next
    }
    return directory
  }

  static func signature(of url: URL, copyingTo output: FileHandle? = nil) throws
    -> ReminderAttachmentSignature
  {
    let parent: Int32
    do {
      parent = try openDirectory(url.deletingLastPathComponent().path)
    } catch let error as POSIXError where error.code == .ENOENT {
      throw ReminderAttachmentStatus.missingLocalFile
    } catch {
      throw ReminderAttachmentStatus.unreadable
    }
    defer { close(parent) }
    let input = openat(
      parent, url.lastPathComponent, O_RDONLY | O_NOFOLLOW | O_NONBLOCK | O_CLOEXEC)
    guard input >= 0 else {
      throw errno == ENOENT ? ReminderAttachmentStatus.missingLocalFile : .unreadable
    }
    let handle = FileHandle(fileDescriptor: input, closeOnDealloc: true)
    defer { try? handle.close() }
    var before = stat()
    guard fstat(input, &before) == 0, before.st_mode & S_IFMT == S_IFREG else {
      throw ReminderAttachmentStatus.unreadable
    }

    var hash = SHA512()
    var size: Int64 = 0
    while true {
      let chunk: Data?
      do {
        chunk = try handle.read(upToCount: 1_048_576)
      } catch {
        throw ReminderAttachmentStatus.unreadable
      }
      guard let chunk, !chunk.isEmpty else { break }
      hash.update(data: chunk)
      size += Int64(chunk.count)
      try output?.write(contentsOf: chunk)
    }
    var after = stat()
    guard fstat(input, &after) == 0, size == before.st_size, size == after.st_size,
      before.st_mtimespec.tv_sec == after.st_mtimespec.tv_sec,
      before.st_mtimespec.tv_nsec == after.st_mtimespec.tv_nsec,
      before.st_ctimespec.tv_sec == after.st_ctimespec.tv_sec,
      before.st_ctimespec.tv_nsec == after.st_ctimespec.tv_nsec
    else {
      throw ReminderAttachmentStatus.integrityMismatch
    }
    return ReminderAttachmentSignature(
      sizeBytes: size, sha512: hash.finalize().map { String(format: "%02x", $0) }.joined())
  }

  static func cacheOriginal(for digest: String, account: UUID, in files: URL) throws -> URL {
    let accounts = try directoryEntries(in: files).filter {
      $0.hasPrefix("Account-") && UUID(uuidString: String($0.dropFirst(8))) == account
    }
    guard let accountDirectory = accounts.first else {
      throw ReminderAttachmentStatus.missingLocalFile
    }
    guard accounts.count == 1 else { throw ReminderAttachmentStatus.ambiguousLocalFile }
    let attachments = files.appendingPathComponent(accountDirectory, isDirectory: true)
      .appendingPathComponent("Attachments", isDirectory: true)
    let matches = try directoryEntries(in: attachments).filter { name in
      let lower = name.lowercased()
      return lower == digest || lower.hasPrefix(digest + ".")
    }
    guard let name = matches.first else { throw ReminderAttachmentStatus.missingLocalFile }
    guard matches.count == 1 else { throw ReminderAttachmentStatus.ambiguousLocalFile }
    return attachments.appendingPathComponent(name)
  }

  private static func directoryEntries(in url: URL) throws -> [String] {
    do {
      let directory = try openDirectory(url.path)
      defer { close(directory) }
      // F_GETPATH uses the opened directory's physical path. Candidate files are
      // opened independently with no symlinks and must still match the stored hash.
      var path = [CChar](repeating: 0, count: Int(MAXPATHLEN))
      guard fcntl(directory, F_GETPATH, &path) == 0 else { throw attachmentPOSIXError(errno) }
      let bytes = path.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
      return try FileManager.default.contentsOfDirectory(
        atPath: String(decoding: bytes, as: UTF8.self))
    } catch let error as POSIXError where error.code == .ENOENT {
      throw ReminderAttachmentStatus.missingLocalFile
    } catch {
      throw ReminderAttachmentStatus.unreadable
    }
  }
}

func attachmentPOSIXError(_ code: Int32) -> POSIXError {
  POSIXError(POSIXErrorCode(rawValue: code) ?? .EIO)
}
