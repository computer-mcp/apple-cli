import AppKit
import Darwin
import Foundation
import ImageIO
import UniformTypeIdentifiers
import Utility

public struct PhotosFileBackend: @unchecked Sendable {
  private static let exportKeepFileName = ".apple-cli-photos-keep"
  private let fileManager: FileManager

  public init(fileManager: FileManager = .default) {
    self.fileManager = fileManager
  }

  public func backupLibrary(source: String, destination: String) throws -> Bool {
    let sourceURL = URL(fileURLWithPath: source)
    let destinationURL = URL(fileURLWithPath: destination)
    guard sourceURL.pathExtension == "photoslibrary" else {
      throw CLIError(
        code: .validationError, message: "`--library` must point to a .photoslibrary package.")
    }
    if destinationURL.path.hasPrefix(sourceURL.path) {
      throw CLIError(
        code: .validationError,
        message: "Photos library backup destination cannot be inside the source library."
      )
    }
    if fileManager.fileExists(atPath: destinationURL.path) {
      throw CLIError(code: .validationError, message: "Backup destination already exists.")
    }
    try fileManager.copyItem(at: sourceURL, to: destinationURL)
    return true
  }

  public func exportPlaceholder(plan: PhotosExportPlan) throws -> PhotosExportResult {
    try fileManager.createDirectory(
      at: URL(fileURLWithPath: plan.destination),
      withIntermediateDirectories: true
    )
    return PhotosExportResult(exported: 0, destination: plan.destination)
  }

  public func exportItems(items: [PhotosMediaItemRecord], plan: PhotosExportPlan) throws
    -> PhotosExportResult
  {
    var exported = 0
    var skipped = 0
    var missing = 0
    var errors: [String] = []
    var resources: [PhotosExportResourceRecord] = []
    var exportedUUIDs: [String] = []
    var skippedUUIDs: [String] = []
    var missingUUIDs: [String] = []
    let destinationURL = URL(fileURLWithPath: plan.destination)
    let skipRaw = plan.options["skip_raw"] == "true"
    let skipRawJPEG = plan.options["skip_raw_jpeg"] == "true"
    let currentName = plan.options["current_name"] == "true"
    let touchFile = plan.options["touch_file"] == "true"
    let skipEdited = plan.options["skip_edited"] == "true"
    let skipOriginalIfEdited = plan.options["skip_original_if_edited"] == "true"
    let skipBursts = plan.options["skip_bursts"] == "true"
    let skipLive = plan.options["skip_live"] == "true"
    let update = plan.options["update"] == "true"
    let forceUpdate = plan.options["force_update"] == "true"
    let onlyNew = plan.options["only_new"] == "true"
    let ignoreSignature = plan.options["ignore_signature"] == "true"
    let overwrite = plan.options["overwrite"] == "true"
    let exportPreview = plan.options["preview"] == "true"
    let previewIfMissing = plan.options["preview_if_missing"] == "true"
    let previewSuffix = plan.options["preview_suffix"] ?? "_preview"
    let editedSuffix = plan.options["edited_suffix"] ?? "_edited"
    let exportAAE = plan.options["export_aae"] == "true"
    let convertToJPEG = plan.options["convert_to_jpeg"] == "true"
    let fixOrientation = plan.options["fix_orientation"] == "true"
    let cleanupEnabled = plan.options["cleanup"] == "true"
    let cleanupKeepRules = exportLinesOption(plan.options["cleanup_keep"])
    let cleanupCommands = exportLinesOption(plan.options["cleanup_command"])
    let cleanupCommandError = plan.options["cleanup_command_error"] ?? ""
    let metadataFields = exportLinesOption(plan.options["metadata_fields"])
    let metadataExiftoolPath = plan.options["metadata_exiftool_path"].flatMap {
      $0.isEmpty ? nil : $0
    }
    let metadataFinderTagTemplates = exportLinesOption(
      plan.options["metadata_finder_tag_templates"])
    let metadataXattrTemplates = try exportXattrTemplates(
      exportLinesOption(plan.options["metadata_xattr_templates"]))
    let metadataTimeoutSeconds = try exportPositiveIntOption(
      plan.options["metadata_timeout_seconds"],
      name: "metadata_timeout_seconds",
      defaultValue: 10,
      maximum: 300
    )
    let metadataOutputCap = try exportPositiveIntOption(
      plan.options["metadata_output_cap"],
      name: "metadata_output_cap",
      defaultValue: 64 * 1024,
      maximum: 4 * 1024 * 1024
    )
    let cleanupTimeoutSeconds = try exportPositiveIntOption(
      plan.options["cleanup_timeout_seconds"],
      name: "cleanup_timeout_seconds",
      defaultValue: 10,
      maximum: 300
    )
    let cleanupOutputCap = try exportPositiveIntOption(
      plan.options["cleanup_output_cap"],
      name: "cleanup_output_cap",
      defaultValue: 64 * 1024,
      maximum: 4 * 1024 * 1024
    )
    let jpegQuality = try exportJPEGQualityOption(plan.options["jpeg_quality"] ?? "1.0")
    let jpegExtension = try exportJPEGExtensionOption(plan.options["jpeg_extension"] ?? "jpeg")
    var temporaryTransformURLs: [URL] = []
    defer {
      for url in temporaryTransformURLs {
        try? fileManager.removeItem(at: url)
      }
    }
    let retryCount = try exportNonNegativeIntOption(
      plan.options["retry_count"],
      name: "retry_count",
      maximum: 5
    )
    let retryWaitSeconds = try exportNonNegativeIntOption(
      plan.options["retry_wait_seconds"],
      name: "retry_wait_seconds",
      maximum: 60
    )
    try withFileRetry(retryCount: retryCount, retryWaitSeconds: retryWaitSeconds) {
      try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)
    }
    let skipUUIDs = Set(
      (plan.options["skip_uuids"] ?? "")
        .split(whereSeparator: \.isNewline)
        .map(String.init)
    )
    let filenameTemplate = plan.options["filename_template"].flatMap { $0.isEmpty ? nil : $0 }
    let directoryTemplate = plan.options["directory_template"].flatMap { $0.isEmpty ? nil : $0 }
    let signatureTemplate = plan.options["signature_template"].flatMap { $0.isEmpty ? nil : $0 }
    let stateURL = plan.options["state_db"]
      .flatMap { $0.isEmpty ? nil : URL(fileURLWithPath: $0) }
    let priorResources =
      try stateURL.map { try readExportState(from: $0).latestResourcesByKey() } ?? [:]
    let exportedAt = ISO8601DateFormatter().string(from: Date())

