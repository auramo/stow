import Testing
@testable import Stow

struct ClipboardImportTests {

    @Test func splitsEachLineIntoALabel() {
        let result = ClipboardImport.itemLabels(from: "Tent\nSocks\nToothbrush")
        #expect(result == ["Tent", "Socks", "Toothbrush"])
    }

    @Test func handlesWindowsAndClassicLineEndings() {
        #expect(ClipboardImport.itemLabels(from: "Tent\r\nSocks") == ["Tent", "Socks"])
        #expect(ClipboardImport.itemLabels(from: "Tent\rSocks") == ["Tent", "Socks"])
    }

    @Test func trimsWhitespaceOnEachLine() {
        let result = ClipboardImport.itemLabels(from: "  Tent \n\tSocks\t")
        #expect(result == ["Tent", "Socks"])
    }

    @Test func dropsBlankAndWhitespaceOnlyLines() {
        let result = ClipboardImport.itemLabels(from: "Tent\n\n   \nSocks\n")
        #expect(result == ["Tent", "Socks"])
    }

    @Test func keepsDuplicateLinesAsSeparateItems() {
        let result = ClipboardImport.itemLabels(from: "Socks\nSocks")
        #expect(result == ["Socks", "Socks"])
    }

    @Test func emptyOrBlankTextProducesNothing() {
        #expect(ClipboardImport.itemLabels(from: "").isEmpty)
        #expect(ClipboardImport.itemLabels(from: "   \n\t\n").isEmpty)
    }
}
