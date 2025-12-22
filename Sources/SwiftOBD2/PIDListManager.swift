import Foundation

actor PIDListManager {
    private var pidList: [OBDCommand] = []

    func getPIDs() -> [OBDCommand] {
        return pidList
    }

    func addPID(_ pid: OBDCommand) {
        pidList.append(pid)
    }

    func removePID(_ pid: OBDCommand) {
        pidList.removeAll { $0 == pid }
    }
}
