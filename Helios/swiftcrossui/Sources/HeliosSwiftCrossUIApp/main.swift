import Foundation

#if canImport(SwiftCrossUI)
import SwiftCrossUI
#endif

@main
struct HeliosSwiftCrossUIApp {
    static func main() {
        #if canImport(SwiftCrossUI)
        print("Wire the SwiftCrossUI runtime here and point it at ../shared/management-settings.slice.json.")
        #else
        print("The SwiftCrossUI dependency is not installed yet. This scaffold stays compile-safe while Helios settles the Windows runtime.")
        #endif
    }
}
