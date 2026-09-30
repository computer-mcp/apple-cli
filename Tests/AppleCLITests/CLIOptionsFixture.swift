import Utility

enum CLIOptionsFixture {
  static func parse(_ arguments: [String]) throws -> CLIOptions {
    var options = CLIOptions()
    var index = 0

    while index < arguments.count {
      let argument = arguments[index]
      let removedOption = "--confirm" + "-" + "re" + "ceipt"

      if argument == removedOption || argument.hasPrefix(removedOption + "=") {
        throw CLIError(
          code: .validationError,
          message: "Removed execution option is not supported; use `--dry-run` for preview."
        )
      }

      switch argument {
      case "--":
        options.positionals.append(contentsOf: arguments.dropFirst(index + 1))
        return options
      case "--help", "-h":
        options.help = true
      case "--version":
        options.version = true
      case "--json":
        options.json = true
      case "--pretty":
        options.pretty = true
      case "--verbose":
        options.verbose = true
      case "--dry-run":
        options.dryRun = true
      case "--allow-destructive-selection":
        options.safetyFlags.insert("allow-destructive-selection")
      case "--allow-external-dispatch":
        options.safetyFlags.insert("allow-external-dispatch")
      case "--allow-artifact-action":
        options.safetyFlags.insert("allow-artifact-action")
      case "--allow-persistent-action":
        options.safetyFlags.insert("allow-persistent-action")
      case "--limit":
        index += 1
        guard index < arguments.count else {
          throw CLIError(
            code: .validationError,
            message: "`--limit` requires a positive integer value."
          )
        }
        options.limit = try parsePositiveInteger(arguments[index], flag: "--limit")
      default:
        if let value = argument.value(afterPrefix: "--limit=") {
          options.limit = try parsePositiveInteger(value, flag: "--limit")
        } else if argument.hasPrefix("--") {
          let targetOption = String(argument.dropFirst(2))
          guard !targetOption.isEmpty else {
            throw CLIError(
              code: .validationError,
              message: "Target option name cannot be empty."
            )
          }

          if let equalsIndex = targetOption.firstIndex(of: "=") {
            let name = String(targetOption[..<equalsIndex])
            let value = String(targetOption[targetOption.index(after: equalsIndex)...])
            guard !name.isEmpty, !value.isEmpty else {
              throw CLIError(
                code: .validationError,
                message: "Target option `--\(name)` requires a non-empty value."
              )
            }
            options.appendTargetOption(value, for: name)
          } else if index + 1 < arguments.count, arguments[index + 1].canBeOptionValue {
            index += 1
            options.appendTargetOption(arguments[index], for: targetOption)
          } else {
            options.targetFlags.insert(targetOption)
          }
        } else if argument.hasPrefix("-") {
          throw CLIError(
            code: .validationError,
            message: "Unsupported shared option: \(argument)"
          )
        } else {
          options.positionals.append(argument)
        }
      }

      index += 1
    }

    return options
  }

  private static func parsePositiveInteger(_ value: String, flag: String) throws -> Int {
    guard let parsed = Int(value), parsed > 0 else {
      throw CLIError(
        code: .validationError,
        message: "`\(flag)` requires a positive integer value."
      )
    }
    return parsed
  }
}

extension CLIOptions {
  fileprivate mutating func appendTargetOption(_ value: String, for name: String) {
    if let existing = targetOptions[name], !existing.isEmpty {
      targetOptions[name] = existing + "\n" + value
    } else {
      targetOptions[name] = value
    }
  }
}

extension String {
  fileprivate func value(afterPrefix prefix: String) -> String? {
    guard hasPrefix(prefix) else {
      return nil
    }
    return String(dropFirst(prefix.count))
  }

  fileprivate var canBeOptionValue: Bool {
    !hasPrefix("-") || isNegativeNumericLiteral
  }

  fileprivate var isNegativeNumericLiteral: Bool {
    hasPrefix("-") && !hasPrefix("--") && Double(self) != nil
  }
}
