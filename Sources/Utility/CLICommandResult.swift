public struct CLICommandResult: Equatable, Sendable {
  public var exitCode: Int32
  public var stdout: String?
  public var stderr: String?

  public init(
    exitCode: Int32 = 0,
    stdout: String? = nil,
    stderr: String? = nil
  ) {
    self.exitCode = exitCode
    self.stdout = stdout
    self.stderr = stderr
  }
}
