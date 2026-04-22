import Foundation

public struct FrameworkComparisonEngine {
    public init() {}

    public func compare(
        slice: SliceDefinition,
        report: PortabilityReport,
        targets: [FrameworkTarget]
    ) -> ComparisonReport {
        let scores = targets.map { target in
            score(target: target, report: report)
        }

        let recommended = scores.max { lhs, rhs in
            if lhs.total == rhs.total {
                return lhs.target.rawValue > rhs.target.rawValue
            }
            return lhs.total < rhs.total
        }?.target ?? .swiftcrossui

        let recommendationReasons = [
            "The slice is dominated by portable or adapter-based SwiftUI files, which favors a SwiftUI-shaped migration path.",
            "Only `ServerView.swift` is a hard rewrite; the remaining files mainly need service adapters and Helios-owned chrome.",
            "Keep the generated `shaft` scaffold as a comparison harness while the shared Windows platform services settle.",
        ]

        return ComparisonReport(
            slice: slice,
            scores: scores,
            recommendedTarget: recommended,
            recommendationReasons: recommendationReasons
        )
    }

    private func score(target: FrameworkTarget, report: PortabilityReport) -> FrameworkScore {
        let adapterCount = report.summary.adapterNeededCount
        let rewriteCount = report.summary.rewriteCount
        let portableCount = report.summary.portableCount

        switch target {
        case .swiftcrossui:
            let criteria = [
                "SwiftUI shape fit": min(10, 8 + adapterCount / 2),
                "AppKit detachment burden": max(1, 8 - rewriteCount),
                "Windows-native affordance fit": max(1, 7 - rewriteCount),
                "Theming/layout carryover": min(10, 7 + max(1, adapterCount / 2)),
                "Expected manual rewrite cost": max(1, 9 - rewriteCount),
            ]

            return FrameworkScore(
                target: target,
                criteria: criteria,
                total: criteria.values.reduce(0, +),
                rationale: [
                    "High SwiftUI surface-area match for sidebar, header, and tab composition.",
                    "Lower manual rewrite cost for the first Helios slice.",
                    "Still needs explicit Windows adapters for clipboard, external links, and file picking.",
                ]
            )
        case .shaft:
            let criteria = [
                "SwiftUI shape fit": max(1, 7 - max(0, adapterCount - portableCount) / 4),
                "AppKit detachment burden": max(1, 8 - rewriteCount),
                "Windows-native affordance fit": min(10, 8 + rewriteCount),
                "Theming/layout carryover": max(1, 7 - adapterCount / 4),
                "Expected manual rewrite cost": max(1, 7 - adapterCount / 2 - rewriteCount),
            ]

            return FrameworkScore(
                target: target,
                criteria: criteria,
                total: criteria.values.reduce(0, +),
                rationale: [
                    "Strong Windows-native posture once the Helios shell grows beyond the first slice.",
                    "Higher manual rewrite pressure for SwiftUI-shaped management primitives.",
                    "Best kept as the parallel comparison scaffold until shared services stabilize.",
                ]
            )
        }
    }
}
