import Foundation

public enum ConnectionType: String, CaseIterable {
    case bluetooth = "Bluetooth"
    case wifi = "Wi-Fi"
    case demo = "Demo"
}

public protocol Device {
    var id: UUID { get }
    var name: String { get }
}

public protocol CommProtocol {
    var connectionStateStream: AsyncStream<ConnectionState> { get }
    func connectAsync(timeout: TimeInterval, device: Device?) async throws
    func sendCommand(_ command: String, retries: Int) async throws -> [String]
    func disconnectPeripheral()
    func scanForPeripherals() -> AsyncStream<Device>
}

/// Represents the errors that can occur within the `OBDService`.
public enum OBDServiceError: Error {
    /// No suitable OBD-II adapter was found during a scan.
    case noAdapterFound
    /// An operation was attempted before a connection to the vehicle was successfully established.
    case notConnectedToVehicle
    /// The connection attempt to the OBD-II adapter failed.
    case adapterConnectionFailed(underlyingError: Error)
    /// A scan for Diagnostic Trouble Codes (DTCs) failed.
    case scanFailed(underlyingError: Error)
    /// An attempt to clear Diagnostic Trouble Codes (DTCs) failed.
    case clearFailed(underlyingError: Error)
    /// A specific OBD-II command failed to execute.
    case commandFailed(command: String, error: Error)
}
