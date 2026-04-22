import Foundation

let heliosSharedManifestPath = "../../shared/management-settings.slice.json"

enum HeliosManagementTab: String, CaseIterable {
    case models
    case providers
    case agents
    case plugins
    case sandbox
    case tools
    case skills
    case commands
    case memory
    case schedules
    case watchers
    case voice
    case themes
    case insights
    case server
    case permissions
    case identity
    case settings
}

struct HeliosServerReadAction {
    let title: String
    let perform: () -> Void
}

struct HeliosServerOverviewModel {
    let status: String
    let localURL: String
    let readActions: [HeliosServerReadAction]
}

let heliosServerOverview = HeliosServerOverviewModel(
    status: PlatformServices.placeholder.server.currentStatus(),
    localURL: PlatformServices.placeholder.server.localServerURL(),
    readActions: [
        HeliosServerReadAction(title: "Copy Local URL") {
            PlatformServices.placeholder.clipboard.copy(PlatformServices.placeholder.server.localServerURL())
        },
        HeliosServerReadAction(title: "Open Documentation") {
            PlatformServices.placeholder.links.open("https://docs.osaurus.ai/")
        },
        HeliosServerReadAction(title: "Open Discord") {
            PlatformServices.placeholder.links.open("https://discord.gg/dinoki")
        },
        HeliosServerReadAction(title: "Show API Reference") {
            PlatformServices.placeholder.navigation.showAPIReference()
        },
    ]
)

// TODO(Helios): Replace NSOpenPanel-driven endpoint tester flows with a Windows file picker service.
// TODO(Helios): Route clipboard writes through ClipboardService instead of NSPasteboard.
// TODO(Helios): Route external links and file launches through ExternalLinkService instead of NSWorkspace.
// TODO(Helios): Rebuild the interactive endpoint tester incrementally once the Windows shell owns the server diagnostics flow.

#if canImport(SwiftCrossUI)
import SwiftCrossUI

struct ManagementSettingsRootView {
    let services: PlatformServices = .placeholder
    let tabs = HeliosManagementTab.allCases

    // This is a framework-shaped bootstrap rather than a finished implementation.
    // It preserves the Management/Settings information architecture while Helios decides
    // how much of the final Windows shell should be owned by SwiftCrossUI.
}
#endif
