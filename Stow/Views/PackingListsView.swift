import SwiftUI
import SwiftData

/// Browse, create, archive, and delete real packing lists.
struct PackingListsView: View {
    @Environment(\.modelContext) private var context

    @Query(filter: #Predicate<PackingList> { !$0.isArchived }, sort: \PackingList.updatedAt, order: .reverse)
    private var active: [PackingList]
    @Query(filter: #Predicate<PackingList> { $0.isArchived }, sort: \PackingList.updatedAt, order: .reverse)
    private var archived: [PackingList]

    @State private var showingNew = false
    @State private var showArchived = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(active) { list in
                        NavigationLink(value: list) { PackingListRow(list: list) }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) { context.delete(list) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button { list.archive() } label: {
                                    Label("Archive", systemImage: "archivebox")
                                }
                                .tint(.orange)
                            }
                    }
                }

                if showArchived && !archived.isEmpty {
                    Section("Archived") {
                        ForEach(archived) { list in
                            NavigationLink(value: list) { PackingListRow(list: list) }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) { context.delete(list) } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    Button { list.unarchive() } label: {
                                        Label("Unarchive", systemImage: "arrow.uturn.backward")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Packing")
            .navigationDestination(for: PackingList.self) { PackingListDetailView(list: $0) }
            .toolbar {
                if !archived.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showArchived.toggle()
                        } label: {
                            Label(showArchived ? "Hide Archived" : "Show Archived",
                                  systemImage: showArchived ? "archivebox.fill" : "archivebox")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingNew = true } label: { Label("New", systemImage: "plus") }
                }
            }
            .overlay {
                if active.isEmpty && archived.isEmpty {
                    ContentUnavailableView("No Packing Lists", systemImage: "suitcase",
                                           description: Text("Create one from your base lists."))
                }
            }
            .sheet(isPresented: $showingNew) {
                NewPackingListView()
            }
        }
    }
}

private struct PackingListRow: View {
    let list: PackingList
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(list.name.isEmpty ? String(localized: "Untitled") : list.name)
            if list.totalCount > 0 {
                ProgressView(value: Double(list.packedCount), total: Double(list.totalCount)) {
                    Text("\(list.packedCount) of \(list.totalCount) packed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Empty").font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
