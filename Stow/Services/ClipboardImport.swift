import Foundation

/// Turns pasted clipboard text into item labels.
enum ClipboardImport {
    /// One label per non-blank line, trimmed of surrounding whitespace. Duplicate
    /// lines are kept (each line becomes its own item) and order is preserved.
    static func itemLabels(from text: String) -> [String] {
        text.split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
