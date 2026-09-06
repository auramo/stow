import SwiftUI
import SwiftData
import UIKit

/// Check off, add, rename, delete, and reorder items in a packing list.
struct PackingListDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var list: PackingList
    @State private var newItem = ""
    @State private var showingNewBaseList = false
    @State private var baseListName = ""

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
                Button(action: pasteItems) {
                    Label("Paste lines from clipboard", systemImage: "doc.on.clipboard")
                }
            }

            Section {
                ArchiveButton(isArchived: list.isArchived) {
                    if list.isArchived { list.unarchive() } else { list.archive() }
                    dismiss()
                }
                Button {
                    baseListName = list.name
                    showingNewBaseList = true
                } label: {
                    Label("Make this a base list", systemImage: "doc.text")
                }
            }
        }
        .navigationTitle(list.name.isEmpty ? String(localized: "Untitled") : list.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { EditButton() }
        .alert("Make this a base list", isPresented: $showingNewBaseList) {
            TextField("Name", text: $baseListName)
            Button("Create") { makeBaseList() }
            Button("Cancel", role: .cancel) {}
        }
    }

    /// Capture this packing list's items as a reusable base list.
    private func makeBaseList() {
        let name = baseListName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        BaseListFactory.makeBaseList(name: name, from: list, in: context)
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

    /// Add one item per non-blank line of the clipboard text (all unpacked).
    private func pasteItems() {
        guard let text = UIPasteboard.general.string else { return }
        let labels = ClipboardImport.itemLabels(from: text)
        guard !labels.isEmpty else { return }
        var order = ListOrdering.nextSortOrder(after: list.orderedItems)
        for label in labels {
            let item = PackingItem(label: label, isPacked: false, sortOrder: order)
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
