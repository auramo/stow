import Foundation
import SwiftData

/// Builds base lists by capturing a packing list back into a reusable template —
/// the mirror of `PackingListFactory`.
enum BaseListFactory {
    /// Make a new, independent base list from a packing list's items. Labels are
    /// deep-copied through the same trimming/dedupe rules used when realising a
    /// packing list, so both directions behave alike. Packed state is dropped:
    /// a template only carries labels. The base list has no link back afterward.
    ///
    /// `name` is expected to be trimmed by the caller, as in `PackingListFactory`.
    @discardableResult
    static func makeBaseList(
        name: String,
        from packingList: PackingList,
        in context: ModelContext
    ) -> BaseList {
        let labels = PackingListFactory.mergedLabels(
            fromGroups: [packingList.orderedItems.map(\.label)]
        )

        let list = BaseList(name: name)
        context.insert(list)

        let items = labels.enumerated().map { index, label in
            BaseItem(label: label, sortOrder: index)
        }
        for item in items { context.insert(item) }
        list.items = items

        return list
    }
}
