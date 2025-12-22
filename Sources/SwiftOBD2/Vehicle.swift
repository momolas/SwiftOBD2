import Foundation

public struct Vehicle: Codable, Identifiable, Equatable, Hashable {
    public static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        lhs.id == rhs.id
    }

    public let id: Int
    public var make: String
    public var model: String
    public var year: String
    public var status: Status?
    public var troubleCodes: [ECUID: [TroubleCode]]?
    public var obdinfo: OBDInfo?
}
