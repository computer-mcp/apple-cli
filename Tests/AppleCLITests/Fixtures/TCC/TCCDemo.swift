import ApplicationServices
import CoreGraphics
import Foundation

let payload: [String: Any] = [
  "executable": CommandLine.arguments.first ?? "",
  "pid": ProcessInfo.processInfo.processIdentifier,
  "accessibilityTrusted": AXIsProcessTrusted(),
  "screenCaptureGranted": CGPreflightScreenCaptureAccess(),
]

let data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
FileHandle.standardOutput.write(data)
FileHandle.standardOutput.write(Data("\n".utf8))
