import SwiftUI

@main
struct StowApp: App {
    // Flip to `true` once the app is enrolled in the Apple Developer Program and
    // the iCloud capability is in place — see `StowModelContainer`.
    let container = StowModelContainer.makeStore(syncsWithCloudKit: false)

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
