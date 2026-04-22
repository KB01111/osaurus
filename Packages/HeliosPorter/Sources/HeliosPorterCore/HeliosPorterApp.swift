import Foundation

public protocol Console {
    func writeStdout(_ string: String)
    func writeStderr(_ string: String)
}

public struct StandardConsole: Console {
    public init() {}

    public func writeStdout(_ string: String) {
        print(string)
    }

    public func writeStderr(_ string: String) {
        fputs(string + "\n", stderr)
    }
}

public final class BufferedConsole: Console {
    public private(set) var stdout: [String] = []
    public private(set) var stderr: [String] = []

    public init() {}

    public func writeStdout(_ string: String) {
        stdout.append(string)
    }

    public func writeStderr(_ string: String) {
        stderr.append(string)
    }
}

public struct HeliosPorterApp {
    private let fileManager: FileManager
    private let console: Console

    public init(fileManager: FileManager = .default, console: Console = StandardConsole()) {
        self.fileManager = fileManager
        self.console = console
    }

    public func run(arguments: [String], currentDirectory: URL) -> CommandOutput {
        do {
            let repoRoot = HeliosPorterSupport.repositoryRoot(startingAt: currentDirectory, fileManager: fileManager)
            guard let command = arguments.first else {
                console.writeStdout(Self.usage)
                return CommandOutput(exitCode: 1, stdout: Self.usage, stderr: "")
            }

            switch command {
            case "help", "--help", "-h":
                console.writeStdout(Self.usage)
                return CommandOutput(exitCode: 0, stdout: Self.usage, stderr: "")
            case "scan":
                let slice = try parseSlice(from: arguments)
                let report = try PortabilityAnalyzer(repoRoot: repoRoot).analyze(slice: slice)
                let outputURL = try writePortabilityReport(report, repoRoot: repoRoot)
                let message = "Wrote \(relativePath(of: outputURL, repoRoot: repoRoot))"
                console.writeStdout(message)
                return CommandOutput(exitCode: 0, stdout: message, stderr: "")
            case "compare":
                let slice = try parseSlice(from: arguments)
                let targets = try parseTargets(from: arguments)
                let portability = try PortabilityAnalyzer(repoRoot: repoRoot).analyze(slice: slice)
                _ = try writePortabilityReport(portability, repoRoot: repoRoot)
                let comparison = FrameworkComparisonEngine().compare(slice: slice, report: portability, targets: targets)
                let outputURL = try writeComparisonReport(portability: portability, comparison: comparison, repoRoot: repoRoot)
                let message = "Wrote \(relativePath(of: outputURL, repoRoot: repoRoot))"
                console.writeStdout(message)
                return CommandOutput(exitCode: 0, stdout: message, stderr: "")
            case "scaffold":
                let slice = try parseSlice(from: arguments)
                let targets = try parseTargets(from: arguments)
                let portability = try PortabilityAnalyzer(repoRoot: repoRoot).analyze(slice: slice)
                _ = try writePortabilityReport(portability, repoRoot: repoRoot)
                let comparison = FrameworkComparisonEngine().compare(slice: slice, report: portability, targets: targets)
                _ = try writeComparisonReport(portability: portability, comparison: comparison, repoRoot: repoRoot)
                let manifest = try ScaffoldGenerator(repoRoot: repoRoot, fileManager: fileManager).scaffold(
                    slice: slice,
                    report: portability,
                    comparison: comparison,
                    targets: targets
                )
                let message = "Scaffolded \(targets.map(\.rawValue).joined(separator: ", ")) using \(manifest.tabs.count) management tabs."
                console.writeStdout(message)
                return CommandOutput(exitCode: 0, stdout: message, stderr: "")
            case "report":
                let slice: SliceDefinition = .management_settings
                let targets: [FrameworkTarget] = [.swiftcrossui, .shaft]
                let portability = try PortabilityAnalyzer(repoRoot: repoRoot).analyze(slice: slice)
                _ = try writePortabilityReport(portability, repoRoot: repoRoot)
                let comparison = FrameworkComparisonEngine().compare(slice: slice, report: portability, targets: targets)
                _ = try writeComparisonReport(portability: portability, comparison: comparison, repoRoot: repoRoot)
                let outputURL = try writeBootstrapReport(portability: portability, comparison: comparison, repoRoot: repoRoot)
                let message = "Wrote \(relativePath(of: outputURL, repoRoot: repoRoot))"
                console.writeStdout(message)
                return CommandOutput(exitCode: 0, stdout: message, stderr: "")
            default:
                throw HeliosPorterError.invalidCommand(command)
            }
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            console.writeStderr(message)
            return CommandOutput(exitCode: 1, stdout: "", stderr: message)
        }
    }

    public static let usage = """
        helios-porter scan --slice management_settings
        helios-porter compare --slice management_settings --targets swiftcrossui,shaft
        helios-porter scaffold --slice management_settings --targets swiftcrossui,shaft
        helios-porter report
        """

    private func parseSlice(from arguments: [String]) throws -> SliceDefinition {
        guard let rawValue = optionValue("--slice", arguments: arguments) else {
            throw HeliosPorterError.missingOption("--slice")
        }
        guard let slice = SliceDefinition(rawValue: rawValue) else {
            throw HeliosPorterError.invalidSlice(rawValue)
        }
        return slice
    }

    private func parseTargets(from arguments: [String]) throws -> [FrameworkTarget] {
        guard let rawValue = optionValue("--targets", arguments: arguments) else {
            throw HeliosPorterError.missingOption("--targets")
        }

        let targets = rawValue
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .compactMap(FrameworkTarget.init(rawValue:))

        guard !targets.isEmpty else {
            throw HeliosPorterError.invalidTargets(rawValue)
        }

        return targets
    }

    private func optionValue(_ option: String, arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: option), arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }

    private func writePortabilityReport(_ report: PortabilityReport, repoRoot: URL) throws -> URL {
        let outputURL = HeliosPorterSupport.reportsDirectory(repoRoot: repoRoot)
            .appendingPathComponent("\(report.slice.slug).portability.json")
        let data = try HeliosPorterSupport.makeEncoder().encode(report)
        try HeliosPorterSupport.write(data, to: outputURL, fileManager: fileManager)
        return outputURL
    }

    private func writeComparisonReport(
        portability: PortabilityReport,
        comparison: ComparisonReport,
        repoRoot: URL
    ) throws -> URL {
        let outputURL = HeliosPorterSupport.reportsDirectory(repoRoot: repoRoot)
            .appendingPathComponent("\(comparison.slice.slug).comparison.md")
        let markdown = ComparisonMarkdownRenderer().render(portability: portability, comparison: comparison)
        try HeliosPorterSupport.write(markdown, to: outputURL, fileManager: fileManager)
        return outputURL
    }

    private func writeBootstrapReport(
        portability: PortabilityReport,
        comparison: ComparisonReport,
        repoRoot: URL
    ) throws -> URL {
        let outputURL = HeliosPorterSupport.reportsDirectory(repoRoot: repoRoot)
            .appendingPathComponent("helios-bootstrap.md")
        let markdown = BootstrapReporter(repoRoot: repoRoot).render(portability: portability, comparison: comparison)
        try HeliosPorterSupport.write(markdown, to: outputURL, fileManager: fileManager)
        return outputURL
    }

    private func relativePath(of url: URL, repoRoot: URL) -> String {
        let repoPath = repoRoot.path
        let fullPath = url.path
        guard fullPath.hasPrefix(repoPath) else { return fullPath }
        return String(fullPath.dropFirst(repoPath.count + 1)).replacingOccurrences(of: "\\", with: "/")
    }
}
