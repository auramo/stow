import SwiftUI

/// Bottom-of-detail action: archive an active list, or unarchive an archived one.
struct ArchiveButton: View {
    let isArchived: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isArchived {
                Label("Unarchive", systemImage: "arrow.uturn.backward")
            } else {
                Label("Archive", systemImage: "archivebox")
            }
        }
        .foregroundStyle(isArchived ? Color.accentColor : Color.orange)
    }
}
