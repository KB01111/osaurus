import Foundation

public enum PortabilityClass: String, Codable, CaseIterable {
    case portable
    case adapter_needed
    case rewrite
}

public enum FrameworkTarget: String, Codable, CaseIterable {
    case swiftcrossui
    case shaft
}

public enum SliceDefinition: String, Codable, CaseIterable {
    case management_settings

    public var displayName: String {
        switch self {
        case .management_settings:
            return "Management/Settings"
        }
    }

    public var slug: String { rawValue.replacingOccurrences(of: "_", with: "-") }

    public var sourcePaths: [String] {
        switch self {
        case .management_settings:
            return [
                "Packages/OsaurusCore/Views/Management/ManagementView.swift",
                "Packages/OsaurusCore/Models/Configuration/ManagementTab.swift",
                "Packages/OsaurusCore/Views/Settings/ServerView.swift",
                "Packages/OsaurusCore/Views/Management/SidebarNavigation.swift",
                "Packages/OsaurusCore/Views/Management/ManagerHeader.swift",
                "Packages/OsaurusCore/Views/Management/SharedSidebarComponents.swift",
                "Packages/OsaurusCore/Views/Common/AnimatedTabSelector.swift",
            ]
        }
    }

    public var serviceInterfaces: [String] {
        [
            "ClipboardService",
            "ExternalLinkService",
            "ServerControlService",
            "SettingsNavigationService",
        ]
    }

    public var fixedNextSlices: [String] {
        ["chat_surface", "app_shell", "platform_services"]
    }
}

public struct PortabilityFinding: Codable, Equatable {
    public let sourcePath: String
    public let symbols: [String]
    public let classification: PortabilityClass
    public let reasons: [String]
    public let platformDependencies: [String]
    public let recommendedTargets: [FrameworkTarget]

    enum CodingKeys: String, CodingKey {
        case sourcePath
        case symbols
        case classification = "class"
        case reasons
        case platformDependencies
        case recommendedTargets
    }
}

public struct PortabilitySummary: Codable, Equatable {
    public let totalFiles: Int
    public let portableCount: Int
    public let adapterNeededCount: Int
    public let rewriteCount: Int
}

public struct PortabilityReport: Codable, Equatable {
    public let slice: SliceDefinition
    public let findings: [PortabilityFinding]
    public let summary: PortabilitySummary
}

public struct FrameworkScore: Equatable {
    public let target: FrameworkTarget
    public let criteria: [String: Int]
    public let total: Int
    public let rationale: [String]
}

public struct ComparisonReport: Equatable {
    public let slice: SliceDefinition
    public let scores: [FrameworkScore]
    public let recommendedTarget: FrameworkTarget
    public let recommendationReasons: [String]
}

public struct HeliosSliceManifest: Codable, Equatable {
    public let slice: SliceDefinition
    public let tabs: [String]
    public let serviceInterfaces: [String]
    public let sourcePaths: [String]
    public let todoMarkers: [String]
}

public struct CommandOutput: Equatable {
    public let exitCode: Int32
    public let stdout: String
    public let stderr: String
}

public enum HeliosPorterError: LocalizedError, Equatable {
    case invalidCommand(String)
    case missingOption(String)
    case invalidSlice(String)
    case invalidTargets(String)
    case sourceFileMissing(String)

    public var errorDescription: String? {
        switch self {
        case .invalidCommand(let command):
            return "Unknown command '\(command)'."
        case .missingOption(let option):
            return "Missing required option \(option)."
        case .invalidSlice(let value):
            return "Unsupported slice '\(value)'."
        case .invalidTargets(let value):
            return "Unsupported target list '\(value)'. Expected a comma-separated list using swiftcrossui and/or shaft."
        case .sourceFileMissing(let relativePath):
            return "Missing source file '\(relativePath)' in the repository root."
        }
    }
}
