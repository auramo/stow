import Foundation
import SwiftData

/// A single template item inside a `BaseList`. Label only — no packed state.
@Model
final class BaseItem {
    var label: String = ""
    var sortOrder: Int = 0
    var list: BaseList?

    init(label: String = "", sortOrder: Int = 0) {
        self.label = label
        self.sortOrder = sortOrder
    }
}
