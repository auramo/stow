import Foundation
import SwiftData

/// A real, in-use packing list. Realised from one or more base lists, but fully
/// independent afterward. Items track whether they've been packed.
@Model
final class PackingList {
    var name: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    var isArchived: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \PackingItem.list)
    var items: [PackingItem]? = []

    init(name: String = "", createdAt: Date = .now) {
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.isArchived = false
    }

    /// Items in their user-defined manual order.
    var orderedItems: [PackingItem] {
        (items ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    var packedCount: Int { (items ?? []).filter(\.isPacked).count }
    var totalCount: Int { (items ?? []).count }
}