    for item in items {
      var didExportItem = false
      var didSkipItem = false
      var didMissItem = false
      defer {
        if didExportItem {
          exportedUUIDs.append(item.uuid)
        }
        if didSkipItem {
          skippedUUIDs.append(item.uuid)
        }
        if didMissItem {
          missingUUIDs.append(item.uuid)
        }
      }
      func markSkipped() {
        skipped += 1
        didSkipItem = true
      }
      func markMissing() {
        missing += 1
        didMissItem = true
      }

      if skipUUIDs.contains(item.uuid)
        || (skipBursts && item.traits.contains("burst"))
      {
        markSkipped()
        continue
      }

      let rawSourcePath = item.rawPath
      let hasRawSource =
        rawSourcePath.map { fileManager.fileExists(atPath: $0) } ?? false
      let shouldCopyPrimary =
        !(skipRawJPEG && hasRawSource) && !(skipOriginalIfEdited && item.edited)
      let shouldCopyRaw = (!skipRaw || skipRawJPEG) && !(skipOriginalIfEdited && item.edited)

      func exportResource(
        sourcePath: String,
        kind: String,
        preferredFilename: String? = nil,
        sourceSignatureOverride: String? = nil,
        semanticSourcePath: String? = nil
      ) throws -> Bool {
        let sourceSignature: String
        if let sourceSignatureOverride {
          sourceSignature = sourceSignatureOverride
        } else {
          sourceSignature = try exportFileSignature(path: sourcePath)
        }
        let semanticSignature = exportSemanticSignature(
          item: item,
          kind: kind,
          sourcePath: semanticSourcePath ?? sourcePath,
          signatureTemplate: signatureTemplate
        )
        let key = PhotosExportStateDatabase.resourceKey(uuid: item.uuid, kind: kind)
        if onlyNew, priorResources[key] != nil {
          markSkipped()
          return false
        }

        var destinationOverride: URL?
        let replaceExisting = overwrite || update || forceUpdate
        if update || forceUpdate, let prior = priorResources[key] {
          destinationOverride = URL(fileURLWithPath: prior.path)
          if fileManager.fileExists(atPath: prior.path) {
            let currentDestinationSignature = try exportFileSignature(path: prior.path)
            let destinationChanged =
              !ignoreSignature && currentDestinationSignature != prior.destinationSignature
            let sourceChanged = sourceSignature != prior.sourceSignature
            let metadataChanged = forceUpdate && semanticSignature != prior.semanticSignature
            if !destinationChanged && !sourceChanged && !metadataChanged {
              markSkipped()
              return false
            }
          }
        }

        let destination = try withFileRetry(
          retryCount: retryCount,
          retryWaitSeconds: retryWaitSeconds
        ) {
          try copyExportFile(
            sourcePath: sourcePath,
            item: item,
            itemUUID: item.uuid,
            kind: kind,
            filenameTemplate: filenameTemplate,
            directoryTemplate: directoryTemplate,
            currentName: currentName,
            touchFile: touchFile,
            to: destinationURL,
            destinationOverride: destinationOverride,
            replaceExisting: replaceExisting,
            preferredNameOverride: preferredFilename
          )
        }
        let destinationSignature = try exportFileSignature(path: destination.path)
        resources.append(
          PhotosExportResourceRecord(
            uuid: item.uuid,
            kind: kind,
            path: destination.path,
            sourceSignature: sourceSignature,
            destinationSignature: destinationSignature,
            semanticSignature: semanticSignature,
            exportedAt: exportedAt
          )
        )
        return true
      }

      var didExportPreview = false
      let previewSourcePath = item.previewPaths.first { fileManager.fileExists(atPath: $0) }
      let itemTraits = Set(item.traits)

      if shouldCopyPrimary {
        if let sourcePath = item.originalPath, fileManager.fileExists(atPath: sourcePath) {
          do {
            if convertToJPEG
              && (fixOrientation || shouldConvertPrimaryToJPEG(sourcePath: sourcePath, item: item))
            {
              let transformed = try temporaryJPEGExport(
                item: item,
                itemUUID: item.uuid,
                sourcePath: sourcePath,
                currentName: currentName,
                filenameTemplate: filenameTemplate,
                jpegExtension: jpegExtension,
                jpegQuality: jpegQuality,
                fixOrientation: fixOrientation
              )
              temporaryTransformURLs.append(transformed.temporaryDirectory)
              if try exportResource(
                sourcePath: transformed.path,
                kind: "converted_jpeg",
                preferredFilename: transformed.preferredFilename,
                sourceSignatureOverride: transformed.sourceSignature,
                semanticSourcePath: sourcePath
              ) {
                didExportItem = true
              }
            } else if try exportResource(sourcePath: sourcePath, kind: "original") {
              didExportItem = true
            }
          } catch {
            markSkipped()
            errors.append("\(item.uuid): \(error)")
          }
        } else if previewIfMissing, let previewSourcePath {
          do {
            let previewFilename = previewExportFilename(
              for: item,
              previewPath: previewSourcePath,
              itemUUID: item.uuid,
              filenameTemplate: filenameTemplate,
              previewSuffix: previewSuffix
            )
            if try exportResource(
              sourcePath: previewSourcePath,
              kind: "preview",
              preferredFilename: previewFilename
            ) {
              didExportItem = true
              didExportPreview = true
            }
          } catch {
            markSkipped()
            errors.append("\(item.uuid) preview: \(error)")
          }
        } else {
          markMissing()
          if previewIfMissing {
            errors.append("missing original and preview for \(item.uuid)")
          } else {
            errors.append("missing original for \(item.uuid)")
          }
        }
      } else if skipOriginalIfEdited && item.edited {
        markSkipped()
      }

      if itemTraits.contains("live") && shouldCopyPrimary {
        if skipLive {
          markSkipped()
        } else if let livePath = item.livePhotoMoviePath,
          fileManager.fileExists(atPath: livePath)
        {
          do {
            let liveFilename = livePhotoMovieExportFilename(
              for: item,
              livePath: livePath,
              itemUUID: item.uuid,
              currentName: currentName,
              filenameTemplate: filenameTemplate,
              edited: false,
              editedSuffix: editedSuffix
            )
            if try exportResource(
              sourcePath: livePath,
              kind: "live_photo_movie",
              preferredFilename: liveFilename
            ) {
              didExportItem = true
            }
          } catch {
            markSkipped()
            errors.append("\(item.uuid) live photo movie: \(error)")
          }
        } else {
          markMissing()
          errors.append("missing live photo movie for \(item.uuid)")
        }
      }

      if item.edited && !skipEdited {
        if let editedPath = item.editedPath, fileManager.fileExists(atPath: editedPath) {
          do {
            let editedFilename = editedRenderExportFilename(
              for: item,
              editedPath: editedPath,
              itemUUID: item.uuid,
              currentName: currentName,
              filenameTemplate: filenameTemplate,
              editedSuffix: editedSuffix
            )
            if try exportResource(
              sourcePath: editedPath,
              kind: "edited_render",
              preferredFilename: editedFilename
            ) {
              didExportItem = true
            }
          } catch {
            markSkipped()
            errors.append("\(item.uuid) edited render: \(error)")
          }
        } else if skipOriginalIfEdited {
          markMissing()
          errors.append("missing edited render for \(item.uuid)")
        } else {
          markSkipped()
          errors.append("missing edited render for \(item.uuid)")
        }

        if itemTraits.contains("live") {
          if skipLive {
            markSkipped()
          } else if let editedLivePath = item.editedLivePhotoMoviePath,
            fileManager.fileExists(atPath: editedLivePath)
          {
            do {
              let editedLiveFilename = livePhotoMovieExportFilename(
                for: item,
                livePath: editedLivePath,
                itemUUID: item.uuid,
                currentName: currentName,
                filenameTemplate: filenameTemplate,
                edited: true,
                editedSuffix: editedSuffix
              )
              if try exportResource(
                sourcePath: editedLivePath,
                kind: "edited_live_photo_movie",
                preferredFilename: editedLiveFilename
              ) {
                didExportItem = true
              }
            } catch {
              markSkipped()
              errors.append("\(item.uuid) edited live photo movie: \(error)")
            }
          } else if item.editedPath != nil {
            markMissing()
            errors.append("missing edited live photo movie for \(item.uuid)")
          }
        }
      } else if item.edited && skipEdited {
        markSkipped()
      }

      if exportAAE, shouldCopyPrimary {
        if item.edited {
          if let adjustmentPath = item.adjustmentPath,
            fileManager.fileExists(atPath: adjustmentPath)
          {
            do {
              let aaeFilename = aaeExportFilename(
                for: item,
                itemUUID: item.uuid,
                currentName: currentName,
                filenameTemplate: filenameTemplate,
                original: false
              )
              if try exportResource(
                sourcePath: adjustmentPath,
                kind: "aae",
                preferredFilename: aaeFilename
              ) {
                didExportItem = true
              }
            } catch {
              markSkipped()
              errors.append("\(item.uuid) aae: \(error)")
            }
          } else {
            markMissing()
            errors.append("missing AAE for \(item.uuid)")
          }
        }
        if let originalAdjustmentPath = item.originalAdjustmentPath,
          fileManager.fileExists(atPath: originalAdjustmentPath)
        {
          do {
            let originalAAEFilename = aaeExportFilename(
              for: item,
              itemUUID: item.uuid,
              currentName: currentName,
              filenameTemplate: filenameTemplate,
              original: true
            )
            if try exportResource(
              sourcePath: originalAdjustmentPath,
              kind: "original_aae",
              preferredFilename: originalAAEFilename
            ) {
              didExportItem = true
            }
          } catch {
            markSkipped()
            errors.append("\(item.uuid) original aae: \(error)")
          }
        }
      }

      if exportPreview, !didExportPreview {
        if let previewSourcePath {
          do {
            let previewFilename = previewExportFilename(
              for: item,
              previewPath: previewSourcePath,
              itemUUID: item.uuid,
              filenameTemplate: filenameTemplate,
              previewSuffix: previewSuffix
            )
            if try exportResource(
              sourcePath: previewSourcePath,
              kind: "preview",
              preferredFilename: previewFilename
            ) {
              didExportItem = true
            }
          } catch {
            markSkipped()
            errors.append("\(item.uuid) preview: \(error)")
          }
        } else {
          markMissing()
          errors.append("missing preview for \(item.uuid)")
        }
      }

      if shouldCopyRaw {
        if let rawSourcePath, fileManager.fileExists(atPath: rawSourcePath) {
          do {
            if try exportResource(sourcePath: rawSourcePath, kind: "raw") {
              didExportItem = true
            }
          } catch {
            markSkipped()
            errors.append("\(item.uuid) raw: \(error)")
          }
        } else if item.traits.contains("raw") {
          markSkipped()
          errors.append("missing raw for \(item.uuid)")
        }
      }

      if didExportItem {
        exported += 1
      }
    }

    let runID = UUID().uuidString
    let reportURL = destinationURL.appendingPathComponent("photos-export-report.json")
    let metadataWrites = try writeExportExifMetadata(
      fields: metadataFields,
      resources: &resources,
      exiftoolPath: metadataExiftoolPath,
      timeoutSeconds: metadataTimeoutSeconds,
      outputCap: metadataOutputCap
    )
    let fileMetadataWrites = try writeExportFileMetadata(
      finderTagTemplates: metadataFinderTagTemplates,
      xattrTemplates: metadataXattrTemplates,
      items: items,
      resources: &resources
    )
    let cleanupSummary = try exportCleanupSummary(
      destinationURL: destinationURL,
      reportURL: reportURL,
      stateURL: stateURL,
      keepRules: cleanupKeepRules,
      cleanupCommands: cleanupCommands,
      cleanupCommandError: cleanupCommandError,
      cleanupEnabled: cleanupEnabled,
      onlyNew: onlyNew,
      priorResources: Array(priorResources.values),
      currentResources: resources,
      timeoutSeconds: cleanupTimeoutSeconds,
      outputCap: cleanupOutputCap
    )
    let report = PhotosExportReport(
      runID: runID,
      exported: exported,
      skipped: skipped,
      missing: missing,
      errors: errors,
      exportedUUIDs: photosUniqueStable(exportedUUIDs),
      skippedUUIDs: photosUniqueStable(skippedUUIDs),
      missingUUIDs: photosUniqueStable(missingUUIDs),
      resources: resources,
      cleanup: cleanupSummary,
      metadataWrites: metadataWrites.isEmpty ? nil : metadataWrites,
      fileMetadataWrites: fileMetadataWrites.isEmpty ? nil : fileMetadataWrites
    )
    try writeJSON(report, to: reportURL)
    if let stateDB = plan.options["state_db"], !stateDB.isEmpty {
      try appendExportReport(report, to: URL(fileURLWithPath: stateDB))
    }

