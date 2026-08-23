import Foundation
import SwiftData

/// Builds packing lists by "realising" (deep-copying) items from base lists.
enum PackingListFactory {
    /// Merge ordered groups of item labels (one group per selected base list, in
    /// selection order) into a deduped label list. Duplicates are matched
    /// case-insensitively after trimming whitespace; the first occurrence wins,
    /// keeping its original casing and position. Blank labels are dropped.
    static func mergedLabels(fromGroups groups: [[String]]) -> [String] {
        var result: [String] = []
        var seen = Set<String>()
        for group in groups {
            for raw in group {
                let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { continue }
                if seen.insert(trimmed.lowercased()).inserted {
                    result.append(trimmed)
                }
            }
        }
        return result
    }

    /// Realise a new, independent packing list from the given base lists. Items
    /// are deep-copied (deduped, unpacked, contiguous sort order); the packing
    /// list has no link back to its sources afterward.
    @discardableResult
    static func makePackingList(
        name: String,
        from baseLists: [BaseList],
        in context: ModelContext
    ) -> PackingList {
        let groups = baseLists.map { $0.orderedItems.map(\.label) }
        let labels = mergedLabels(fromGroups: groups)

        let list = PackingList(name: name)
        context.insert(list)

        let items = labels.enumerated().map { index, label in
            PackingItem(label: label, isPacked: false, sortOrder: index)
        }
        for item in items { context.insert(item) }
        list.items = items

        return list
    }
}
