import Darwin
import Foundation
import Testing
import Utility

@Suite
struct SubprocessTests {
  @Test func synchronousInputAndOutputAreDrainedTogetherWithoutChangingBytes() throws {
    let input = Data((0..<262_144).map { UInt8(truncatingIfNeeded: $0) })
    let result = try CLISubprocess.runBytes(
      .path("/bin/sh"), arguments: ["-c", "cat; printf 'diagnostic' >&2"], input: input,
      timeoutSeconds: 3, outputLimit: input.count)
    #expect(result.exitCode == 0)
    #expect(result.stdout == input)
    #expect(result.stderr == Data("diagnostic".utf8))
  }

  @Test func timeoutIncludesAChildThatDoesNotReadItsInput() throws {
    do {
      _ = try CLISubprocess.runBytes(
        .path("/bin/sh"), arguments: ["-c", "exec sleep 30"],
        input: Data(repeating: 1, count: 262_144), timeoutSeconds: 1)
      Issue.record("Expected an input-blocked child to time out.")
    } catch let error as CLIError {
      #expect(error.code == .timeout)
    }
  }

  @Test func childClosingInputDoesNotSignalTheParent() throws {
    let result = try CLISubprocess.runBytes(
      .path("/bin/sh"), arguments: ["-c", "exec 0<&-; printf 'closed'"],
      input: Data(repeating: 1, count: 262_144), timeoutSeconds: 2)
    #expect(result.exitCode == 0)
    #expect(result.stdout == Data("closed".utf8))
  }

  @Test func synchronousCallsCompleteOnSaturatedCooperativeExecutor() async throws {
    let results = try await withThrowingTaskGroup(of: CLISubprocessResult.self) { group in
      for index in 0..<64 {
        group.addTask {
          try CLISubprocess.run(.path("/bin/echo"), arguments: ["\(index)"], timeoutSeconds: 3)
        }
      }
      var results: [CLISubprocessResult] = []
      for try await result in group { results.append(result) }
      return results
    }
    #expect(results.count == 64)
    #expect(results.allSatisfy { $0.exitCode == 0 && $0.stderr.isEmpty })
    #expect(Set(results.map { $0.stdout.trimmingCharacters(in: .newlines) }).count == 64)
  }

