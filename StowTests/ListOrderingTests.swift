import Testing
import Foundation
@testable import Stow

@MainActor
struct ListOrderingTests {

    @Test func nextSortOrderIsOneAboveMax() {
        let items = [BaseItem(label: "a", sortOrder: 0), BaseItem(label: "b", sortOrder: 5)]
        #expect(ListOrdering.nextSortOrder(after: items) == 6)
    }

    @Test func nextSortOrderIsZeroWhenEmpty() {
        #expect(ListOrdering.nextSortOrder(after: []) == 0)
    }

    @Test func moveReassignsContiguousSortOrder() {
        let a = BaseItem(label: "a", sortOrder: 0)
        let b = BaseItem(label: "b", sortOrder: 1)
        let c = BaseItem(label: "c", sortOrder: 2)
        // Move "c" (index 2) to the front.
        ListOrdering.move([a, b, c], fromOffsets: IndexSet(integer: 2), toOffset: 0)
        #expect(a.sortOrder == 1)
        #expect(b.sortOrder == 2)
        #expect(c.sortOrder == 0)
    }

    @Test func touchUpdatesTimestamp() {
        let list = PackingList(name: "Trip", createdAt: Date(timeIntervalSince1970: 0))
        #expect(list.updatedAt == Date(timeIntervalSince1970: 0))
        list.touch()
        #expect(list.updatedAt > Date(timeIntervalSince1970: 0))
    }

    @Test func archiveAndUnarchiveToggleFlag() {
        let list = BaseList(name: "Camping")
        #expect(list.isArchived == false)
        list.archive()
        #expect(list.isArchived == true)
        list.unarchive()
        #expect(list.isArchived == false)
    }
}