    return PhotosExportResult(
      exported: exported,
      skipped: skipped,
      missing: missing,
      destination: plan.destination,
      reportPath: reportURL.path,
      exportedUUIDs: photosUniqueStable(exportedUUIDs),
      skippedUUIDs: photosUniqueStable(skippedUUIDs),
      missingUUIDs: photosUniqueStable(missingUUIDs),
      cleanup: cleanupSummary,
      metadataWrites: metadataWrites.isEmpty ? nil : metadataWrites,
      fileMetadataWrites: fileMetadataWrites.isEmpty ? nil : fileMetadataWrites
    )
  }

  public func exportReport(stateDB: String?, runID: String?) throws -> PhotosExportReport {
    guard let stateDB, !stateDB.isEmpty else {
      return PhotosExportReport(runID: runID ?? "latest", exported: 0)
    }
    let url = URL(fileURLWithPath: stateDB)
    guard fileManager.fileExists(atPath: url.path) else {
      throw CLIError(code: .notFound, message: "Photos export state DB was not found.")
    }
    let data = try Data(contentsOf: url)
    if let state = try? JSONDecoder().decode(PhotosExportStateDatabase.self, from: data) {
      guard let report = state.report(runID: runID) else {
        throw CLIError(
          code: .notFound,
          message: "Photos export run was not found.",
          details: ["run_id": runID ?? "latest"]
        )
      }
      return report
    }

    let legacyReport = try JSONDecoder().decode(PhotosExportReport.self, from: data)
    if let runID, legacyReport.runID != runID {
      throw CLIError(
        code: .notFound,
        message: "Photos export run was not found.",
        details: ["run_id": runID]
      )
    }
    return legacyReport
  }

  public func writeSidecar(
    format: String,
    items: [PhotosMediaItemRecord],
    query: PhotosQuery,
    destination: String,
    template: String?
  ) throws -> Bool {
    let normalizedFormat = format.lowercased()
    guard ["json", "xmp", "template"].contains(normalizedFormat) else {
      throw CLIError(
        code: .validationError,
        message: "Photos sidecar format must be `json`, `xmp`, or `template`."
      )
    }
    if normalizedFormat == "template", template == nil {
      throw CLIError(
        code: .validationError,
        message: "Photos template sidecars require `--template`."
      )
    }

    let destinationURL = URL(fileURLWithPath: destination)
    try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)

    if items.isEmpty {
      let manifest = destinationURL.appendingPathComponent("photos-sidecar-plan.json")
      let payload = CLISuccessEnvelope(data: query, meta: ["format": normalizedFormat])
      try CLIJSON.encodeString(payload, pretty: true).write(
        to: manifest, atomically: true, encoding: .utf8)
      return true
    }

    for item in items {
      let base = URL(fileURLWithPath: item.filename).deletingPathExtension().lastPathComponent
      let fileExtension = normalizedFormat == "template" ? "txt" : normalizedFormat
      let sidecar = destinationURL.appendingPathComponent("\(base).\(fileExtension)")
      let renderedTemplate = template.map { photosRenderTemplate($0, item: item) }
      switch normalizedFormat {
      case "json":
        if let renderedTemplate {
          try writeJSON(
            PhotosJSONSidecar(item: item, renderedTemplate: renderedTemplate),
            to: sidecar
          )
        } else {
          try writeJSON(item, to: sidecar)
        }
      case "xmp":
        try xmpSidecar(for: item, renderedTemplate: renderedTemplate).write(
          to: sidecar,
          atomically: true,
          encoding: .utf8
        )
      case "template":
        try (renderedTemplate ?? "").write(to: sidecar, atomically: true, encoding: .utf8)
      default:
        break
      }
    }
    return true
  }

  public func writeExifPlan(
    fields: [String],
    items: [PhotosMediaItemRecord],
    query: PhotosQuery,
    destination: String?,
    exiftoolPath: String?,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> Bool {
    if let destination, !destination.isEmpty {
      let destinationURL = URL(fileURLWithPath: destination)
      try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)
      let plan = PhotosExifPlan(fields: fields, query: query, items: items)
      try writeJSON(plan, to: destinationURL.appendingPathComponent("photos-exif-plan.json"))
      return true
    }

    let paths = try externalExifWritablePaths(items: items, query: query)
    _ = try runExiftool(
      fields: fields,
      paths: paths,
      explicitPath: exiftoolPath,
      timeoutSeconds: timeoutSeconds,
      outputCap: outputCap
    )
    return true
  }

  public func requireExiftool() throws -> Bool {
    _ = try resolvedExiftoolPath(nil)
    return true
  }

  private func resolvedExiftoolPath(_ explicitPath: String?) throws -> String {
    if let explicitPath, !explicitPath.isEmpty {
      guard fileManager.isExecutableFile(atPath: explicitPath) else {
        throw CLIError(
          code: .backendUnavailable,
          message: "exiftool is not installed or not executable.",
          details: ["tool": explicitPath]
        )
      }
      return explicitPath
    }

    let candidates = [
      ProcessInfo.processInfo.environment["APPLE_PHOTOS_EXIFTOOL"],
      "/opt/homebrew/bin/exiftool",
      "/usr/local/bin/exiftool",
      "/usr/bin/exiftool",
    ].compactMap { $0 }.filter { !$0.isEmpty }
    guard let path = candidates.first(where: { fileManager.isExecutableFile(atPath: $0) }) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "exiftool is not installed or not executable.",
        details: ["tool": "exiftool"]
      )
    }
    return path
  }

  private func runExiftool(
    fields: [String],
    paths: [String],
    explicitPath: String?,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> [PhotosExifWriteRecord] {
    guard !fields.isEmpty else {
      return []
    }
    guard !paths.isEmpty else {
      throw CLIError(
        code: .notFound,
        message: "No writable Photos EXIF metadata targets were found."
      )
    }
    let toolPath = try resolvedExiftoolPath(explicitPath)
    let fieldArguments = fields.map { field in
      field.hasPrefix("-") ? field : "-\(field)"
    }
    var records: [PhotosExifWriteRecord] = []
    for path in paths {
      let result = try CLISubprocess.run(
        .path(toolPath),
        arguments: fieldArguments + ["-overwrite_original", path],
        timeoutSeconds: timeoutSeconds,
        outputLimit: outputCap
      )
      guard result.exitCode == 0 else {
        throw CLIError(
          code: .backendUnavailable,
          message: "exiftool metadata write failed.",
          details: [
            "path": path,
            "status": "\(result.exitCode)",
            "stderr": result.stderr.trimmingCharacters(in: .whitespacesAndNewlines),
          ]
        )
      }
      records.append(PhotosExifWriteRecord(path: path, fields: fields, exitCode: result.exitCode))
    }
    return records
  }

  private func externalExifWritablePaths(
    items: [PhotosMediaItemRecord],
    query: PhotosQuery
  ) throws -> [String] {
    let libraryPath = query.libraryPath.map { URL(fileURLWithPath: $0).standardizedFileURL.path }
    var paths: [String] = []
    for item in items {
      guard let originalPath = item.originalPath, fileManager.fileExists(atPath: originalPath)
      else {
        throw CLIError(
          code: .notFound,
          message: "Photos item has no writable original file for EXIF metadata.",
          details: ["uuid": item.uuid]
        )
      }
      let path = URL(fileURLWithPath: originalPath).standardizedFileURL.path
      if let libraryPath, path == libraryPath || path.hasPrefix("\(libraryPath)/") {
        throw CLIError(
          code: .unsafeMutationRefused,
          message: "Refusing to write EXIF metadata inside a .photoslibrary package.",
          details: ["uuid": item.uuid, "path": path]
        )
      }
      paths.append(path)
    }
    return paths
  }

  private func writeExportExifMetadata(
    fields: [String],
    resources: inout [PhotosExportResourceRecord],
    exiftoolPath: String?,
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> [PhotosExifWriteRecord] {
    guard !fields.isEmpty else {
      return []
    }
    let writableKinds = exportMetadataWritableKinds()
    var records: [PhotosExifWriteRecord] = []
    for index in resources.indices where writableKinds.contains(resources[index].kind) {
      let path = resources[index].path
      guard fileManager.fileExists(atPath: path) else {
        continue
      }
      records += try runExiftool(
        fields: fields,
        paths: [path],
        explicitPath: exiftoolPath,
        timeoutSeconds: timeoutSeconds,
        outputCap: outputCap
      )
      resources[index].destinationSignature = try exportFileSignature(path: path)
    }
    if records.isEmpty {
      throw CLIError(
        code: .notFound,
        message: "No exported resources were writable by exiftool."
      )
    }
    return records
  }

  private func writeExportFileMetadata(
    finderTagTemplates: [String],
    xattrTemplates: [PhotosXattrTemplate],
    items: [PhotosMediaItemRecord],
    resources: inout [PhotosExportResourceRecord]
  ) throws -> [PhotosFileMetadataWriteRecord] {
    guard !finderTagTemplates.isEmpty || !xattrTemplates.isEmpty else {
      return []
    }
    let writableKinds = exportMetadataWritableKinds()
    let itemsByUUID = Dictionary(uniqueKeysWithValues: items.map { ($0.uuid, $0) })
    var records: [PhotosFileMetadataWriteRecord] = []
    for index in resources.indices where writableKinds.contains(resources[index].kind) {
      let resource = resources[index]
      guard fileManager.fileExists(atPath: resource.path),
        let item = itemsByUUID[resource.uuid]
      else {
        continue
      }

      let finderTags = exportFinderTags(
        from: finderTagTemplates,
        item: item,
        resource: resource
      )
      if !finderTags.isEmpty {
        try setExportFinderTags(finderTags, path: resource.path)
      }

      var xattrNames: [String] = []
      for template in xattrTemplates {
        let rendered = photosRenderTemplate(
          template.template,
          item: item,
          resourcePath: resource.path,
          resourceKind: resource.kind
        )
        let value = rendered.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else {
          continue
        }
        try setExportXattr(name: template.name, value: value, path: resource.path)
        xattrNames.append(template.name)
      }

      guard !finderTags.isEmpty || !xattrNames.isEmpty else {
        continue
      }
      resources[index].destinationSignature = try exportFileSignature(path: resource.path)
      records.append(
        PhotosFileMetadataWriteRecord(
          path: resource.path,
          resourceKind: resource.kind,
          finderTags: finderTags,
          xattrs: xattrNames
        )
      )
    }
    if records.isEmpty {
      throw CLIError(
        code: .notFound,
        message: "No exported resources were writable for file metadata."
      )
    }
    return records
  }

  private func exportMetadataWritableKinds() -> Set<String> {
    [
      "original",
      "raw",
      "preview",
      "edited_render",
      "live_photo_movie",
      "edited_live_photo_movie",
      "converted_jpeg",
    ]
  }

  private func exportFinderTags(
    from templates: [String],
    item: PhotosMediaItemRecord,
    resource: PhotosExportResourceRecord
  ) -> [String] {
    var tags: [String] = []
    var seen: Set<String> = []
    for template in templates {
      let rendered = photosRenderTemplate(
        template,
        item: item,
        resourcePath: resource.path,
        resourceKind: resource.kind
      )
      for tag in rendered.split(whereSeparator: { $0 == "," || $0 == "\n" }) {
        let value = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, seen.insert(value).inserted else {
          continue
        }
        tags.append(value)
      }
    }
    return tags
  }

  private func setExportFinderTags(_ tags: [String], path: String) throws {
    let values = tags.map { "\($0)\n0" }
    let data = try PropertyListSerialization.data(
      fromPropertyList: values, format: .binary, options: 0)
    try setExportXattrData(
      name: "com.apple.metadata:_kMDItemUserTags",
      data: data,
      path: path,
      failureMessage: "Failed to set Finder tags on exported Photos resource."
    )
  }

  private func setExportXattr(name: String, value: String, path: String) throws {
    let data = Data(value.utf8)
    try setExportXattrData(
      name: name,
      data: data,
      path: path,
      failureMessage: "Failed to set xattr on exported Photos resource."
    )
  }

  private func setExportXattrData(
    name: String,
    data: Data,
    path: String,
    failureMessage: String
  ) throws {
    let status = data.withUnsafeBytes { bytes in
      setxattr(path, name, bytes.baseAddress, data.count, 0, 0)
    }
    if status == -1 {
      throw CLIError(
        code: .backendUnavailable,
        message: failureMessage,
        details: ["path": path, "attribute": name, "errno": "\(errno)"]
      )
    }
  }

  private func uniqueDestination(in directory: URL, preferredName: String) -> URL {
    let proposed = directory.appendingPathComponent(preferredName)
    guard fileManager.fileExists(atPath: proposed.path) else {
      return proposed
    }

    let stem = proposed.deletingPathExtension().lastPathComponent
    let ext = proposed.pathExtension
    var counter = 2
    while true {
      let name = ext.isEmpty ? "\(stem)-\(counter)" : "\(stem)-\(counter).\(ext)"
      let candidate = directory.appendingPathComponent(name)
      if !fileManager.fileExists(atPath: candidate.path) {
        return candidate
      }
      counter += 1
    }
  }

  private func copyExportFile(
    sourcePath: String,
    item: PhotosMediaItemRecord,
    itemUUID: String,
    kind: String,
    filenameTemplate: String?,
    directoryTemplate: String?,
    currentName: Bool,
    touchFile: Bool,
    to directory: URL,
    destinationOverride: URL? = nil,
    replaceExisting: Bool = false,
    preferredNameOverride: String? = nil
  ) throws -> URL {
    let sourceURL = URL(fileURLWithPath: sourcePath)
    let destination: URL
    if let destinationOverride {
      try fileManager.createDirectory(
        at: destinationOverride.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      destination = destinationOverride
    } else {
      let destinationDirectory = try exportDirectory(
        for: item,
        sourcePath: sourcePath,
        kind: kind,
        template: directoryTemplate,
        root: directory
      )
      let preferredName =
        preferredNameOverride
        ?? preferredExportFilename(
          for: item,
          sourceURL: sourceURL,
          itemUUID: itemUUID,
          kind: kind,
          currentName: currentName,
          template: filenameTemplate
        )
      if replaceExisting {
        destination = destinationDirectory.appendingPathComponent(preferredName)
      } else {
        destination = uniqueDestination(in: destinationDirectory, preferredName: preferredName)
      }
    }

    if replaceExisting, fileManager.fileExists(atPath: destination.path) {
      if sourceURL.standardizedFileURL.path == destination.standardizedFileURL.path {
        throw CLIError(
          code: .validationError,
          message: "Photos export overwrite destination cannot be the source file."
        )
      }
      try fileManager.removeItem(at: destination)
    }
    try fileManager.copyItem(at: sourceURL, to: destination)
    if touchFile, let date = item.date {
      try fileManager.setAttributes([.modificationDate: date], ofItemAtPath: destination.path)
    }
    return destination
  }

  private func exportDirectory(
    for item: PhotosMediaItemRecord,
    sourcePath: String,
    kind: String,
    template: String?,
    root: URL
  ) throws -> URL {
    guard let template else {
      return root
    }
    let rendered = photosRenderTemplate(
      template,
      item: item,
      resourcePath: sourcePath,
      resourceKind: kind
    )
    let components = photosSanitizedRelativeDirectory(rendered)
    let destination = components.reduce(root) { partial, component in
      partial.appendingPathComponent(component, isDirectory: true)
    }
    try fileManager.createDirectory(at: destination, withIntermediateDirectories: true)
    return destination
  }

  private func preferredExportFilename(
    for item: PhotosMediaItemRecord,
    sourceURL: URL,
    itemUUID: String,
    kind: String,
    currentName: Bool,
    template: String?
  ) -> String {
    let fallback = preferredExportFallbackFilename(
      item: item,
      sourceURL: sourceURL,
      itemUUID: itemUUID,
      kind: kind,
      currentName: currentName
    )
    guard let template else {
      return fallback
    }
    var rendered = photosSanitizedFilename(
      photosRenderTemplate(
        template,
        item: item,
        resourcePath: sourceURL.path,
        resourceKind: kind
      ),
      fallback: fallback
    )
    let sourceExtension = sourceURL.pathExtension
    if !sourceExtension.isEmpty, URL(fileURLWithPath: rendered).pathExtension.isEmpty {
      rendered += ".\(sourceExtension)"
    }
    return rendered
  }

  private func preferredExportFallbackFilename(
    item: PhotosMediaItemRecord,
    sourceURL: URL,
    itemUUID: String,
    kind: String,
    currentName: Bool
  ) -> String {
    let sourceFilename = sourceURL.lastPathComponent
    guard currentName, !item.filename.isEmpty else {
      return sourceFilename.isEmpty ? "\(itemUUID)-\(kind)" : sourceFilename
    }

    if kind == "original" {
      return item.filename
    }

    let currentStem = URL(fileURLWithPath: item.filename).deletingPathExtension().lastPathComponent
    let sourceExtension = sourceURL.pathExtension
    guard !currentStem.isEmpty, !sourceExtension.isEmpty else {
      return sourceFilename.isEmpty ? "\(itemUUID)-\(kind)" : sourceFilename
    }
    return "\(currentStem).\(sourceExtension)"
  }

  private func previewExportFilename(
    for item: PhotosMediaItemRecord,
    previewPath: String,
    itemUUID: String,
    filenameTemplate: String?,
    previewSuffix: String
  ) -> String {
    let previewURL = URL(fileURLWithPath: previewPath)
    let previewExtension = previewURL.pathExtension
    let fallbackBase =
      item.filename.isEmpty
      ? itemUUID
      : item.filename
    let rendered =
      filenameTemplate.map {
        photosRenderTemplate(
          $0,
          item: item,
          resourcePath: previewPath,
          resourceKind: "preview"
        )
      } ?? fallbackBase
    let sanitized = photosSanitizedFilename(rendered, fallback: fallbackBase)
    let stem = URL(fileURLWithPath: sanitized).deletingPathExtension().lastPathComponent
    let outputStem = stem.isEmpty ? itemUUID : stem
    guard !previewExtension.isEmpty else {
      return "\(outputStem)\(previewSuffix)"
    }
    return "\(outputStem)\(previewSuffix).\(previewExtension)"
  }

  private func aaeExportFilename(
    for item: PhotosMediaItemRecord,
    itemUUID: String,
    currentName: Bool,
    filenameTemplate: String?,
    original: Bool
  ) -> String {
    let sourceURL = URL(fileURLWithPath: item.originalPath ?? item.filename)
    let base = preferredExportFilename(
      for: item,
      sourceURL: sourceURL,
      itemUUID: itemUUID,
      kind: "original",
      currentName: currentName,
      template: filenameTemplate
    )
    let stem = URL(fileURLWithPath: base).deletingPathExtension().lastPathComponent
    let outputStem = stem.isEmpty ? itemUUID : stem
    return original ? "\(outputStem)_O.AAE" : "\(outputStem).AAE"
  }

  private func editedRenderExportFilename(
    for item: PhotosMediaItemRecord,
    editedPath: String,
    itemUUID: String,
    currentName: Bool,
    filenameTemplate: String?,
    editedSuffix: String
  ) -> String {
    let editedURL = URL(fileURLWithPath: editedPath)
    let fallbackBase =
      currentName && !item.filename.isEmpty
      ? item.filename
      : (item.filename.isEmpty ? itemUUID : item.filename)
    let rendered =
      filenameTemplate.map {
        photosRenderTemplate(
          $0,
          item: item,
          resourcePath: editedPath,
          resourceKind: "edited_render"
        )
      } ?? fallbackBase
    let sanitized = photosSanitizedFilename(rendered, fallback: fallbackBase)
    let stem = URL(fileURLWithPath: sanitized).deletingPathExtension().lastPathComponent
    let outputStem = stem.isEmpty ? itemUUID : stem
    let editedExtension = editedURL.pathExtension
    guard !editedExtension.isEmpty else {
      return "\(outputStem)\(editedSuffix)"
    }
    return "\(outputStem)\(editedSuffix).\(editedExtension)"
  }

  private func livePhotoMovieExportFilename(
    for item: PhotosMediaItemRecord,
    livePath: String,
    itemUUID: String,
    currentName: Bool,
    filenameTemplate: String?,
    edited: Bool,
    editedSuffix: String
  ) -> String {
    let resourceKind = edited ? "edited_live_photo_movie" : "live_photo_movie"
    let basePath =
      edited
      ? (item.editedPath ?? item.originalPath ?? item.filename)
      : (item.originalPath ?? item.filename)
    let rendered: String
    if let filenameTemplate {
      rendered = photosRenderTemplate(
        filenameTemplate,
        item: item,
        resourcePath: livePath,
        resourceKind: resourceKind
      )
    } else if edited, let editedPath = item.editedPath {
      rendered = editedRenderExportFilename(
        for: item,
        editedPath: editedPath,
        itemUUID: itemUUID,
        currentName: currentName,
        filenameTemplate: nil,
        editedSuffix: editedSuffix
      )
    } else {
      rendered = preferredExportFilename(
        for: item,
        sourceURL: URL(fileURLWithPath: basePath),
        itemUUID: itemUUID,
        kind: "original",
        currentName: currentName,
        template: nil
      )
    }
    let fallback = item.filename.isEmpty ? itemUUID : item.filename
    let sanitized = photosSanitizedFilename(rendered, fallback: fallback)
    let stem = URL(fileURLWithPath: sanitized).deletingPathExtension().lastPathComponent
    let outputStem = stem.isEmpty ? itemUUID : stem
    let liveExtension = URL(fileURLWithPath: livePath).pathExtension
    guard !liveExtension.isEmpty else {
      return "\(outputStem).mov"
    }
    return "\(outputStem).\(liveExtension)"
  }

  private func shouldConvertPrimaryToJPEG(sourcePath: String, item: PhotosMediaItemRecord) -> Bool {
    if item.mediaType != "image" {
      return false
    }
    if item.uti == "public.jpeg" || item.originalUTI == "public.jpeg" {
      return false
    }
    let sourceExtension = URL(fileURLWithPath: sourcePath).pathExtension.lowercased()
    return !["jpg", "jpeg"].contains(sourceExtension)
  }

  private func temporaryJPEGExport(
    item: PhotosMediaItemRecord,
    itemUUID: String,
    sourcePath: String,
    currentName: Bool,
    filenameTemplate: String?,
    jpegExtension: String,
    jpegQuality: Double,
    fixOrientation: Bool
  ) throws -> (
    path: String, preferredFilename: String, sourceSignature: String, temporaryDirectory: URL
  ) {
    let temporaryDirectory = fileManager.temporaryDirectory.appendingPathComponent(
      "apple-cli-photos-transform-\(UUID().uuidString)",
      isDirectory: true
    )
    try fileManager.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
    let preferredFilename = convertedJPEGExportFilename(
      for: item,
      sourcePath: sourcePath,
      itemUUID: itemUUID,
      currentName: currentName,
      filenameTemplate: filenameTemplate,
      jpegExtension: jpegExtension
    )
    let convertedURL = temporaryDirectory.appendingPathComponent(preferredFilename)
    try convertImageToJPEG(
      sourcePath: sourcePath,
      destination: convertedURL,
      quality: jpegQuality,
      fixOrientation: fixOrientation
    )
    let originalSignature = try exportFileSignature(path: sourcePath)
    let sourceSignature = photosSHA256Hex(
      [
        "transform=jpeg",
        "source=\(originalSignature)",
        "quality=\(jpegQuality)",
        "extension=\(jpegExtension)",
        "fix_orientation=\(fixOrientation)",
      ].joined(separator: "\n")
    )
    return (convertedURL.path, preferredFilename, sourceSignature, temporaryDirectory)
  }

  private func convertedJPEGExportFilename(
    for item: PhotosMediaItemRecord,
    sourcePath: String,
    itemUUID: String,
    currentName: Bool,
    filenameTemplate: String?,
    jpegExtension: String
  ) -> String {
    let sourceURL = URL(fileURLWithPath: sourcePath)
    let base = preferredExportFilename(
      for: item,
      sourceURL: sourceURL,
      itemUUID: itemUUID,
      kind: "original",
      currentName: currentName,
      template: filenameTemplate
    )
    let stem = URL(fileURLWithPath: base).deletingPathExtension().lastPathComponent
    let outputStem = stem.isEmpty ? itemUUID : stem
    return "\(outputStem).\(jpegExtension)"
  }

  private func convertImageToJPEG(
    sourcePath: String,
    destination: URL,
    quality: Double,
    fixOrientation: Bool
  ) throws {
    let sourceURL = URL(fileURLWithPath: sourcePath)
    guard let imageSource = CGImageSourceCreateWithURL(sourceURL as CFURL, nil) else {
      throw CLIError(
        code: .validationError,
        message: "Photos export image conversion failed.",
        details: ["source": sourcePath, "reason": "unsupported image source"]
      )
    }

    let image: CGImage?
    if fixOrientation {
      let properties =
        CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any]
      let width = properties?[kCGImagePropertyPixelWidth] as? Int ?? 1
      let height = properties?[kCGImagePropertyPixelHeight] as? Int ?? 1
      let maxPixelSize = max(width, height, 1)
      let options: [CFString: Any] = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
      ]
      image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
    } else {
      image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    }

    guard let image else {
      throw CLIError(
        code: .validationError,
        message: "Photos export image conversion failed.",
        details: ["source": sourcePath, "reason": "unsupported image frame"]
      )
    }
    guard
      let destinationImage = CGImageDestinationCreateWithURL(
        destination as CFURL,
        UTType.jpeg.identifier as CFString,
        1,
        nil
      )
    else {
      throw CLIError(
        code: .internalError,
        message: "Photos export image conversion could not create a JPEG destination."
      )
    }
    let properties: [CFString: Any] = [
      kCGImageDestinationLossyCompressionQuality: quality
    ]
    CGImageDestinationAddImage(destinationImage, image, properties as CFDictionary)
    guard CGImageDestinationFinalize(destinationImage) else {
      throw CLIError(
        code: .internalError,
        message: "Photos export image conversion failed to write JPEG output."
      )
    }
  }

  private func exportCleanupSummary(
    destinationURL: URL,
    reportURL: URL,
    stateURL: URL?,
    keepRules: [String],
    cleanupCommands: [String],
    cleanupCommandError: String,
    cleanupEnabled: Bool,
    onlyNew: Bool,
    priorResources: [PhotosExportResourceRecord],
    currentResources: [PhotosExportResourceRecord],
    timeoutSeconds: Int,
    outputCap: Int
  ) throws -> PhotosExportCleanupSummary? {
    guard cleanupEnabled || !cleanupCommands.isEmpty else {
      return nil
    }

    let root = destinationURL.standardizedFileURL
    let loadedKeepRules = try exportCleanupKeepRules(destinationURL: root, commandRules: keepRules)
    var protectedPaths = Set<String>()
    func protect(_ url: URL) {
      protectedPaths.insert(exportCleanupNormalizedPath(url))
    }

    protect(reportURL)
    protect(root.appendingPathComponent(Self.exportKeepFileName))
    if let stateURL {
      protect(stateURL)
    }
    for resource in currentResources {
      protect(URL(fileURLWithPath: resource.path))
    }
    if onlyNew {
      for resource in priorResources {
        protect(URL(fileURLWithPath: resource.path))
      }
    }

    let candidates = try exportCleanupCandidateFiles(
      destinationURL: root,
      protectedPaths: protectedPaths,
      keepRules: loadedKeepRules
    )
    var commandRuns: [PhotosExportCleanupCommandRun] = []
    for candidate in candidates {
      commandLoop: for rawCommand in cleanupCommands {
        let rendered = exportCleanupCommand(rawCommand, filepath: candidate.path)
        let result = try CLISubprocess.run(
          .path("/bin/zsh"),
          arguments: ["-lc", rendered],
          timeoutSeconds: timeoutSeconds,
          outputLimit: outputCap
        )
        commandRuns.append(
          PhotosExportCleanupCommandRun(
            path: candidate.path,
            command: rendered,
            exitCode: result.exitCode
          ))
        guard result.exitCode == 0 else {
          switch cleanupCommandError {
          case "continue":
            continue
          case "break":
            break commandLoop
          default:
            throw CLIError(
              code: .backendUnavailable,
              message: "Photos export cleanup command failed.",
              details: [
                "path": candidate.path,
                "status": "\(result.exitCode)",
                "stderr": result.stderr.trimmingCharacters(in: .whitespacesAndNewlines),
              ]
            )
          }
        }
      }
    }

    var deletedFiles: [String] = []
    var deletedDirectories: [String] = []
    if cleanupEnabled {
      for candidate in candidates {
        if fileManager.fileExists(atPath: candidate.path) {
          try fileManager.removeItem(at: candidate)
          deletedFiles.append(candidate.path)
        }
      }
      deletedDirectories = try exportCleanupEmptyDirectories(
        destinationURL: root,
        protectedPaths: protectedPaths,
        keepRules: loadedKeepRules
      )
    }

    return PhotosExportCleanupSummary(
      deletedFiles: deletedFiles.sorted(),
      deletedDirectories: deletedDirectories.sorted(),
      commandRuns: commandRuns
    )
  }

  private func exportCleanupKeepRules(destinationURL: URL, commandRules: [String]) throws
    -> [String]
  {
    let keepFile = destinationURL.appendingPathComponent(Self.exportKeepFileName)
    var rules: [String] = []
    if fileManager.fileExists(atPath: keepFile.path) {
      let contents = try String(contentsOf: keepFile, encoding: .utf8)
      rules.append(contentsOf: exportLinesOption(contents))
    }
    rules.append(contentsOf: commandRules)
    return rules.compactMap { rule in
      let trimmed = rule.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else {
        return nil
      }
      return trimmed
    }
  }

  private func exportCleanupCandidateFiles(
    destinationURL: URL,
    protectedPaths: Set<String>,
    keepRules: [String]
  ) throws -> [URL] {
    guard
      let enumerator = fileManager.enumerator(
        at: destinationURL,
        includingPropertiesForKeys: [.isDirectoryKey],
        options: [.skipsPackageDescendants]
      )
    else {
      return []
    }

    var candidates: [URL] = []
    for case let url as URL in enumerator {
      let values = try url.resourceValues(forKeys: [.isDirectoryKey])
      if values.isDirectory == true {
        if url.lastPathComponent.hasPrefix(".") {
          enumerator.skipDescendants()
        }
        continue
      }
      guard !url.lastPathComponent.hasPrefix(".") else {
        continue
      }
      let normalizedPath = exportCleanupNormalizedPath(url)
      guard !protectedPaths.contains(normalizedPath) else {
        continue
      }
      guard !exportCleanupMatchesKeepRule(url, root: destinationURL, keepRules: keepRules) else {
        continue
      }
      candidates.append(url)
    }
    return candidates.sorted { $0.path < $1.path }
  }

  private func exportCleanupEmptyDirectories(
    destinationURL: URL,
    protectedPaths: Set<String>,
    keepRules: [String]
  ) throws -> [String] {
    guard
      let enumerator = fileManager.enumerator(
        at: destinationURL,
        includingPropertiesForKeys: [.isDirectoryKey],
        options: [.skipsPackageDescendants]
      )
    else {
      return []
    }

    var directories: [URL] = []
    for case let url as URL in enumerator {
      let values = try url.resourceValues(forKeys: [.isDirectoryKey])
      guard values.isDirectory == true else {
        continue
      }
      if url.lastPathComponent.hasPrefix(".") {
        enumerator.skipDescendants()
        continue
      }
      directories.append(url)
    }

    var deleted: [String] = []
    for directory in directories.sorted(by: { $0.path.count > $1.path.count }) {
      guard exportCleanupNormalizedPath(directory) != exportCleanupNormalizedPath(destinationURL)
      else {
        continue
      }
      guard !protectedPaths.contains(exportCleanupNormalizedPath(directory)) else {
        continue
      }
      guard !exportCleanupMatchesKeepRule(directory, root: destinationURL, keepRules: keepRules)
      else {
        continue
      }
      let contents = try fileManager.contentsOfDirectory(atPath: directory.path)
      guard contents.isEmpty else {
        continue
      }
      try fileManager.removeItem(at: directory)
      deleted.append(directory.path)
    }
    return deleted
  }

  private func exportCleanupMatchesKeepRule(_ url: URL, root: URL, keepRules: [String]) -> Bool {
    var keep = false
    for rawRule in keepRules {
      var rule = rawRule.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !rule.isEmpty, !rule.hasPrefix("#") else {
        continue
      }
      let negated = rule.hasPrefix("!")
      if negated {
        rule.removeFirst()
      }
      guard !rule.isEmpty else {
        continue
      }
      if exportCleanupRule(rule, matches: url, root: root) {
        keep = !negated
      }
    }
    return keep
  }

  private func exportCleanupRule(_ rule: String, matches url: URL, root: URL) -> Bool {
    let absolutePath = exportCleanupNormalizedPath(url)
    let relativePath = exportCleanupRelativePath(url, root: root)
    let basename = url.lastPathComponent
    let normalizedRule = rule.replacingOccurrences(of: "\\", with: "/")
    let directoryRule = normalizedRule.hasSuffix("/")
    let trimmedDirectoryRule =
      directoryRule ? String(normalizedRule.dropLast()) : normalizedRule

    if normalizedRule.hasPrefix("/") {
      let absoluteRulePath = exportCleanupNormalizedPath(URL(fileURLWithPath: normalizedRule))
      if absolutePath == absoluteRulePath || absolutePath.hasPrefix("\(absoluteRulePath)/") {
        return true
      }
      let anchored = String(trimmedDirectoryRule.drop(while: { $0 == "/" }))
      if directoryRule {
        return relativePath == anchored || relativePath.hasPrefix("\(anchored)/")
      }
      return exportCleanupGlob(
        trimmedDirectoryRule.hasPrefix("/") ? anchored : trimmedDirectoryRule,
        matches: relativePath)
    }

    if directoryRule {
      return relativePath == trimmedDirectoryRule
        || relativePath.hasPrefix("\(trimmedDirectoryRule)/")
    }
    if trimmedDirectoryRule.contains("/") {
      return exportCleanupGlob(trimmedDirectoryRule, matches: relativePath)
    }
    return exportCleanupGlob(trimmedDirectoryRule, matches: basename)
      || exportCleanupGlob("**/\(trimmedDirectoryRule)", matches: relativePath)
  }

  private func exportCleanupGlob(_ pattern: String, matches value: String) -> Bool {
    let regex = "^\(exportCleanupGlobRegex(pattern))$"
    return value.range(of: regex, options: [.regularExpression]) != nil
  }

  private func exportCleanupGlobRegex(_ pattern: String) -> String {
    var regex = ""
    var index = pattern.startIndex
    while index < pattern.endIndex {
      let character = pattern[index]
      if character == "*" {
        let next = pattern.index(after: index)
        if next < pattern.endIndex, pattern[next] == "*" {
          let afterDoubleStar = pattern.index(after: next)
          if afterDoubleStar < pattern.endIndex, pattern[afterDoubleStar] == "/" {
            regex += "(?:.*/)?"
            index = pattern.index(after: afterDoubleStar)
          } else {
            regex += ".*"
            index = afterDoubleStar
          }
        } else {
          regex += "[^/]*"
          index = next
        }
      } else if character == "?" {
        regex += "[^/]"
        index = pattern.index(after: index)
      } else {
        regex += NSRegularExpression.escapedPattern(for: String(character))
        index = pattern.index(after: index)
      }
    }
    return regex
  }

  private func exportCleanupCommand(_ command: String, filepath: String) -> String {
    command
      .replacingOccurrences(of: "{filepath|shell_quote}", with: exportCleanupShellQuote(filepath))
      .replacingOccurrences(of: "{filepath}", with: filepath)
  }

  private func exportCleanupShellQuote(_ value: String) -> String {
    "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
  }

  private func exportCleanupNormalizedPath(_ url: URL) -> String {
    let standardized = url.standardizedFileURL
    if let resolved = exportCleanupRealPath(standardized) {
      return resolved
    }
    let parent = standardized.deletingLastPathComponent()
    if let resolvedParent = exportCleanupRealPath(parent) {
      return URL(fileURLWithPath: resolvedParent)
        .appendingPathComponent(standardized.lastPathComponent)
        .path
    }
    return standardized.path
  }

  private func exportCleanupRealPath(_ url: URL) -> String? {
    url.withUnsafeFileSystemRepresentation { representation in
      guard let representation, let resolved = realpath(representation, nil) else {
        return nil
      }
      defer { free(resolved) }
      return String(cString: resolved)
    }
  }

  private func exportCleanupRelativePath(_ url: URL, root: URL) -> String {
    let path = exportCleanupNormalizedPath(url)
    let rootPath = exportCleanupNormalizedPath(root)
    if path == rootPath {
      return ""
    }
    let prefix = "\(rootPath)/"
    guard path.hasPrefix(prefix) else {
      return path
    }
    return String(path.dropFirst(prefix.count))
  }

  private func exportLinesOption(_ value: String?) -> [String] {
    guard let value, !value.isEmpty else {
      return []
    }
    return
      value
      .split(whereSeparator: \.isNewline)
      .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
  }

  private func photosUniqueStable(_ values: [String]) -> [String] {
    var seen: Set<String> = []
    var result: [String] = []
    for value in values where seen.insert(value).inserted {
      result.append(value)
    }
    return result
  }

  private func exportXattrTemplates(_ values: [String]) throws -> [PhotosXattrTemplate] {
    try values.map { value in
      guard let separator = value.firstIndex(of: "="), separator > value.startIndex else {
        throw CLIError(
          code: .validationError,
          message: "`--xattr-template` must use `name=template`."
        )
      }
      let name = String(value[..<separator]).trimmingCharacters(in: .whitespacesAndNewlines)
      let template = String(value[value.index(after: separator)...])
      try validateExportXattrName(name)
      return PhotosXattrTemplate(name: name, template: template)
    }
  }

  private func validateExportXattrName(_ name: String) throws {
    guard !name.isEmpty, name.count <= 128,
      name.range(of: #"^[A-Za-z0-9._:-]+$"#, options: .regularExpression) != nil
    else {
      throw CLIError(
        code: .validationError,
        message: "Photos xattr names may contain only letters, digits, `.`, `_`, `:`, and `-`."
      )
    }
    if name == "com.apple.quarantine" {
      throw CLIError(
        code: .validationError,
        message: "`com.apple.quarantine` is not an accepted Photos metadata xattr target."
      )
    }
  }

  private func exportPositiveIntOption(
    _ value: String?,
    name: String,
    defaultValue: Int,
    maximum: Int
  ) throws -> Int {
    guard let value, !value.isEmpty else {
      return defaultValue
    }
    guard let parsed = Int(value), parsed > 0 else {
      throw CLIError(
        code: .validationError,
        message: "Photos export option `\(name)` requires a positive integer."
      )
    }
    guard parsed <= maximum else {
      throw CLIError(
        code: .validationError,
        message: "Photos export option `\(name)` cannot exceed \(maximum)."
      )
    }
    return parsed
  }

  private func writeJSON(_ value: some Encodable, to url: URL) throws {
    let parent = url.deletingLastPathComponent()
    try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)
    try CLIJSON.encodeString(value, pretty: true).write(to: url, atomically: true, encoding: .utf8)
  }

  private func readExportState(from url: URL) throws -> PhotosExportStateDatabase {
    guard fileManager.fileExists(atPath: url.path) else {
      return PhotosExportStateDatabase(runs: [])
    }
    let data = try Data(contentsOf: url)
    if let state = try? JSONDecoder().decode(PhotosExportStateDatabase.self, from: data) {
      return state
    }
    if let legacyReport = try? JSONDecoder().decode(PhotosExportReport.self, from: data) {
      return PhotosExportStateDatabase(runs: [legacyReport])
    }
    throw CLIError(
      code: .validationError,
      message: "Photos export state DB is not readable JSON state.",
      details: ["path": url.path]
    )
  }

  private func appendExportReport(_ report: PhotosExportReport, to url: URL) throws {
    let existing = try readExportState(from: url)

    var updated = existing
    updated.append(report)
    try writeJSON(updated, to: url)
  }

  private func exportNonNegativeIntOption(
    _ value: String?,
    name: String,
    maximum: Int
  ) throws -> Int {
    guard let value, !value.isEmpty else {
      return 0
    }
    guard let parsed = Int(value), parsed >= 0 else {
      throw CLIError(
        code: .validationError,
        message: "Photos export option `\(name)` requires a non-negative integer."
      )
    }
    guard parsed <= maximum else {
      throw CLIError(
        code: .validationError,
        message: "Photos export option `\(name)` cannot exceed \(maximum)."
      )
    }
    return parsed
  }

  private func exportJPEGQualityOption(_ value: String) throws -> Double {
    guard let parsed = Double(value), parsed.isFinite, (0.0...1.0).contains(parsed) else {
      throw CLIError(
        code: .validationError,
        message: "Photos export option `jpeg_quality` must be between 0.0 and 1.0."
      )
    }
    return parsed
  }

  private func exportJPEGExtensionOption(_ value: String) throws -> String {
    try photosJPEGExtension(value)
  }

  private func withFileRetry<T>(
    retryCount: Int,
    retryWaitSeconds: Int,
    operation: () throws -> T
  ) throws -> T {
    var remainingRetries = retryCount
    while true {
      do {
        return try operation()
      } catch {
        guard remainingRetries > 0 else {
          throw error
        }
        remainingRetries -= 1
        if retryWaitSeconds > 0 {
          Thread.sleep(forTimeInterval: TimeInterval(retryWaitSeconds))
        }
      }
    }
  }

  private func exportFileSignature(path: String) throws -> String {
    let url = URL(fileURLWithPath: path)
    let attributes = try fileManager.attributesOfItem(atPath: path)
    let size = (attributes[.size] as? NSNumber)?.int64Value ?? 0
    let modificationDate = attributes[.modificationDate] as? Date
    let modificationMicroseconds = Int64((modificationDate?.timeIntervalSince1970 ?? 0) * 1_000_000)
    return photosSHA256Hex(
      [
        "name=\(url.lastPathComponent)",
        "size=\(size)",
        "mtime_us=\(modificationMicroseconds)",
      ].joined(separator: "\n")
    )
  }

  private func exportSemanticSignature(
    item: PhotosMediaItemRecord,
    kind: String,
    sourcePath: String,
    signatureTemplate: String?
  ) -> String {
    if let signatureTemplate {
      return photosSHA256Hex(
        photosRenderTemplate(
          signatureTemplate,
          item: item,
          resourcePath: sourcePath,
          resourceKind: kind
        )
      )
    }

    return photosSHA256Hex(
      [
        "uuid=\(item.uuid)",
        "kind=\(kind)",
        "filename=\(item.filename)",
        "title=\(item.title ?? "")",
        "description=\(item.description ?? "")",
        "date=\(item.date?.timeIntervalSince1970.description ?? "")",
        "date_added=\(item.dateAdded?.timeIntervalSince1970.description ?? "")",
        "favorite=\(item.favorite)",
        "hidden=\(item.hidden)",
        "width=\(item.width?.description ?? "")",
        "height=\(item.height?.description ?? "")",
        "media_type=\(item.mediaType)",
        "uti=\(item.uti ?? "")",
        "original_uti=\(item.originalUTI ?? "")",
        "raw_uti=\(item.rawUTI ?? "")",
        "keywords=\(item.keywords.sorted().joined(separator: "\u{1f}"))",
        "persons=\(item.persons.sorted().joined(separator: "\u{1f}"))",
        "labels=\(item.labels.sorted().joined(separator: "\u{1f}"))",
        "albums=\(item.albumIDs.sorted().joined(separator: "\u{1f}"))",
      ].joined(separator: "\n")
    )
  }

  private func xmpSidecar(for item: PhotosMediaItemRecord, renderedTemplate: String?) -> String {
    let subjects = (item.keywords + item.persons + item.labels)
      .map { "            <rdf:li>\(xmlEscape($0))</rdf:li>" }
      .joined(separator: "\n")
    let subjectBlock =
      subjects.isEmpty
      ? ""
      : """
            <dc:subject>
              <rdf:Bag>
      \(subjects)
              </rdf:Bag>
            </dc:subject>
      """
    let templateBlock =
      renderedTemplate.map {
        "          <photos:template>\(xmlEscape($0))</photos:template>"
      } ?? ""
    return """
      <?xml version="1.0" encoding="UTF-8"?>
      <x:xmpmeta xmlns:x="adobe:ns:meta/">
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
          <rdf:Description xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:photos="https://apple-cli.local/photos">
            <photos:uuid>\(xmlEscape(item.uuid))</photos:uuid>
            <dc:title>\(xmlEscape(item.title ?? ""))</dc:title>
            <dc:description>\(xmlEscape(item.description ?? ""))</dc:description>
      \(subjectBlock)
      \(templateBlock)
          </rdf:Description>
        </rdf:RDF>
      </x:xmpmeta>
      """
  }

  private func xmlEscape(_ value: String) -> String {
    value
      .replacingOccurrences(of: "&", with: "&amp;")
      .replacingOccurrences(of: "<", with: "&lt;")
      .replacingOccurrences(of: ">", with: "&gt;")
      .replacingOccurrences(of: "\"", with: "&quot;")
  }
}

