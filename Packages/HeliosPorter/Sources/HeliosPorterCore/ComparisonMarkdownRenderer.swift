import Foundation

public struct ComparisonMarkdownRenderer {
    public init() {}

    public func render(portability: PortabilityReport, comparison: ComparisonReport) -> String {
        var lines: [String] = []
        lines.append("# \(portability.slice.displayName) Framework Comparison")
        lines.append("")
        lines.append("## Slice Summary")
        lines.append("- Slice: \(portability.slice.displayName)")
        lines.append("- Files analyzed: \(portability.summary.totalFiles)")
        lines.append("- Portable: \(portability.summary.portableCount)")
        lines.append("- Adapter needed: \(portability.summary.adapterNeededCount)")
        lines.append("- Rewrite: \(portability.summary.rewriteCount)")
        lines.append("")
        lines.append("## Criteria Scores")
        lines.append("| Target | SwiftUI shape fit | AppKit detachment burden | Windows-native affordance fit | Theming/layout carryover | Expected manual rewrite cost | Total |")
        lines.append("| --- | ---: | ---: | ---: | ---: | ---: | ---: |")

        for score in comparison.scores {
            lines.append(
                "| \(score.target.rawValue) | \(score.criteria["SwiftUI shape fit"] ?? 0) | \(score.criteria["AppKit detachment burden"] ?? 0) | \(score.criteria["Windows-native affordance fit"] ?? 0) | \(score.criteria["Theming/layout carryover"] ?? 0) | \(score.criteria["Expected manual rewrite cost"] ?? 0) | \(score.total) |"
            )
        }

        lines.append("")
        lines.append("## Recommendation")
        lines.append("**Recommended target:** `\(comparison.recommendedTarget.rawValue)`")
        lines.append("")
        for reason in comparison.recommendationReasons {
            lines.append("- \(reason)")
        }
        lines.append("")
        lines.append("## Per-Target Notes")

        for score in comparison.scores {
            lines.append("### `\(score.target.rawValue)`")
            for reason in score.rationale {
                lines.append("- \(reason)")
            }
            lines.append("")
        }

        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
    }
}
