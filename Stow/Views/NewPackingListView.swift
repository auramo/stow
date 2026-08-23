import SwiftUI
import SwiftData

/// Create a packing list: type a name, pick one or more base lists, and realise
/// their items (deduped) into a new, independent packing list.
struct NewPackingListView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(filter: #Predicate<BaseList> { !$0.isArchived }, sort: \BaseList.name)
    private var baseLists: [BaseList]

    @State private var name = ""
    @State private var selected: Set<PersistentIdentifier> = []

    private var chosen: [BaseList] {
        baseLists.filter { selected.contains($0.persistentModelID) }
    }

    private var mergedCount: Int {
        PackingListFactory.mergedLabels(fromGroups: chosen.map { $0.orderedItems.map(\.label) }).count
    }

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Packing list name", text: $name)
                }

                Section {
                    if baseLists.isEmpty {
                        Text("No base lists yet — you can still create a blank list and add items by hand.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(baseLists) { list in
                        Button { toggle(list) } label: {
                            HStack {
                                Image(systemName: selected.contains(list.persistentModelID) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selected.contains(list.persistentModelID) ? Color.accentColor : .secondary)
                                Text(list.name.isEmpty ? String(localized: "Untitled") : list.name)
                                Spacer()
                                Text("\(list.orderedItems.count)").foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Base lists (optional)")
                } footer: {
                    Text("Leave all unselected to start with a blank list.")
                }

                if !selected.isEmpty {
                    Section {
                        Text("\(mergedCount) items after merging duplicates")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("New Packing List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { create() }.disabled(!canCreate)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func toggle(_ list: BaseList) {
        let id = list.persistentModelID
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
    }

    private func create() {
        PackingListFactory.makePackingList(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            from: chosen,
            in: context
        )
        dismiss()
    }
}