private struct PhotosJSONSidecar: Codable, Sendable {
  var item: PhotosMediaItemRecord
  var renderedTemplate: String
}

private struct PhotosXattrTemplate: Sendable {
  var name: String
  var template: String
}

private struct PhotosExportStateDatabase: Codable, Sendable {
  var schemaVersion: Int
  var runs: [PhotosExportReport]
  var lastRunID: String?

  init(schemaVersion: Int = 1, runs: [PhotosExportReport], lastRunID: String? = nil) {
    self.schemaVersion = schemaVersion
    self.runs = runs
    self.lastRunID = lastRunID ?? runs.last?.runID
  }

  mutating func append(_ report: PhotosExportReport) {
    runs.append(report)
    lastRunID = report.runID
  }

  func report(runID: String?) -> PhotosExportReport? {
    guard let runID else {
      if let lastRunID {
        return runs.last { $0.runID == lastRunID } ?? runs.last
      }
      return runs.last
    }
    return runs.first { $0.runID == runID }
  }

  func latestResourcesByKey() -> [String: PhotosExportResourceRecord] {
    var resources: [String: PhotosExportResourceRecord] = [:]
    for run in runs {
      for resource in run.resources ?? [] {
        resources[Self.resourceKey(uuid: resource.uuid, kind: resource.kind)] = resource
      }
    }
    return resources
  }

