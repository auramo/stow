import Foundation
import SwiftData

/// A single item inside a `PackingList`, with a packed flag.
@Model
final class PackingItem {
    var label: String = ""
    var isPacked: Bool = false
    var sortOrder: Int = 0
    var list: PackingList?

    init(label: String = "", isPacked: Bool = false, sortOrder: Int = 0) {
        self.label = label
        self.isPacked = isPacked
        self.sortOrder = sortOrder
    }
}
