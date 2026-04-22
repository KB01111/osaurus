import Foundation

#if canImport(Shaft)
import Shaft
#endif

@main
struct HeliosShaftApp {
    static func main() {
        #if canImport(Shaft)
        print("Wire the Shaft runtime here and point it at ../shared/management-settings.slice.json.")
        #else
        print("The Shaft dependency is not installed yet. This scaffold stays compile-safe while Helios settles the Windows runtime.")
        #endif
    }
}