  static func resourceKey(uuid: String, kind: String) -> String {
    "\(uuid)\u{1f}\(kind)"
  }
}

private struct PhotosExifPlan: Codable, Sendable {
  var fields: [String]
  var query: PhotosQuery
  var items: [PhotosMediaItemRecord]
}

private let photosAppleScriptFieldSeparator = "\u{1F}"
private let photosAppleScriptRowSeparator = "\u{1E}"

private let photosAppleScriptRecordHandlers = """
  on _photosJoin(values, separator)
    set oldDelimiters to AppleScript's text item delimiters
    set AppleScript's text item delimiters to separator
    set outputText to values as text
    set AppleScript's text item delimiters to oldDelimiters
    return outputText
  end _photosJoin

  on _photosContainerLine(theContainer)
    tell application "Photos"
      set parentID to ""
      try
        set parentID to id of parent of theContainer as text
      end try
      return my _photosJoin({id of theContainer as text, name of theContainer as text, parentID}, ASCII character 31)
    end tell
  end _photosContainerLine

  on _photosMediaItemLine(theItem)
    tell application "Photos"
      set keywordText to ""
      try
        set keywordText to my _photosJoin((keywords of theItem) as list, ",")
      end try
      set latitudeText to ""
      set longitudeText to ""
      try
        set locationValue to location of theItem
        if locationValue is not missing value then
          set latitudeText to item 1 of locationValue as text
          set longitudeText to item 2 of locationValue as text
        end if
      end try
      set descriptionText to ""
      try
        set descriptionText to description of theItem as text
      end try
      set titleText to ""
      try
        set titleText to name of theItem as text
      end try
      set dateText to ""
      try
        set dateText to date of theItem as text
      end try
      set sizeText to ""
      try
        set sizeText to size of theItem as text
      end try
      return my _photosJoin({id of theItem as text, filename of theItem as text, titleText, descriptionText, favorite of theItem as text, dateText, width of theItem as text, height of theItem as text, keywordText, latitudeText, longitudeText, sizeText}, ASCII character 31)
    end tell
  end _photosMediaItemLine
  """

