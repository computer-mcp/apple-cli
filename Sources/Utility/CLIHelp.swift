public struct CLIHelpDocument: Equatable, Sendable {
  public var executableName: String
  public var summary: String
  public var currentScope: [String]
  public var status: String

  public init(
    executableName: String,
    summary: String,
    currentScope: [String],
    status: String
  ) {
    self.executableName = executableName
    self.summary = summary
    self.currentScope = currentScope
    self.status = status
  }

  public func render() -> String {
    let scopeText =
      currentScope
      .map { "  - \($0)" }
      .joined(separator: "\n")

    return """
      \(executableName)

      \(summary)

      Current scope:
      \(scopeText)

      \(status)
      """
  }
}
