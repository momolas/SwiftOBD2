import XCTest
@testable import SwiftOBD2

final class OBDServiceTests: XCTestCase {
    var obdService: OBDService!
    var mockComm: MOCKComm!

    override func setUp() {
        super.setUp()
        mockComm = MOCKComm()
        obdService = OBDService(connectionType: .demo)
        let elm327 = ELM327(comm: mockComm)
        obdService.elm327 = elm327
    }

    func testAddPID() {
        let pid = OBDCommand.mode1(.rpm)
        obdService.addPID(pid)
        XCTAssertEqual(obdService.pidList.count, 1)
        XCTAssertEqual(obdService.pidList.first, pid)
    }

    func testRemovePID() {
        let pid = OBDCommand.mode1(.rpm)
        obdService.addPID(pid)
        obdService.removePID(pid)
        XCTAssertTrue(obdService.pidList.isEmpty)
    }

    func testRequestPIDsBatching() async throws {
        let pids = [
            OBDCommand.mode1(.rpm),
            OBDCommand.mode1(.speed),
            OBDCommand.mode1(.throttlePosition),
            OBDCommand.mode1(.engineLoad),
            OBDCommand.mode1(.coolantTemperature),
            OBDCommand.mode1(.fuelPressure),
            OBDCommand.mode1(.intakeManifoldPressure)
        ]

        mockComm.setResponse(for: "010C0D1104050A", response: ["41 0C 00 00 0D 00 11 00 04 00 05 00 0A 00"])
        mockComm.setResponse(for: "010B", response: ["41 0B 00"])

        let results = try await obdService.requestPIDs(pids, unit: .metric)

        XCTAssertEqual(mockComm.sentCommands.count, 2)
        XCTAssertEqual(mockComm.sentCommands[0], "010C0D1104050A")
        XCTAssertEqual(mockComm.sentCommands[1], "010B")
        XCTAssertEqual(results.count, 7)
    }
}