public struct PhotosAppleScriptBackend: Sendable {
  public init() {}

  public func openLibrary(path: String) throws -> Bool {
    let url = URL(fileURLWithPath: path)
    guard url.pathExtension == "photoslibrary" else {
      throw CLIError(
        code: .validationError, message: "`--library` must point to a .photoslibrary package.")
    }

    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
      isDirectory.boolValue
    else {
      throw CLIError(
        code: .notFound, message: "Photos library was not found.", details: ["path": path])
    }

    guard NSWorkspace.shared.open(url) else {
      throw CLIError(
        code: .backendUnavailable,
        message: "Photos library could not be opened through LaunchServices.",
        details: ["path": path]
      )
    }
    return true
  }

  public func createAlbum(name: String, parentFolderID: String?) throws -> PhotosAlbumRecord {
    let parentScript = parentFolderID.map {
      photosAppleScriptContainerSelector(kind: "folder", selector: $0, variable: "parentFolder")
    }
    let atClause = parentFolderID == nil ? "" : " at parentFolder"
    let output = try runString(
      """
      \(photosAppleScriptRecordHandlers)
      tell application "Photos"
        \(parentScript ?? "")
        set createdAlbum to make new album named "\(photosAppleScriptString(name))"\(atClause)
        return my _photosContainerLine(createdAlbum)
      end tell
      """
    )
    return try photosAlbumRecord(fromAppleScriptLine: output)
  }

