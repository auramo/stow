import Testing
import SwiftData
@testable import Stow

/// Turning a packing list back into a reusable base list. The mirror of
/// `PackingListRealisationTests`, and independent in the same way.
@Suite(.serialized)
@MainActor
struct BaseListCreationTests {

    /// Build a packing list from (label, isPacked) pairs, sortOrder following
    /// array order, inserted into `context`.
    private func makePackingList(
        _ name: String,
        _ items: [(String, Bool)],
        in context: ModelContext
    ) -> PackingList {
        let list = PackingList(name: name)
        context.insert(list)
        let packingItems = items.enumerated().map {
            PackingItem(label: $0.element.0, isPacked: $0.element.1, sortOrder: $0.offset)
        }
        for item in packingItems { context.insert(item) }
        list.items = packingItems
        return list
    }

    @Test func copiesEveryItemInOrderWhateverItsPackedState() {
        let context = ModelContext(TestContainer.shared)
        let trip = makePackingList("Lapin reissu", [("Tent", true), ("Socks", false), ("Laptop", true)], in: context)

        let base = BaseListFactory.makeBaseList(name: "Talvireissu", from: trip, in: context)

        #expect(base.name == "Talvireissu")
        #expect(base.orderedItems.map(\.label) == ["Tent", "Socks", "Laptop"])
        #expect(base.orderedItems.map(\.sortOrder) == [0, 1, 2])
    }

    @Test func dedupesCaseInsensitivelyAndDropsBlankLabels() {
        let context = ModelContext(TestContainer.shared)
        let trip = makePackingList(
            "Trip",
            [("Tent", false), ("  ", false), ("tent", true), ("  Socks  ", false)],
            in: context
        )

        let base = BaseListFactory.makeBaseList(name: "Template", from: trip, in: context)

        #expect(base.orderedItems.map(\.label) == ["Tent", "Socks"])
        #expect(base.orderedItems.map(\.sortOrder) == [0, 1])
    }

    @Test func baseListIsIndependentOfLaterPackingListEdits() {
        let context = ModelContext(TestContainer.shared)
        let trip = makePackingList("Trip", [("Tent", false), ("Socks", false)], in: context)

        let base = BaseListFactory.makeBaseList(name: "Template", from: trip, in: context)

        // Mutate the packing list AFTER the base list was made.
        trip.items?.first?.label = "Big Tent"
        trip.items?.append(PackingItem(label: "Sleeping Bag", sortOrder: 99))
        trip.items?.removeAll { $0.label == "Socks" }

        #expect(base.orderedItems.map(\.label) == ["Tent", "Socks"])
    }

    @Test func makesAnEmptyBaseListFromAnEmptyPackingList() {
        let context = ModelContext(TestContainer.shared)
        let trip = makePackingList("Empty", [], in: context)

        let base = BaseListFactory.makeBaseList(name: "Template", from: trip, in: context)

        #expect(base.orderedItems.isEmpty)
    }
}
