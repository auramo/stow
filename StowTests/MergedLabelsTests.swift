import Testing
@testable import Stow

struct MergedLabelsTests {

    @Test func singleGroupKeepsOrderAndLabels() {
        let result = PackingListFactory.mergedLabels(fromGroups: [["Tent", "Toothbrush", "Socks"]])
        #expect(result == ["Tent", "Toothbrush", "Socks"])
    }

    @Test func duplicatesAcrossGroupsCollapseKeepingFirstOccurrence() {
        let groups = [
            ["Tent", "Toothbrush", "Socks"],
            ["Laptop", "Toothbrush"],
        ]
        let result = PackingListFactory.mergedLabels(fromGroups: groups)
        #expect(result == ["Tent", "Toothbrush", "Socks", "Laptop"])
    }

    @Test func duplicateMatchIsCaseInsensitiveAndFirstCasingWins() {
        let groups = [["Toothbrush"], ["toothbrush"], ["TOOTHBRUSH"]]
        let result = PackingListFactory.mergedLabels(fromGroups: groups)
        #expect(result == ["Toothbrush"])
    }

    @Test func labelsAreTrimmedAndBlanksDropped() {
        let groups = [["  Socks  ", "", "   ", "Tent"]]
        let result = PackingListFactory.mergedLabels(fromGroups: groups)
        #expect(result == ["Socks", "Tent"])
    }

    @Test func trimmedDuplicatesCollapse() {
        let groups = [["Socks"], ["  socks "]]
        let result = PackingListFactory.mergedLabels(fromGroups: groups)
        #expect(result == ["Socks"])
    }

    @Test func emptyInputProducesEmptyResult() {
        #expect(PackingListFactory.mergedLabels(fromGroups: []).isEmpty)
        #expect(PackingListFactory.mergedLabels(fromGroups: [[], []]).isEmpty)
    }
}