  public func deleteAlbum(idOrName: String) throws -> Bool {
    try runVoid(
      """
      tell application "Photos"
        \(photosAppleScriptContainerSelector(kind: "album", selector: idOrName, variable: "targetAlbum"))
        delete targetAlbum
      end tell
      """
    )
    return true
  }

  public func addItemsToAlbum(albumIDOrName: String, itemUUIDs: [String]) throws -> Bool {
    try runVoid(
      """
      tell application "Photos"
        \(photosAppleScriptContainerSelector(kind: "album", selector: albumIDOrName, variable: "targetAlbum"))
        set targetItems to {}
        repeat with itemID in \(photosAppleScriptList(itemUUIDs))
          set end of targetItems to media item id (itemID as text)
        end repeat
        add targetItems to targetAlbum
      end tell
      """
    )
    return true
  }

  public func createFolder(name: String, parentFolderID: String?) throws -> PhotosFolderRecord {
    let parentScript = parentFolderID.map {
      photosAppleScriptContainerSelector(kind: "folder", selector: $0, variable: "parentFolder")
    }
    let atClause = parentFolderID == nil ? "" : " at parentFolder"
    let output = try runString(
      """
      \(photosAppleScriptRecordHandlers)
      tell application "Photos"
        \(parentScript ?? "")
        set createdFolder to make new folder named "\(photosAppleScriptString(name))"\(atClause)
        return my _photosContainerLine(createdFolder)
      end tell
      """
    )
    return try photosFolderRecord(fromAppleScriptLine: output)
  }

  public func deleteFolder(idOrName: String) throws -> Bool {
    try runVoid(
      """
      tell application "Photos"
        \(photosAppleScriptContainerSelector(kind: "folder", selector: idOrName, variable: "targetFolder"))
        delete targetFolder
      end tell
      """
    )
    return true
  }

  public func updateMediaItem(uuid: String, fields: [String: String]) throws
    -> PhotosMediaItemRecord
  {
    if fields.keys.contains("hidden") {
      throw photosProofFailed(
        "photos media-items update --hidden",
        reason: "Photos SDEF does not expose a stable writable hidden property for media item.")
    }

    var assignments: [String] = []
    if let title = fields["title"] {
      assignments.append("set name of targetItem to \"\(photosAppleScriptString(title))\"")
    }
    if let description = fields["description"] {
      assignments.append(
        "set description of targetItem to \"\(photosAppleScriptString(description))\"")
    }
    if let keyword = fields["keyword"] {
      assignments.append(
        "set keywords of targetItem to \(photosAppleScriptList(photosCommaList(keyword)))")
    }
    if let favorite = fields["favorite"] {
      assignments.append("set favorite of targetItem to \(favorite == "true" ? "true" : "false")")
    }
    if let date = fields["date"] {
      assignments.append("set date of targetItem to date \"\(photosAppleScriptString(date))\"")
    }
    if let location = fields["location"] {
      let parts = photosCommaList(location)
      guard parts.count == 2, Double(parts[0]) != nil, Double(parts[1]) != nil else {
        throw CLIError(
          code: .validationError, message: "`--location` must be `latitude,longitude`.")
      }
      assignments.append("set location of targetItem to {\(parts[0]), \(parts[1])}")
    }

    let output = try runString(
      """
      \(photosAppleScriptRecordHandlers)
      tell application "Photos"
        set targetItem to media item id "\(photosAppleScriptString(uuid))"
        \(assignments.joined(separator: "\n        "))
        return my _photosMediaItemLine(targetItem)
      end tell
      """
    )

    if let album = fields["album-id"] {
      _ = try addItemsToAlbum(albumIDOrName: album, itemUUIDs: [uuid])
    }

    return try photosMediaItemRecord(fromAppleScriptLine: output)
  }

  public func duplicateMediaItem(uuid: String) throws -> PhotosMediaItemRecord {
    let output = try runString(
      """
      \(photosAppleScriptRecordHandlers)
      tell application "Photos"
        set duplicatedItem to duplicate media item id "\(photosAppleScriptString(uuid))"
        return my _photosMediaItemLine(duplicatedItem)
      end tell
      """
    )
    return try photosMediaItemRecord(fromAppleScriptLine: output)
  }