  @Test func asynchronousCallsCompleteConcurrently() async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
      for index in 0..<32 {
        group.addTask {
          let result = try await CLISubprocess.runAsync(.name("echo"), arguments: ["\(index)"])
          #expect(result.stdout == "\(index)\n")
          #expect(result.exitCode == 0)
        }
      }
      try await group.waitForAll()
    }
  }

  @Test(arguments: [false, true])
  func drainsBothPipesBeyondTheirCapacity(asynchronous: Bool) async throws {
    let script = "i=0; while [ $i -lt 12000 ]; do printf 'abcdefghijklmnop'; printf 'qrstuvwxyzABCDEF' >&2; i=$((i+1)); done"
    let result = try await runShell(script, asynchronous: asynchronous, limit: 200_000)
    #expect(result.stdout == String(repeating: "abcdefghijklmnop", count: 12_000))
    #expect(result.stderr == String(repeating: "qrstuvwxyzABCDEF", count: 12_000))
    #expect(result.exitCode == 0)
  }

  @Test(arguments: [false, true])
  func preservesLiteralArgumentsAndNonzeroExit(asynchronous: Bool) async throws {
    let arguments = ["-c", "printf '%s\\n' \"$1\"; printf 'problem' >&2; exit 17", "fixture", "$HOME;$(echo secret) * a b"]
    let result = asynchronous
      ? try await CLISubprocess.runAsync(.path("/bin/sh"), arguments: arguments)
      : try CLISubprocess.run(.path("/bin/sh"), arguments: arguments)
    #expect(result.exitCode == 17)
    #expect(result.stdout == "$HOME;$(echo secret) * a b\n")
    #expect(result.stderr == "problem")
  }

  @Test(arguments: [false, true])
  func preservesSignalExitStatus(asynchronous: Bool) async throws {
    let result = try await runShell("kill -TERM $$", asynchronous: asynchronous)
    #expect(result.exitCode == 128 + SIGTERM)
  }

  @Test(arguments: [false, true])
  func acceptsExactLimitAndRejectsOverflow(asynchronous: Bool) async throws {
    let exact = try await runShell("printf 'abcd'; printf 'efgh' >&2", asynchronous: asynchronous, limit: 4)
    #expect(exact.stdout == "abcd" && exact.stderr == "efgh")
    let empty = try await runShell("exit 0", asynchronous: asynchronous, limit: 0)
    #expect(empty.stdout.isEmpty && empty.stderr.isEmpty)
    for script in ["printf 'abcde'", "printf 'abcde' >&2"] {
      do {
        _ = try await runShell(script, asynchronous: asynchronous, limit: 4)
        Issue.record("Expected output overflow.")
      } catch let error as CLIError {
        #expect(error.code == .backendUnavailable)
        #expect(error.details["output_limit"] == "4")
      }
    }
    do {
      _ = try await runShell("printf 'x'", asynchronous: asynchronous, limit: 0)
      Issue.record("Expected zero-limit overflow.")
    } catch let error as CLIError { #expect(error.code == .backendUnavailable) }
  }

  @Test(arguments: [false, true])
  func rejectsInvalidParametersBeforeLaunch(asynchronous: Bool) async throws {
    for timeout in [0, -1, Int.max] {
      do {
        _ = try await runShell("exit 0", asynchronous: asynchronous, timeout: timeout)
        Issue.record("Expected invalid duration.")
      } catch let error as CLIError { #expect(error.code == .validationError) }
    }
    do {
      _ = try await runShell("exit 0", asynchronous: asynchronous, limit: -1)
      Issue.record("Expected invalid output limit.")
    } catch let error as CLIError { #expect(error.code == .validationError) }
    do {
      _ = asynchronous
        ? try await CLISubprocess.runAsync(.path("/apple-cli-fixture-missing-executable"), arguments: [])
        : try CLISubprocess.run(.path("/apple-cli-fixture-missing-executable"), arguments: [])
      Issue.record("Expected missing executable.")
    } catch {}
  }

  @Test(arguments: [false, true])
  func timeoutKillsAndReapsChildIgnoringTerminate(asynchronous: Bool) async throws {
    let directory = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }
    let pidFile = directory.appendingPathComponent("pid")
    let arguments = ["-c", "trap '' TERM; printf '%s' $$ > \"$1\"; while :; do sleep 0.1; done", "fixture", pidFile.path]
    let start = ContinuousClock.now
    do {
      _ = asynchronous
        ? try await CLISubprocess.runAsync(.path("/bin/sh"), arguments: arguments, timeoutSeconds: 1)
        : try CLISubprocess.run(.path("/bin/sh"), arguments: arguments, timeoutSeconds: 1)
      Issue.record("Expected timeout.")
    } catch let error as CLIError { #expect(error.code == .timeout) }
    #expect(start.duration(to: .now) < cleanupTimeLimit)
    let pid = try #require(Int32(String(contentsOf: pidFile, encoding: .utf8)))
    #expect(kill(pid, 0) == -1 && errno == ESRCH)
  }

  @Test(arguments: [false, true])
  func deadlineIncludesProcessLifetimeAfterPipesClose(asynchronous: Bool) async throws {
    let start = ContinuousClock.now
    do {
      _ = try await runShell("exec 1>&- 2>&-; sleep 30", asynchronous: asynchronous, timeout: 1)
      Issue.record("Expected lifetime timeout.")
    } catch let error as CLIError { #expect(error.code == .timeout) }
    #expect(start.duration(to: .now) < cleanupTimeLimit)
  }

  @Test(arguments: [false, true])
  func inheritedWriterDoesNotKeepExitedChildOpen(asynchronous: Bool) async throws {
    let start = ContinuousClock.now
    do {
      _ = try await runShell("(trap '' TERM; sleep 30) & exit 0", asynchronous: asynchronous)
      Issue.record("Expected incomplete drainage error.")
    } catch let error as CLIError { #expect(error.code == .backendUnavailable) }
    #expect(start.duration(to: .now) < cleanupTimeLimit)
  }

  @Test func cancellationPropagatesAndReapsChild() async throws {
    let directory = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }
    let pidFile = directory.appendingPathComponent("pid")
    let task = Task {
      try await CLISubprocess.runAsync(.path("/bin/sh"), arguments: [
        "-c", "printf '%s' $$ > \"$1\"; sleep 30", "fixture", pidFile.path,
      ])
    }
    defer { task.cancel() }
    for _ in 0..<100 where !FileManager.default.fileExists(atPath: pidFile.path) {
      try await Task.sleep(for: .milliseconds(20))
    }
    let pid = try #require(Int32(String(contentsOf: pidFile, encoding: .utf8)))
    task.cancel()
    do {
      _ = try await task.value
      Issue.record("Expected cancellation.")
    } catch is CancellationError {}
    #expect(kill(pid, 0) == -1 && errno == ESRCH)
    let subsequent = try await CLISubprocess.runAsync(.name("echo"), arguments: ["after-cancel"])
    #expect(subsequent.stdout == "after-cancel\n")
  }

  @Test(arguments: [false, true])
  func escapedWriterCannotBlockReaderCleanup(asynchronous: Bool) async throws {
    let directory = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }
    let fixture = try #require(Bundle.module.resourceURL)
      .appendingPathComponent("Fixtures/Subprocess/retained-writer.c")
    let executable = directory.appendingPathComponent("retained-writer")
    let compile = try CLISubprocess.run(.path("/usr/bin/xcrun"), arguments: [
      "clang", fixture.path, "-o", executable.path,
    ], timeoutSeconds: 30)
    #expect(compile.exitCode == 0)
    let pidFile = directory.appendingPathComponent("pid")
    defer {
      if let text = try? String(contentsOf: pidFile, encoding: .utf8), let pid = Int32(text) {
        _ = kill(pid, SIGKILL)
      }
    }
    let start = ContinuousClock.now
    do {
      _ = asynchronous
        ? try await CLISubprocess.runAsync(.path(executable.path), arguments: [pidFile.path])
        : try CLISubprocess.run(.path(executable.path), arguments: [pidFile.path])
      Issue.record("Expected incomplete drainage error.")
    } catch let error as CLIError { #expect(error.code == .backendUnavailable) }
    #expect(start.duration(to: .now) < cleanupTimeLimit)
  }
}

// Includes executor contention and SDK spawn/reap time; remains below the
// fixtures' 30-second lifetime so natural exit cannot satisfy cleanup checks.
private let cleanupTimeLimit: Duration = .seconds(10)

private func runShell(
  _ script: String, asynchronous: Bool, timeout: Int? = nil, limit: Int = 1_048_576
) async throws -> CLISubprocessResult {
  if asynchronous {
    return try await CLISubprocess.runAsync(.path("/bin/sh"), arguments: ["-c", script],
      timeoutSeconds: timeout, outputLimit: limit)
  }
  return try CLISubprocess.run(.path("/bin/sh"), arguments: ["-c", script],
    timeoutSeconds: timeout, outputLimit: limit)
}

private func temporaryDirectory() throws -> URL {
  let directory = FileManager.default.temporaryDirectory.appendingPathComponent("apple-cli-subprocess-\(UUID().uuidString)")
  try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  return directory
}
