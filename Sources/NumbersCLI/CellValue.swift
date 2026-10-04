import Carbon
import Foundation
import Utility

extension NumbersCellRecord {
  func matchesLiteralText(_ text: String) -> Bool {
    valueType == .text && rawValue == text && formula == ""
  }
}

func numbersCellRecord(_ row: NSAppleEventDescriptor) throws -> NumbersCellRecord {
  guard row.descriptorType == typeAEList, row.numberOfItems == 9,
    let sheet = row.atIndex(1)?.stringValue,
    let table = row.atIndex(2)?.stringValue,
    let rowCountText = row.atIndex(3)?.stringValue, let rowCount = Int(rowCountText),
    let columnCountText = row.atIndex(4)?.stringValue, let columnCount = Int(columnCountText),
    let rowText = row.atIndex(5)?.stringValue, let rowIndex = Int(rowText),
    let columnText = row.atIndex(6)?.stringValue, let columnIndex = Int(columnText),
    let displayValue = row.atIndex(7), let rawValue = row.atIndex(8),
    let formula = row.atIndex(9),
    rowIndex > 0, rowIndex <= rowCount, columnIndex > 0, columnIndex <= columnCount
  else {
    throw numbersCellReadError()
  }
  let value = try numbersCellValue(rawValue)
  let formulaText: String
  if numbersDescriptorIsMissing(formula) {
    formulaText = ""
  } else {
    guard let text = numbersTextDescriptor(formula) else { throw numbersCellReadError() }
    formulaText = text
  }
  let displayText: String
  if numbersDescriptorIsMissing(displayValue) {
    displayText = ""
  } else {
    guard let text = numbersTextDescriptor(displayValue) else { throw numbersCellReadError() }
    displayText = text
  }
  return NumbersCellRecord(
    sheetName: sheet, tableName: table, row: rowIndex, column: columnIndex,
    rowCount: rowCount, columnCount: columnCount, value: displayText,
    rawValue: value.rawValue, valueType: value.type, formula: formulaText
  )
}

private func numbersCellValue(_ descriptor: NSAppleEventDescriptor) throws
  -> (rawValue: String?, type: NumbersCellValueType)
{
  if numbersDescriptorIsMissing(descriptor) { return (nil, .empty) }
  switch descriptor.descriptorType {
  case typeUnicodeText, typeUTF8Text, typeChar, typeCString:
    guard let value = descriptor.stringValue else { throw numbersCellReadError() }
    return (value, .text)
  case typeBoolean, typeTrue, typeFalse:
    return (descriptor.booleanValue ? "true" : "false", .boolean)
  case typeSInt16, typeSInt32, typeUInt32, typeSInt64, typeUInt64:
    guard let value = descriptor.coerce(toDescriptorType: typeUnicodeText)?.stringValue else {
      throw numbersCellReadError()
    }
    return (value, .number)
  case typeIEEE32BitFloatingPoint, typeIEEE64BitFloatingPoint:
    guard let value = descriptor.coerce(toDescriptorType: typeIEEE64BitFloatingPoint),
      value.doubleValue.isFinite
    else { throw numbersCellReadError() }
    return (String(value.doubleValue), .number)
  case typeLongDateTime:
    guard let date = descriptor.dateValue else { throw numbersCellReadError() }
    return (ISO8601DateFormatter().string(from: date), .date)
  default:
    throw numbersCellReadError()
  }
}

private func numbersDescriptorIsMissing(_ descriptor: NSAppleEventDescriptor) -> Bool {
  descriptor.descriptorType == typeNull
    || (descriptor.descriptorType == typeType && descriptor.typeCodeValue == OSType(cMissingValue))
}

private func numbersTextDescriptor(_ descriptor: NSAppleEventDescriptor) -> String? {
  guard [typeUnicodeText, typeUTF8Text, typeChar, typeCString].contains(descriptor.descriptorType)
  else { return nil }
  return descriptor.stringValue
}

private func numbersCellReadError() -> CLIError {
  CLIError(
    code: .backendUnavailable,
    message: "Numbers did not return a complete typed cell value and formula."
  )
}
