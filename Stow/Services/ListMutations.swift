import Foundation

/// Anything with a manual sort position.
protocol Orderable: AnyObject {
    var sortOrder: Int { get set }
}

extension BaseItem: Orderable {}
extension PackingItem: Orderable {}

enum ListOrdering {
    /// The sort order to assign the next appended item.
    static func nextSortOrder(after items: [any Orderable]) -> Int {
        (items.map(\.sortOrder).max() ?? -1) + 1
    }

    /// Apply a SwiftUI-style move to an already-ordered array, then reassign
    /// contiguous `sortOrder` values (0, 1, 2, …) so the new order persists.
    static func move(_ ordered: [any Orderable], fromOffsets source: IndexSet, toOffset destination: Int) {
        var reordered = ordered
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, item) in reordered.enumerated() {
            item.sortOrder = index
        }
    }
}

// MARK: - Timestamp + archive helpers

extension BaseList {
    /// Mark the list as edited now. Call after any mutation.
    func touch() { updatedAt = .now }
    func archive() { isArchived = true; touch() }
    func unarchive() { isArchived = false; touch() }
}

extension PackingList {
    /// Mark the list as edited now. Call after any mutation, including toggling
    /// an item's packed state.
    func touch() { updatedAt = .now }
    func archive() { isArchived = true; touch() }
    func unarchive() { isArchived = false; touch() }
}
