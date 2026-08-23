import Testing
import SwiftData
@testable import Stow

// Creating more than one in-memory ModelContainer per process trips a trap deep
// in SwiftData's CoreData-backed store. Swift Testing makes a fresh suite
// instance per test, so share ONE container (static) and give each test its own
// context for isolation. `.serialized` keeps the shared store single-threaded.
@Suite(.serialized)
@MainActor
struct PackingListRealisationTests {

    static let container = StowModelContainer.makeInMemory()

    /// Build a base list with the given labels (sortOrder follows array order),
    /// inserted into `context`.
    private func makeBaseList(_ name: String, _ labels: [String], in context: ModelContext) -> BaseList {
        let list = BaseList(name: name)
        context.insert(list)
        let items = labels.enumerated().map { BaseItem(label: $0.element, sortOrder: $0.offset) }
        for item in items { context.insert(item) }
        list.items = items
        return list
    }

    @Test func realisesDedupedItemsAllUnpackedInOrder() {
        let context = ModelContext(Self.container)
        let camping = makeBaseList("Camping", ["Tent", "Toothbrush", "Socks"], in: context)
        let business = makeBaseList("Business", ["Laptop", "Toothbrush"], in: context)

        let packing = PackingListFactory.makePackingList(name: "Trip", from: [camping, business], in: context)

        #expect(packing.name == "Trip")
        #expect(packing.orderedItems.map(\.label) == ["Tent", "Toothbrush", "Socks", "Laptop"])
        #expect(packing.orderedItems.map(\.sortOrder) == [0, 1, 2, 3])
        #expect(packing.orderedItems.allSatisfy { !$0.isPacked })
    }

    @Test func packingListIsIndependentOfLaterBaseListEdits() {
        let context = ModelContext(Self.container)
        let camping = makeBaseList("Camping", ["Tent", "Toothbrush"], in: context)

        let packing = PackingListFactory.makePackingList(name: "Trip", from: [camping], in: context)

        // Mutate the base list AFTER realisation.
        camping.items?.first?.label = "Big Tent"
        camping.items?.append(BaseItem(label: "Sleeping Bag", sortOrder: 99))
        camping.items?.removeAll { $0.label == "Toothbrush" }

        // The packing list must be unchanged.
        #expect(packing.orderedItems.map(\.label) == ["Tent", "Toothbrush"])
    }
}
