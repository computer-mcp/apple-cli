import Foundation
import Utility

func reminderTagsOption(_ value: String?, optionName: String) throws -> [String] {
  guard let value else {
    return []
  }

  let tags = value
    .split { character in
      character == "," || character == "\n"
    }
    .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }

  guard !tags.isEmpty, tags.allSatisfy({ !$0.isEmpty }) else {
    throw CLIError(
      code: .validationError,
      message: "`--\(optionName)` must contain at least one non-empty tag."
    )
  }

  guard tags.allSatisfy({ !$0.contains("#") }) else {
    throw CLIError(
      code: .validationError,
      message: "`--\(optionName)` tag names should be provided without `#`."
    )
  }

  guard tags.count <= 50 else {
    throw CLIError(
      code: .validationError,
      message: "`--\(optionName)` cannot contain more than 50 tags."
    )
  }

  var seen: Set<String> = []
  var normalized: [String] = []
  for tag in tags {
    let key = tag.lowercased()
    if seen.insert(key).inserted {
      normalized.append(tag)
    }
  }
  return normalized
}

func reminderSectionOption(_ value: String?) throws -> String? {
  guard let value else {
    return nil
  }

  let title = value.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !title.isEmpty else {
    throw CLIError(code: .validationError, message: "`--section` must not be empty.")
  }
  return title
}
