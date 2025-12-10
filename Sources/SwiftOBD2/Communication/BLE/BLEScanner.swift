import CoreBluetooth
import Foundation
import OSLog

/// Protocol for BLE scanning operations
protocol BLEScannerProtocol {
    var foundPeripherals: [CBPeripheral] { get }
    var peripheralStream: AsyncStream<CBPeripheral> { get }

    func startScanning(services: [CBUUID]?) async throws
    func stopScanning()
    func scanForPeripheralAsync(services: [CBUUID]?, timeout: TimeInterval) async throws -> CBPeripheral?
}

/// Focused component responsible for BLE device discovery and peripheral management
class BLEPeripheralScanner {
    var foundPeripherals: [CBPeripheral] = []

    private var continuation: AsyncStream<CBPeripheral>.Continuation?
    lazy var peripheralStream: AsyncStream<CBPeripheral> = {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.example.app", category: "BLEPeripheralScanner")

    nonisolated(unsafe) static let supportedServices = [
        CBUUID(string: "FFE0"),
        CBUUID(string: "FFF0"),
        CBUUID(string: "18F0"), // e.g. VGate iCar Pro
    ]

    func addDiscoveredPeripheral(_ peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        // Filter out peripherals with invalid RSSI
        guard rssi.intValue < 0 else { return }

        if !foundPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            foundPeripherals.append(peripheral)
            continuation?.yield(peripheral)
            logger.info("Found new peripheral: \(peripheral.name ?? "Unnamed") - RSSI: \(rssi)")
        }
    }
}
// MARK: - CBPeripheralDelegate

// MARK: - Error Types

enum BLEScannerError: Error, LocalizedError {
    case centralManagerNotAvailable
    case bluetoothNotPoweredOn
    case scanTimeout
    case peripheralNotFound

    var errorDescription: String? {
        switch self {
        case .centralManagerNotAvailable:
            return "Bluetooth Central Manager is not available"
        case .bluetoothNotPoweredOn:
            return "Bluetooth is not powered on"
        case .scanTimeout:
            return "BLE scanning timed out"
        case .peripheralNotFound:
            return "No compatible BLE peripheral found"
        }
    }
}

/// Cancels the current operation and throws a timeout error.
func withTimeout<R: Sendable>(
    seconds: TimeInterval,
    timeoutError: Error = BLEManagerError.timeout,
    onTimeout: (() -> Void)? = nil,
    operation: @escaping @Sendable () async throws -> R
) async throws -> R {
    try await withThrowingTaskGroup(of: R.self) { group in
        group.addTask {
            let result = try await operation()
            try Task.checkCancellation()
            return result
        }

        group.addTask {
            if seconds > 0 {
                try await Task.sleep(for: .seconds(seconds))
            }
            try Task.checkCancellation()

            // Call cleanup handler if provided
            onTimeout?()
            throw timeoutError
        }

        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}
