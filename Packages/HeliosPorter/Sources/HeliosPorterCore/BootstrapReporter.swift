import Foundation

public struct BootstrapReporter {
    public let repoRoot: URL

    public init(repoRoot: URL) {
        self.repoRoot = repoRoot
    }

    public func render(
        portability: PortabilityReport,
        comparison: ComparisonReport
    ) -> String {
        let blockers = blockers(from: portability)
        let scaffoldPaths = [
            "Helios/swiftcrossui",
            "Helios/shaft",
        ].filter {
            FileManager.default.fileExists(atPath: repoRoot.appendingPathComponent($0).path)
        }

        var lines: [String] = []
        lines.append("# Helios Bootstrap Report")
        lines.append("")
        lines.append("## Current Slice")
        lines.append("- Slice: \(portability.slice.displayName)")
        lines.append("- Portability mix: \(portability.summary.portableCount) portable, \(portability.summary.adapterNeededCount) adapter_needed, \(portability.summary.rewriteCount) rewrite")
        lines.append("- Recommended framework: `\(comparison.recommendedTarget.rawValue)`")
        lines.append("")
        lines.append("## Portability Inventory")
        lines.append("| File | Class | Key blockers |")
        lines.append("| --- | --- | --- |")
        for finding in portability.findings {
            lines.append("| \(finding.sourcePath) | `\(finding.classification.rawValue)` | \(finding.platformDependencies.joined(separator: ", ")) |")
        }
        lines.append("")
        lines.append("## Framework Comparison")
        lines.append("| Target | Total |")
        lines.append("| --- | ---: |")
        for score in comparison.scores {
            lines.append("| `\(score.target.rawValue)` | \(score.total) |")
        }
        lines.append("")
        lines.append("## Next Slices")
        for slice in portability.slice.fixedNextSlices {
            lines.append("- \(slice)")
        }
        lines.append("")
        lines.append("## Top Windows Blockers")
        for blocker in blockers {
            lines.append("- \(blocker)")
        }
        lines.append("")
        lines.append("## Generated Scaffolds")
        if scaffoldPaths.isEmpty {
            lines.append("- No Helios UI skeletons generated yet.")
        } else {
            for path in scaffoldPaths {
                lines.append("- \(path)")
            }
        }
        lines.append("")

        return lines.joined(separator: "\n")
    }

    private func blockers(from portability: PortabilityReport) -> [String] {
        let dependencies = Set(portability.findings.flatMap(\.platformDependencies))
        var blockers: [String] = []

        if dependencies.contains("AppKit") || dependencies.contains("NSPasteboard") || dependencies.contains("NSWorkspace") || dependencies.contains("NSOpenPanel") {
            blockers.append("Replace AppKit clipboard, shell, and picker flows in `ServerView.swift` with Windows-native platform services.")
        }

        if dependencies.contains("Osaurus singleton managers") {
            blockers.append("Rebind `ManagementView.swift` away from Osaurus singleton managers and onto Helios-owned application state.")
        }

        if dependencies.contains("Theme environment") || dependencies.contains("Manager header primitives") || dependencies.contains("SidebarNavigation") {
            blockers.append("Recreate the theme, sidebar, and header primitives as Helios-owned Windows-native chrome instead of copying the macOS shell directly.")
        }

        if blockers.isEmpty {
            blockers.append("Finalize the first Helios slice and then expand into `chat_surface`, `app_shell`, and `platform_services`.")
        }

        return blockers
    }
}
