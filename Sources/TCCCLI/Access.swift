import ApplicationServices
import CoreGraphics
import Foundation
import IOKit.hidsystem
import Utility

public protocol TCCAccessChecking: Sendable {
  func preflight(service: TCCServiceInfo) throws -> TCCAccessCheckResponse
  func request(service: TCCServiceInfo) throws -> TCCAccessCheckResponse
}

public struct TCCPublicAccessBackend: TCCAccessChecking {
  public init() {}

  public func preflight(service: TCCServiceInfo) throws -> TCCAccessCheckResponse {
    switch service.suffix {
    case "Accessibility":
      let granted = AXIsProcessTrusted()
      return TCCAccessCheckResponse(
        service: service,
        granted: granted,
        route: "ApplicationServices.AXIsProcessTrusted",
        prompted: false
      )
    case "ScreenCapture":
      let granted = CGPreflightScreenCaptureAccess()
      return TCCAccessCheckResponse(
        service: service,
        granted: granted,
        route: "CoreGraphics.CGPreflightScreenCaptureAccess",
        prompted: false
      )
    case "ListenEvent":
      let access = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent)
      return TCCAccessCheckResponse(
        service: service,
        granted: access == kIOHIDAccessTypeGranted,
        route: "IOKit.hidsystem.IOHIDCheckAccess(kIOHIDRequestTypeListenEvent)",
        prompted: false,
        diagnostics: ["raw_access=\(access.rawValue)"]
      )
    default:
      throw CLIError(
        code: .unsupportedOperation,
        message: TCCWording.publicPreflightRouteUnavailable(),
        details: ["service": service.rawName, "public_api_route": service.publicAPIRoute ?? ""]
      )
    }
  }

  public func request(service: TCCServiceInfo) throws -> TCCAccessCheckResponse {
    switch service.suffix {
    case "Accessibility":
      let options = [
        "AXTrustedCheckOptionPrompt": true
      ] as CFDictionary
      let granted = AXIsProcessTrustedWithOptions(options)
      return TCCAccessCheckResponse(
        service: service,
        granted: granted,
        route: "ApplicationServices.AXIsProcessTrustedWithOptions(prompt: true)",
        prompted: true
      )
    case "ScreenCapture":
      let granted = CGRequestScreenCaptureAccess()
      return TCCAccessCheckResponse(
        service: service,
        granted: granted,
        route: "CoreGraphics.CGRequestScreenCaptureAccess",
        prompted: true
      )
    case "ListenEvent":
      let granted = IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
      return TCCAccessCheckResponse(
        service: service,
        granted: granted,
        route: "IOKit.hidsystem.IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)",
        prompted: true
      )
    default:
      throw CLIError(
        code: .unsupportedOperation,
        message: TCCWording.publicRequestRouteUnavailable(),
        details: ["service": service.rawName, "public_api_route": service.publicAPIRoute ?? ""]
      )
    }
  }
}
