import CoreGraphics
import Foundation
#if canImport(PDFKit)
import PDFKit
#endif
import Utility

public struct NotesVisionAttachmentRecognizedTextGenerator:
  NotesAttachmentRecognizedTextGenerating
{
  public init() {}

  public func generateRecognizedText(
    from input: NotesAttachmentRecognizedTextGenerationInput
  ) throws -> NotesAttachmentRecognizedTextGeneration {
    if let pdfResult = try recognizePDFText(input.data) {
      return pdfResult
    }
    return try recognizeImageText(input.data)
  }

  private func recognizePDFText(_ data: Data) throws -> NotesAttachmentRecognizedTextGeneration? {
    #if canImport(PDFKit)
    guard let document = PDFDocument(data: data), document.pageCount > 0 else {
      return nil
    }
    var chunks: [String] = []
    var observationCount = 0
    for index in 0..<document.pageCount {
      guard let page = document.page(at: index),
        let image = renderPDFPage(page)
      else {
        continue
      }
      let pageResult = try recognizeCGImage(image)
      observationCount += pageResult.observationCount
      if !pageResult.text.isEmpty {
        chunks.append(pageResult.text)
      }
    }
    return try generatedText(
      chunks.joined(separator: "\n\n"),
      sourceKind: "Vision.VNRecognizeTextRequest+PDFKit.PDFDocument",
      pageCount: document.pageCount,
      observationCount: observationCount
    )
    #else
    return nil
    #endif
  }

  private func recognizeImageText(_ data: Data) throws -> NotesAttachmentRecognizedTextGeneration {
    let request = try makeRecognizeTextRequest()
    let handler = try makeImageRequestHandler(data: data)
    try performVisionRequest(handler: handler, request: request)
    return try generatedText(
      recognizedText(from: request),
      sourceKind: "Vision.VNRecognizeTextRequest+VNImageRequestHandler.data",
      pageCount: nil,
      observationCount: visionObservationCount(from: request)
    )
  }

  private func recognizeCGImage(_ image: CGImage) throws -> NotesAttachmentRecognizedTextGeneration {
    let request = try makeRecognizeTextRequest()
    let handler = try makeImageRequestHandler(cgImage: image)
    try performVisionRequest(handler: handler, request: request)
    return try generatedText(
      recognizedText(from: request),
      sourceKind: "Vision.VNRecognizeTextRequest+CGImage",
      pageCount: nil,
      observationCount: visionObservationCount(from: request)
    )
  }

  private func makeRecognizeTextRequest() throws -> NSObject {
    guard let requestClass = NSClassFromString("VNRecognizeTextRequest") as? NSObject.Type else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Recognized text generation requires the Vision runtime."
      )
    }
    let request = requestClass.init()
    request.setValue(1, forKey: "recognitionLevel")
    request.setValue(true, forKey: "usesLanguageCorrection")
    return request
  }

  private func makeImageRequestHandler(data: Data) throws -> NSObject {
    try makeVisionHandler(
      selectorName: "initWithData:options:",
      firstArgument: data as NSData
    )
  }

  private func makeImageRequestHandler(cgImage: CGImage) throws -> NSObject {
    try makeVisionHandler(
      selectorName: "initWithCGImage:options:",
      firstArgument: cgImage
    )
  }

  private func makeVisionHandler(selectorName: String, firstArgument: AnyObject) throws -> NSObject {
    guard let handlerClass = NSClassFromString("VNImageRequestHandler") else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Recognized text generation requires the Vision runtime."
      )
    }
    guard let allocated = (handlerClass as AnyObject)
      .perform(NSSelectorFromString("alloc"))?
      .takeUnretainedValue() as? NSObject
    else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Could not allocate Vision image request handler."
      )
    }
    guard let initialized = allocated
      .perform(
        NSSelectorFromString(selectorName),
        with: firstArgument,
        with: NSDictionary()
      )?
      .takeUnretainedValue() as? NSObject
    else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Could not initialize Vision image request handler."
      )
    }
    return initialized
  }

  private func performVisionRequest(handler: NSObject, request: NSObject) throws {
    let selector = NSSelectorFromString("performRequests:error:")
    guard let implementation = class_getMethodImplementation(type(of: handler), selector) else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Vision image request handler does not expose text-recognition execution."
      )
    }
    typealias PerformRequests = @convention(c) (
      AnyObject,
      Selector,
      NSArray,
      UnsafeMutablePointer<NSError?>?
    ) -> Bool
    let perform = unsafeBitCast(implementation, to: PerformRequests.self)
    var error: NSError?
    let ok = perform(handler, selector, [request] as NSArray, &error)
    guard ok else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Vision recognized text generation failed.",
        details: ["vision_error": error?.localizedDescription ?? "unknown"]
      )
    }
  }

  private func recognizedText(from request: NSObject) -> String {
    visionObservations(from: request)
      .compactMap(visionTopCandidateString)
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
      .joined(separator: "\n")
  }

  private func visionObservationCount(from request: NSObject) -> Int {
    visionObservations(from: request).count
  }

  private func visionObservations(from request: NSObject) -> [NSObject] {
    (request.value(forKey: "results") as? [NSObject]) ?? []
  }

  private func visionTopCandidateString(_ observation: NSObject) -> String? {
    let selector = NSSelectorFromString("topCandidates:")
    guard let implementation = class_getMethodImplementation(type(of: observation), selector) else {
      return nil
    }
    typealias TopCandidates = @convention(c) (AnyObject, Selector, Int) -> NSArray?
    let topCandidates = unsafeBitCast(implementation, to: TopCandidates.self)
    guard let candidate = topCandidates(observation, selector, 1)?.firstObject as? NSObject else {
      return nil
    }
    return candidate.value(forKey: "string") as? String
  }

  private func generatedText(
    _ text: String,
    sourceKind: String,
    pageCount: Int?,
    observationCount: Int
  ) throws -> NotesAttachmentRecognizedTextGeneration {
    let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalized.isEmpty else {
      throw CLIError(
        code: .unsupportedOperation,
        message: "Recognized text generation produced no text for the selected attachment.",
        details: [
          "recognition_source_kind": sourceKind,
          "observation_count": "\(observationCount)",
        ]
      )
    }
    return NotesAttachmentRecognizedTextGeneration(
      text: normalized,
      sourceKind: sourceKind,
      pageCount: pageCount,
      observationCount: observationCount
    )
  }

  #if canImport(PDFKit)
  private func renderPDFPage(_ page: PDFPage) -> CGImage? {
    let bounds = page.bounds(for: .mediaBox)
    let scale: CGFloat = 2
    let width = max(1, Int(bounds.width * scale))
    let height = max(1, Int(bounds.height * scale))
    guard let context = CGContext(
      data: nil,
      width: width,
      height: height,
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
      return nil
    }
    context.setFillColor(CGColor(gray: 1, alpha: 1))
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: scale, y: -scale)
    page.draw(with: .mediaBox, to: context)
    return context.makeImage()
  }
  #endif
}
