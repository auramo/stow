import SwiftUI

/// Two top-level tabs: reusable base lists and real packing lists.
struct RootView: View {
    var body: some View {
        TabView {
            PackingListsView()
                .tabItem { Label("Packing", systemImage: "suitcase.fill") }
            BaseListsView()
                .tabItem { Label("Base Lists", systemImage: "doc.text") }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(StowModelContainer.makeInMemory())
}
