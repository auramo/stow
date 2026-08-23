import Foundation
import SwiftData

/// A reusable template list. Its items carry only a label; realising a packing
/// list deep-copies these items so later edits here never affect that packing list.
@Model
final class BaseList {
    var name: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    var isArchived: Bool = false

    // Optional to-many with explicit inverse, cascade delete — CloudKit-compatible.
    @Relationship(deleteRule: .cascade, inverse: \BaseItem.list)
    var items: [BaseItem]? = []

    init(name: String = "", createdAt: Date = .now) {
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.isArchived = false
    }

    /// Items in their user-defined manual order.
    var orderedItems: [BaseItem] {
        (items ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }
}
