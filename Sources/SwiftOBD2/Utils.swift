import Foundation
import CoreBluetooth

public enum PROTOCOL: String, CaseIterable, Codable, Hashable {
    case ISO_15765_4_11bit_500k = "6"
    case ISO_15765_4_29bit_500k = "7"
    case ISO_15765_4_11bit_250K = "8"
    case ISO_15765_4_29bit_250k = "9"
    case SAE_J1939 = "A"
    case SAE_J1850_PWM = "1"
    case SAE_J1850_VPW = "2"
    case ISO_9141_2 = "3"
    case ISO_14230_4_KWP_5Baud = "4"
    case ISO_14230_4_KWP_Fast = "5"
    case NONE = "0"

    public var description: String {
        switch self {
        case .ISO_15765_4_11bit_500k: return "ISO 15765-4 (CAN 11/500)"
        case .ISO_15765_4_29bit_500k: return "ISO 15765-4 (CAN 29/500)"
        case .ISO_15765_4_11bit_250K: return "ISO 15765-4 (CAN 11/250)"
        case .ISO_15765_4_29bit_250k: return "ISO 15765-4 (CAN 29/250)"
        case .SAE_J1939: return "SAE J1939 (CAN 29/250)"
        case .SAE_J1850_PWM: return "SAE J1850 PWM"
        case .SAE_J1850_VPW: return "SAE J1850 VPW"
        case .ISO_9141_2: return "ISO 9141-2"
        case .ISO_14230_4_KWP_5Baud: return "ISO 14230-4 KWP (5 baud init)"
        case .ISO_14230_4_KWP_Fast: return "ISO 14230-4 KWP (fast init)"
        case .NONE: return "NONE"
        }
    }

    public var cmd: String {
        "ATSP" + rawValue
    }
}

nonisolated(unsafe) let protocols: [PROTOCOL: CANProtocol] = [
    .ISO_15765_4_11bit_500k: ISO_15765_4_11bit_500k(),
    .ISO_15765_4_29bit_500k: ISO_15765_4_29bit_500k(),
    .ISO_15765_4_11bit_250K: ISO_15765_4_11bit_250K(),
    .ISO_15765_4_29bit_250k: ISO_15765_4_29bit_250k(),
    .SAE_J1939: SAE_J1939(),
    .SAE_J1850_PWM: SAE_J1850_PWM(),
    .SAE_J1850_VPW: SAE_J1850_VPW(),
    .ISO_9141_2: ISO_9141_2(),
    .ISO_14230_4_KWP_5Baud: ISO_14230_4_KWP_5Baud(),
    .ISO_14230_4_KWP_Fast: ISO_14230_4_KWP_Fast()
]


extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension CBPeripheral: @unchecked Sendable {}
extension CBCentralManager: @unchecked Sendable {}
extension BLECharacteristicHandler: @unchecked Sendable {}
