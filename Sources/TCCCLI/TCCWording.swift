enum TCCWording {
  static func readOnlyRejectsDryRun() -> String {
    "Read-only TCC commands do not accept `--dry-run`."
  }

  static func readOnlyRejectsRiskFlags() -> String {
    "Read-only TCC commands do not accept risk flags."
  }

  static func publicPreflightRouteUnavailable() -> String {
    "This TCC service has no apple-cli public preflight route yet."
  }

  static func publicRequestRouteUnavailable() -> String {
    "This TCC service has no apple-cli public request route yet."
  }

  static func promptRequestRequiresAllowFlag() -> String {
    "TCC prompt requests require `--allow-tcc-prompt`."
  }

  static func accessRequestDoesNotUseDryRun() -> String {
    "`access request` opens system permission UI and does not use `--dry-run`."
  }

  static func resetRequiresAllowFlag() -> String {
    "Official TCC reset requires `--allow-tcc-reset`."
  }

  static func resetDoesNotUseDryRun() -> String {
    "`tccutil reset` is gated by `--allow-tcc-reset`; it does not use `--dry-run`."
  }

  static func tccutilResetFailed() -> String {
    "tccutil reset failed."
  }

  static func privateDatabaseScopeRequired() -> String {
    "Private TCC database writes require `--scope user` or `--scope system`."
  }

  static func privateDatabaseWritesRequireAllowFlag() -> String {
    "Private TCC database writes require `--allow-private-tcc-db-write`."
  }

  static func unknownRawServiceWriteRequiresAllowFlag() -> String {
    "Writing an unknown raw TCC service requires `--allow-unknown-tcc-service`."
  }

  static func schemaDigestChangedBeforeMutation() -> String {
    "TCC schema digest changed before mutation."
  }

  static func schemaColumnsChangedBeforeMutation() -> String {
    "TCC schema columns changed before mutation."
  }

  static func currentRowChangedBeforeMutation() -> String {
    "TCC current row changed before mutation."
  }

  static func databaseOpenReadWriteFailed() -> String {
    "TCC database could not be opened read-write."
  }

  static func databaseNotReadableByProcess() -> String {
    "TCC database is not readable by this process."
  }

  static func databaseIsReadable() -> String {
    "TCC database is readable."
  }

  static func databaseIsNotReadable() -> String {
    "TCC database is not readable."
  }

  static func databaseSchemaNotRecognized() -> String {
    "TCC database access table schema is not recognized."
  }

  static func databaseHasNoRecognizedColumns() -> String {
    "TCC database access table has no recognized columns."
  }

  static func databaseCannotAcceptServiceClientInserts() -> String {
    "TCC access schema cannot accept service/client inserts."
  }

  static func databaseHasNoAuthorizationColumn() -> String {
    "TCC access schema has no supported authorization column."
  }

  static func privateFrameworkWritesRequireAllowFlag() -> String {
    "Private TCC.framework writes require `--allow-private-tcc-framework-write`."
  }

  static func mutationRequiresAllowFlag() -> String {
    "This TCC mutation requires the target-specific `--allow-*` flag."
  }

  static func privateFrameworkBackendUnavailable() -> String {
    "Private TCC.framework backend is unavailable."
  }

  static func privateFrameworkBundleCouldNotBeCreated() -> String {
    "Bundle could not be created for private TCC.framework call."
  }

  static func privateFrameworkCouldNotBeOpened() -> String {
    "Private TCC.framework could not be opened."
  }

  static func privateFrameworkSymbolCouldNotBeResolved() -> String {
    "Private TCC.framework symbol could not be resolved."
  }

  static func privateFrameworkAvailable() -> String {
    "TCC.framework private backend available"
  }

  static func privateFrameworkUnavailable() -> String {
    "TCC.framework private backend unavailable"
  }

  static func serviceIsInCatalog() -> String {
    "TCC service is in the apple-cli catalog."
  }

  static func rawServiceIsNotInCatalog() -> String {
    "Raw service is not in the apple-cli catalog."
  }

  static func clientIdentityParsed() -> String {
    "TCC client identity parsed."
  }

  static func targetMappingResolved() -> String {
    "Target TCC mapping resolved."
  }
}
