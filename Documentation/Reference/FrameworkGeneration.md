# Framework Header Generation

Notes and Reminders use generated Clang modules with the frameworks' official
names. Their generation commands share an Objective-C declaration merger and
retain separate module configurations:

```bash
Scripts/notes-private-framework-normalize-full-dump --dump-root <dump-root> --sources-root <sources-root>
Scripts/reminderkit-normalize-full-dump --dump-root <dump-root> --sources-root <sources-root>
```

Notes generates `NotesSupport`, `NotesHTML`, `NotesShared`, `NotesUI`,
`NotesEditor`, and `NotesPreviewKit`. Reminders generates `ReminderKit` and
`ReminderKitInternal`. Each module receives an umbrella header, module map, and
linking shim. Input headers use `<dump-root>/<Module>/<Module>/*.h`.

## Versioned Inputs

Use exactly one of `--dump-root` and `--input-manifest`. A versioned manifest
follows [FrameworkInputManifest.schema.json](FrameworkInputManifest.schema.json):

```bash
Scripts/notes-private-framework-normalize-full-dump \
  --input-manifest <manifest.json> \
  --sources-root <sources-root> \
  --report <diagnostic-report.json>
```

`--sdk-root` optionally selects the validation SDK. Otherwise the generator
uses the selected Xcode macOS SDK.

Each manifest input has a unique `id`, a `dump_root` relative to the manifest
or an absolute input path, a recorded macOS version, OS build, and architecture
(`arm64` or `x86_64`). Record the extraction source, SDK version, and app version
when known. Each configured module has either:

- `presence: "present"` with a complete map of header filenames to their SHA-256
  digests; extra, missing, or changed headers are refused.
- `presence: "absent"` without headers; the module input directory must be
  absent. This describes the supplied dump, rather than proving absence of a
  framework from an OS.

Every output module needs at least one present input. A single dump does not
infer version, build, architecture, or app metadata from the generation host.

## Merge and Validation

Declarations are identified by module, class, protocol, or category; members
are identified by property name or scoped Objective-C selector. Matching
declarations are deduplicated and compatible additional members are combined.
Method argument names do not define a selector or signature. Superclass,
return/parameter type, property ownership, accessors, mutability, protocol
requirement, and selector conflicts retain their source identities and block
generation. Categories are checked against the class's effective selectors.
For comparison, explicit default getter/setter names are equivalent to their
omission, and `strong` and `retain` describe the same ownership. Source
declarations and origins remain in the output and report. Ownership semantics
follow [Clang's ARC specification](https://clang.llvm.org/docs/AutomaticReferenceCounting.html#property-declarations);
accessor defaults follow [Apple's declared property rules](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocProperties.html).
Conflicting property metadata within a single declaration also requires
reconciliation. A property and a method with the same accessor but different
object types remain conflicting; the generator does not choose a declaration
based on its position or erase the discrepancy to `id`.

The report lists each declaration and member's observed inputs and the input
header digests. `availability_basis: "observed_input_presence"` records evidence
from supplied dumps. It does not establish an Apple API introduction version.
Members excluded by import normalization are reported with their origins.
Normalized headers remain an import surface; they do not independently prove
runtime ABI or behavior of every declaration.

Before publication, the generator typechecks imports of every configured
module for each recorded architecture. Without recorded architecture metadata,
it checks the generation host's architecture. The compiler uses the selected
SDK and a macOS 13 deployment target. These checks do not prove old-OS framework
loadability, execution on Intel, or target operation behavior. Runtime
requirements and native verification remain owned by the CLI target.

## Output Ownership and Recovery

Generation prepares the complete output tree beside `sources-root`, preserving
other targets' files. Parsing, digest, conflict, or import failures preserve the
existing output group. A successful generation publishes the prepared tree
through one directory exchange, with snapshots before and after exchange to
detect concurrent edits. Run generation while builds and source edits are idle.

Generated paths and metadata must not be symlinks. Generation metadata is
stored under `<sources-root>/.framework-normalization/<profile>.json`. An
explicit `--report` destination must be outside the output tree. On a failed
exchange recovery, retain the workspace identified in the diagnostic before
manual recovery. A diagnostic report write failure after successful publication
produces a warning; the validated output group remains published.

Inputs are read-only regular files with bounded sizes. Diagnostic reports must
also be outside every input dump tree and cannot replace the input manifest or
an input header reached through a symbolic link. Boundaries are checked against
resolved ancestors even when an output or report does not yet exist. Dangling
ancestor links and links at owned generated paths are refused.

Keep local dumps, machine paths, and exploratory reports in temporary execution
state. Promote only reviewed import surfaces and portable provenance appropriate
to the repository. Normal package builds use the saved headers and do not run
class dumps or the normalizer.

## Tests

```bash
swift test --filter FrameworkNormalizationTests
```

Swift Testing uses synthetic declarations and temporary output trees. It
covers both profiles, missing inputs, signature conflicts, observed version
presence, order independence, protocol/category merging, digest validation,
compiler rejection, and output preservation. It does not access app stores or
invoke app mutations.
