import CryptoKit
import Foundation
import Utility

public protocol PrintReading: Sendable {
  func listPrinters(limit: Int) throws -> [PrinterRecord]
  func readPrinter(name: String) throws -> PrinterRecord?
  func listJobs(printer: String?, limit: Int) throws -> [PrintJobRecord]
}

public protocol PrintActing: Sendable {
  func submit(filePath: String, printerName: String) throws -> String
  func cancel(jobID: String) throws -> Bool
}

public protocol CUPSCommandRunning: Sendable {
  func runLPStat(arguments: [String]) throws -> String
}

public protocol CUPSActionCommandRunning: Sendable {
  func runLP(arguments: [String]) throws -> String
  func runCancel(arguments: [String]) throws -> String
}
