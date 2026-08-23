import SwiftUI

@main
struct StowApp: App {
    let container = StowModelContainer.makeLocal()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
