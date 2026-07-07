import XCTest
@testable import Wodcard

@MainActor
final class WodcardTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let before = store.entries.count
        store.add(LogEntry(title: "Test", date: Date(), value1: 1, value2: 1, notes: "note"))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testDeleteEntryRemovesIt() {
        let entry = LogEntry(title: "ToDelete", date: Date(), value1: 1, value2: 1, notes: "")
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateEntryChangesFields() {
        let entry = LogEntry(title: "Orig", date: Date(), value1: 1, value2: 1, notes: "")
        store.add(entry)
        var updated = entry
        updated.title = "Changed"
        store.update(updated)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.title, "Changed")
    }

    func testCanAddMoreFreeTrueInitially() {
        XCTAssertTrue(store.canAddMoreFree)
    }

    func testCanAddMoreFreeFalseAtLimit() {
        store.entries = (0..<Store.freeLimit).map { _ in LogEntry(title: "x", date: Date(), value1: 0, value2: 0, notes: "") }
        XCTAssertFalse(store.canAddMoreFree)
    }

    func testDeleteAtOffsetsRemovesCorrectEntry() {
        store.entries = []
        let a = LogEntry(title: "A", date: Date(), value1: 0, value2: 0, notes: "")
        let b = LogEntry(title: "B", date: Date(), value1: 0, value2: 0, notes: "")
        store.add(b)
        store.add(a)
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.first?.title, "B")
    }

    func testEntriesPersistAcrossReload() {
        store.add(LogEntry(title: "Persisted", date: Date(), value1: 2, value2: 2, notes: ""))
        let reloaded = Store()
        XCTAssertTrue(reloaded.entries.contains(where: { $0.title == "Persisted" }))
    }
}
