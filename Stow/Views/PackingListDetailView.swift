import SwiftUI
import SwiftData

/// Check off, add, rename, delete, and reorder items in a packing list.
struct PackingListDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var list: PackingList
    @State private var newItem = ""

    var body: some View {
        List {
            Section {
                ForEach(list.orderedItems) { item in
                    PackingItemRow(item: item) { list.touch() }
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }

            Section {
                HStack {
                    TextField("Add item", text: $newItem)
                        .onSubmit(add)
                    Button(action: add) { Image(systemName: "plus.circle.fill") }
                        .disabled(newItem.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .navigationTitle(list.name.isEmpty ? "Untitled" : list.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { EditButton() }
    }

    private func add() {
        let label = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !label.isEmpty else { return }
        let item = PackingItem(label: label, sortOrder: ListOrdering.nextSortOrder(after: list.orderedItems))
        context.insert(item)
        item.list = list
        list.touch()
        newItem = ""
    }

    private func delete(at offsets: IndexSet) {
        let ordered = list.orderedItems
        for index in offsets { context.delete(ordered[index]) }
        list.touch()
    }

    private func move(from source: IndexSet, to destination: Int) {
        ListOrdering.move(list.orderedItems, fromOffsets: source, toOffset: destination)
        list.touch()
    }
}

private struct PackingItemRow: View {
    @Bindable var item: PackingItem
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button {
                item.isPacked.toggle()
                onToggle()
            } label: {
                Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isPacked ? .green : .secondary)
            }
            .buttonStyle(.plain)

            TextField("Item", text: $item.label)
                .strikethrough(item.isPacked)
                .foregroundStyle(item.isPacked ? .secondary : .primary)
        }
    }
}
