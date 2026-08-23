import SwiftUI
import SwiftData

/// Edit a base list's label-only items: add, rename, delete, reorder.
struct BaseListDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var list: BaseList
    @State private var newItem = ""

    var body: some View {
        List {
            Section {
                ForEach(list.orderedItems) { item in
                    @Bindable var item = item
                    TextField("Item", text: $item.label)
                        .onChange(of: item.label) { list.touch() }
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
        .navigationTitle(list.name.isEmpty ? String(localized: "Untitled") : list.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { EditButton() }
    }

    private func add() {
        let label = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !label.isEmpty else { return }
        let item = BaseItem(label: label, sortOrder: ListOrdering.nextSortOrder(after: list.orderedItems))
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
