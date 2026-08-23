import SwiftUI
import SwiftData
import UIKit

/// Edit a base list's label-only items: add, rename, delete, reorder.
struct BaseListDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
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
                Button(action: pasteItems) {
                    Label("Paste lines from clipboard", systemImage: "doc.on.clipboard")
                }
            }

            Section {
                ArchiveButton(isArchived: list.isArchived) {
                    if list.isArchived { list.unarchive() } else { list.archive() }
                    dismiss()
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

    /// Add one item per non-blank line of the clipboard text.
    private func pasteItems() {
        guard let text = UIPasteboard.general.string else { return }
        let labels = ClipboardImport.itemLabels(from: text)
        guard !labels.isEmpty else { return }
        var order = ListOrdering.nextSortOrder(after: list.orderedItems)
        for label in labels {
            let item = BaseItem(label: label, sortOrder: order)
            context.insert(item)
            item.list = list
            order += 1
        }
        list.touch()
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
