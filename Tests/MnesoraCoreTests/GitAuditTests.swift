import XCTest
@testable import MnesoraCore

final class GitAuditTests: XCTestCase {
    var tmpDir: URL!

    override func setUp() {
        super.setUp()
        tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("mnesora-git-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tmpDir)
        super.tearDown()
    }

    func testInitCreatesRepo() throws {
        let audit = GitAudit(directory: tmpDir)
        try audit.initIfNeeded()
        XCTAssertTrue(FileManager.default.fileExists(atPath: tmpDir.appendingPathComponent(".git").path))
    }

    func testCommitProducesEntryInLog() throws {
        let audit = GitAudit(directory: tmpDir)
        try audit.initIfNeeded()
        try "hello".write(to: tmpDir.appendingPathComponent("a.md"), atomically: true, encoding: .utf8)
        try audit.commit(message: "test: first commit", author: "Mnesora Test <test@mnesora.dev>")
        let log = try audit.log(limit: 1)
        XCTAssertEqual(log.count, 1)
        XCTAssertTrue(log[0].contains("test: first commit"))
    }

    func testEmptyCommitIsNoop() throws {
        let audit = GitAudit(directory: tmpDir)
        try audit.initIfNeeded()
        try "hello".write(to: tmpDir.appendingPathComponent("a.md"), atomically: true, encoding: .utf8)
        try audit.commit(message: "first", author: "T <t@e.com>")
        let before = try audit.log(limit: 10).count
        try audit.commit(message: "should-be-noop", author: "T <t@e.com>")
        let after = try audit.log(limit: 10).count
        XCTAssertEqual(before, after)
    }
}
