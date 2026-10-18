public struct CLIOptions: Equatable, Sendable {
  public var help: Bool
  public var version: Bool
  public var json: Bool
  public var pretty: Bool
  public var verbose: Bool
  public var limit: Int?
  public var dryRun: Bool
  public var safetyFlags: Set<String>
  public var targetOptions: [String: String]
  public var targetFlags: Set<String>
  public var positionals: [String]

  public init(
    help: Bool = false,
    version: Bool = false,
    json: Bool = false,
    pretty: Bool = false,
    verbose: Bool = false,
    limit: Int? = nil,
    dryRun: Bool = false,
    safetyFlags: Set<String> = [],
    targetOptions: [String: String] = [:],
    targetFlags: Set<String> = [],
    positionals: [String] = []
  ) {
    self.help = help
    self.version = version
    self.json = json
    self.pretty = pretty
    self.verbose = verbose
    self.limit = limit
    self.dryRun = dryRun
    self.safetyFlags = safetyFlags
    self.targetOptions = targetOptions
    self.targetFlags = targetFlags
    self.positionals = positionals
  }

  public func targetOption(_ name: String) -> String? {
    targetOptions[name]
  }

  public func hasTargetFlag(_ name: String) -> Bool {
    targetFlags.contains(name) || safetyFlags.contains(name)
  }

  public func hasSafetyFlag(_ name: String) -> Bool {
    safetyFlags.contains(name)
  }
}
