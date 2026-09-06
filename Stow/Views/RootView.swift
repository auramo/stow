import SwiftUI

/// Two top-level tabs: reusable base lists and real packing lists, plus a
/// floating "new" button beside the tab bar that creates whichever kind of list
/// the current tab shows.
struct RootView: View {
    private enum TabSelection {
        case packing, base
    }

    @State private var selection: TabSelection = .packing
    @State private var packingPath = NavigationPath()
    @State private var basePath = NavigationPath()
    @State private var showingNewPacking = false
    @State private var showingNewBase = false

    /// Creating a list only makes sense at the top level of a tab, not once
    /// you've drilled into one.
    private var showsNewButton: Bool {
        switch selection {
        case .packing: packingPath.isEmpty
        case .base: basePath.isEmpty
        }
    }

    var body: some View {
        TabView(selection: $selection) {
            PackingListsView(path: $packingPath, showingNew: $showingNewPacking)
                .tabItem { Label("Packing", systemImage: "suitcase.fill") }
                .tag(TabSelection.packing)
            BaseListsView(path: $basePath, showingNew: $showingNewBase)
                .tabItem { Label("Base Lists", systemImage: "doc.text") }
                .tag(TabSelection.base)
        }
        .overlay(alignment: .bottomTrailing) {
            if showsNewButton {
                NewListButton(action: startNewList)
            }
        }
    }

    private func startNewList() {
        switch selection {
        case .packing: showingNewPacking = true
        case .base: showingNewBase = true
        }
    }
}

/// Round "+" floating at the trailing edge of the tab bar. On iOS 26 it sits
/// beside the tab capsule and matches its glass; older systems draw a full-width
/// tab bar, so there it floats above the bar instead.
private struct NewListButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .frame(width: 52, height: 52)
        }
        .accessibilityLabel(Text("New"))
        .modifier(FloatingButtonBackground())
    }
}

private struct FloatingButtonBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular, in: .circle)
                .padding(.trailing, 16)
                // Tuned so the circle's centre lines up with the tab capsule's.
                .padding(.bottom, 2)
        } else {
            content
                .background(.thinMaterial, in: .circle)
                .shadow(radius: 6, y: 2)
                .padding(.trailing, 16)
                .padding(.bottom, 24)
        }
    }
}

#Preview {
    RootView()
        .modelContainer(StowModelContainer.makeInMemory())
}
