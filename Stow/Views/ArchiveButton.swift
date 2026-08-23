import SwiftUI

/// Toolbar toggle label: an archive-box icon plus a small grey "Archive" caption.
/// Uses a dedicated key so Finnish reads the noun "Arkisto" (not the verb "Arkistoi").
struct ArchiveToggleLabel: View {
    let isOn: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isOn ? "archivebox.fill" : "archivebox")
            Text(String(localized: "archive_toggle", defaultValue: "Archive"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

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