  public func listSelection(limit: Int?) throws -> [PhotosMediaItemRecord] {
    let limitScript = limit.map { "if itemIndex > \($0) then exit repeat" } ?? ""
    let output = try runString(
      """
      \(photosAppleScriptRecordHandlers)
      tell application "Photos"
        set outputLines to {}
        set selectedItems to selection
        set itemIndex to 0
        repeat with selectedItem in selectedItems
          set itemIndex to itemIndex + 1
          \(limitScript)
          set end of outputLines to my _photosMediaItemLine(selectedItem)
        end repeat
        return my _photosJoin(outputLines, ASCII character 30)
      end tell
      """
    )
    return try photosMediaItemRecords(fromAppleScriptOutput: output)
  }

  public func importItems(
    paths: [String],
    albumIDOrName: String?,
    skipDuplicateCheck: Bool
  ) throws -> [PhotosMediaItemRecord] {
    let albumSelector = albumIDOrName.map {
      photosAppleScriptContainerSelector(kind: "album", selector: $0, variable: "targetAlbum")
    }
    let intoClause = albumIDOrName == nil ? "" : " into targetAlbum"
    let output = try runString(
      """
      \(photosAppleScriptRecordHandlers)
      tell application "Photos"
        \(albumSelector ?? "")
        set importFiles to {}
        repeat with importPath in \(photosAppleScriptList(paths))
          set end of importFiles to POSIX file (importPath as text)
        end repeat
        set importedItems to import importFiles\(intoClause) skip check duplicates \(skipDuplicateCheck ? "true" : "false")
        set outputLines to {}
        repeat with importedItem in importedItems
          set end of outputLines to my _photosMediaItemLine(importedItem)
        end repeat
        return my _photosJoin(outputLines, ASCII character 30)
      end tell
      """
    )
    return try photosMediaItemRecords(fromAppleScriptOutput: output)
  }

  public func slideshowRunning() throws -> Bool {
    let output = try runString(
      """
      tell application "Photos"
        return slideshow running
      end tell
      """
    )
    switch output.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
    case "true":
      return true
    case "false":
      return false
    default:
      throw CLIError(
        code: .backendUnavailable,
        message: "Photos returned an unexpected slideshow running value.",
        details: ["value": output]
      )
    }
  }

  public func exportItems(uuids: [String], destination: String, usingOriginals: Bool) throws
    -> PhotosExportResult
  {
    try runVoid(
      """
      tell application "Photos"
        set exportItems to {}
        repeat with itemID in \(photosAppleScriptList(uuids))
          set end of exportItems to media item id (itemID as text)
        end repeat
        export exportItems to POSIX file "\(photosAppleScriptString(destination))" using originals \(usingOriginals ? "true" : "false")
      end tell
      """,
      timeoutSeconds: 300
    )
    return PhotosExportResult(
      exported: uuids.count,
      destination: destination,
      exportedUUIDs: uuids
    )
  }

  public func slideshow(action: String, query: PhotosQuery) throws -> Bool {
    let command =
      switch action {
      case "start" where !query.uuids.isEmpty:
        "start slideshow using \(photosAppleScriptMediaItemList(query.uuids))"
      case "start": "start slideshow using selection"
      case "stop": "stop slideshow"
      case "next": "next slide"
      case "previous": "previous slide"
      case "pause": "pause slideshow"
      case "resume": "resume slideshow"
      default: ""
      }
    guard !command.isEmpty else {
      throw CLIError(code: .validationError, message: "Unsupported Photos slideshow action.")
    }
    try runVoid("tell application \"Photos\" to \(command)")
    return true
  }

  public func showSpotlight(selector: String) throws -> Bool {
    let target =
      FileManager.default.fileExists(atPath: selector)
      ? "\"\(photosAppleScriptString(selector))\""
      : "media item id \"\(photosAppleScriptString(selector))\""
    try runVoid(
      """
      tell application "Photos"
        spotlight \(target)
      end tell
      """
    )
    return true
  }

  private func runVoid(_ source: String, timeoutSeconds: Int = 30) throws {
    var errorInfo: NSDictionary?
    guard
      let script = NSAppleScript(source: photosTimedAppleScriptSource(source, timeoutSeconds))
    else {
      throw CLIError(code: .internalError, message: "Failed to compile Photos automation script.")
    }
    _ = script.executeAndReturnError(&errorInfo)
    if let errorInfo {
      throw photosAutomationError(errorInfo)
    }
  }

  private func runString(_ source: String, timeoutSeconds: Int = 30) throws -> String {
    var errorInfo: NSDictionary?
    guard
      let script = NSAppleScript(source: photosTimedAppleScriptSource(source, timeoutSeconds))
    else {
      throw CLIError(code: .internalError, message: "Failed to compile Photos automation script.")
    }
    let result = script.executeAndReturnError(&errorInfo)
    if let errorInfo {
      throw photosAutomationError(errorInfo)
    }
    return result.stringValue ?? ""
  }
}

private func photosTimedAppleScriptSource(_ source: String, _ timeoutSeconds: Int) -> String {
  let trimmedSource = source.trimmingCharacters(in: .whitespacesAndNewlines)
  let recordHandlers = photosAppleScriptRecordHandlers.trimmingCharacters(
    in: .whitespacesAndNewlines)

  if trimmedSource.hasPrefix(recordHandlers) {
    let body = String(trimmedSource.dropFirst(recordHandlers.count))
      .trimmingCharacters(in: .whitespacesAndNewlines)
    return """
      \(recordHandlers)
      with timeout of \(timeoutSeconds) seconds
      \(body)
      end timeout
      """
  }

  return """
    with timeout of \(timeoutSeconds) seconds
    \(trimmedSource)
    end timeout
    """
}

private func photosAutomationError(_ errorInfo: NSDictionary) -> CLIError {
  let originalMessage =
    errorInfo[NSAppleScript.errorMessage] as? String ?? "Photos automation failed."
  let number = errorInfo[NSAppleScript.errorNumber] as? Int
  let code: CLIErrorCode =
    if number == -1712 {
      .timeout
    } else if let number, [-1743, -25211].contains(number) {
      .permissionDenied
    } else if number == -1728 {
      .notFound
    } else {
      .backendUnavailable
    }
  var details = ["executor": "NSAppleScript"]
  if let number {
    details["apple_event_error"] = "\(number)"
  }
  if code == .permissionDenied {
    details["original_error"] = originalMessage
  }
  return CLIError(
    code: code,
    message: code == .permissionDenied
      ? CLIPermissionWording.automationPermissionRequired(target: "Photos")
      : originalMessage,
    details: details)
}

private func photosAppleScriptContainerSelector(kind: String, selector: String, variable: String)
  -> String
{
  let escaped = photosAppleScriptString(selector)
  return """
    if exists \(kind) id "\(escaped)" then
      set \(variable) to \(kind) id "\(escaped)"
    else
      set \(variable) to \(kind) "\(escaped)"
    end if
    """
}

private func photosAppleScriptList(_ values: [String]) -> String {
  "{\(values.map { "\"\(photosAppleScriptString($0))\"" }.joined(separator: ", "))}"
}

private func photosAppleScriptMediaItemList(_ uuids: [String]) -> String {
  "{\(uuids.map { "media item id \"\(photosAppleScriptString($0))\"" }.joined(separator: ", "))}"
}

private func photosAlbumRecord(fromAppleScriptLine line: String) throws -> PhotosAlbumRecord {
  let fields = photosAppleScriptFields(line)
  guard fields.count >= 2 else {
    throw CLIError(
      code: .backendUnavailable, message: "Photos album automation returned an invalid record.")
  }
  return PhotosAlbumRecord(
    id: fields[0],
    name: fields[1],
    parentID: fields[safe: 2].flatMap { $0.isEmpty ? nil : $0 }
  )
}

private func photosFolderRecord(fromAppleScriptLine line: String) throws -> PhotosFolderRecord {
  let fields = photosAppleScriptFields(line)
  guard fields.count >= 2 else {
    throw CLIError(
      code: .backendUnavailable, message: "Photos folder automation returned an invalid record.")
  }
  return PhotosFolderRecord(
    id: fields[0],
    name: fields[1],
    parentID: fields[safe: 2].flatMap { $0.isEmpty ? nil : $0 }
  )
}

private func photosMediaItemRecords(fromAppleScriptOutput output: String) throws
  -> [PhotosMediaItemRecord]
{
  try output
    .split(separator: Character(photosAppleScriptRowSeparator), omittingEmptySubsequences: true)
    .map { try photosMediaItemRecord(fromAppleScriptLine: String($0)) }
}

private func photosMediaItemRecord(fromAppleScriptLine line: String) throws -> PhotosMediaItemRecord
{
  let fields = photosAppleScriptFields(line)
  guard fields.count >= 2 else {
    throw CLIError(
      code: .backendUnavailable, message: "Photos media item automation returned an invalid record."
    )
  }
  let latitude = fields[safe: 9].flatMap(Double.init)
  let longitude = fields[safe: 10].flatMap(Double.init)
  let location: PhotosLocationRecord? =
    if let latitude, let longitude {
      PhotosLocationRecord(latitude: latitude, longitude: longitude)
    } else {
      nil
    }
  let uuid = fields[0]
  return PhotosMediaItemRecord(
    id: "photos-media-item:\(uuid)",
    uuid: uuid,
    filename: fields[1],
    title: fields[safe: 2].flatMap { $0.isEmpty ? nil : $0 },
    description: fields[safe: 3].flatMap { $0.isEmpty ? nil : $0 },
    favorite: fields[safe: 4].map { ["true", "yes", "1"].contains($0.lowercased()) } ?? false,
    keywords: photosCommaList(fields[safe: 8] ?? ""),
    width: fields[safe: 6].flatMap(Int.init),
    height: fields[safe: 7].flatMap(Int.init),
    fileSize: fields[safe: 11].flatMap(Int64.init),
    location: location
  )
}

private func photosAppleScriptFields(_ line: String) -> [String] {
  line.split(
    separator: Character(photosAppleScriptFieldSeparator), omittingEmptySubsequences: false
  )
  .map(String.init)
}

private func photosCommaList(_ value: String) -> [String] {
  value
    .split(whereSeparator: { $0 == "," || $0 == "\n" })
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }
}

private func photosAppleScriptString(_ value: String) -> String {
  value
    .replacingOccurrences(of: "\\", with: "\\\\")
    .replacingOccurrences(of: "\"", with: "\\\"")
    .replacingOccurrences(of: "\r\n", with: "\" & return & \"")
    .replacingOccurrences(of: "\n", with: "\" & return & \"")
    .replacingOccurrences(of: "\r", with: "\" & return & \"")
}

extension Array {
  fileprivate subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
