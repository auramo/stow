import SwiftUI
import SwiftData

/// Browse, create, archive, and delete base (template) lists.
struct BaseListsView: View {
    @Environment(\.modelContext) private var context

    @Query(filter: #Predicate<BaseList> { !$0.isArchived }, sort: \BaseList.updatedAt, order: .reverse)
    private var active: [BaseList]
    @Query(filter: #Predicate<BaseList> { $0.isArchived }, sort: \BaseList.updatedAt, order: .reverse)
    private var archived: [BaseList]

    @State private var showingNew = false
    @State private var newName = ""
    @State private var showArchived = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(active) { list in
                        NavigationLink(value: list) { BaseListRow(list: list) }
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
                            NavigationLink(value: list) { BaseListRow(list: list) }
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
            .navigationTitle("Base Lists")
            .navigationDestination(for: BaseList.self) { BaseListDetailView(list: $0) }
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
                    Button { newName = ""; showingNew = true } label: { Label("New", systemImage: "plus") }
                }
            }
            .overlay {
                if active.isEmpty && archived.isEmpty {
                    ContentUnavailableView("No Base Lists", systemImage: "doc.text",
                                           description: Text("Create a reusable template you can pack from."))
                }
            }
            .alert("New Base List", isPresented: $showingNew) {
                TextField("Name", text: $newName)
                Button("Create") { createList() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func createList() {
        let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        context.insert(BaseList(name: name))
    }
}

private struct BaseListRow: View {
    let list: BaseList
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(list.name.isEmpty ? String(localized: "Untitled") : list.name)
            Text("\(list.orderedItems.count) items")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
