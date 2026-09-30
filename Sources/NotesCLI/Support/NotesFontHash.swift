import AppKit
import Foundation
import Utility

func notesFontSHA256(_ font: NSFont) -> String {
  let traits = NSFontManager.shared.traits(of: font).rawValue
  let fields = [
    font.familyName ?? "",
    font.fontName,
    String(format: "%.3f", Double(font.pointSize)),
    "\(traits)",
  ]
  return sha256Hex(fields.joined(separator: "|"))
}
