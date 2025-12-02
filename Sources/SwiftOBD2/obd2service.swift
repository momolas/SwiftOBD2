import Combine
import CoreBluetooth
import Foundation

public enum ConnectionType: String, CaseIterable {
    case bluetooth = "Bluetooth"
    case wifi = "Wi-Fi"
    case demo = "Demo"
}

struct Command: Codable {
    var bytes: Int
    var command: String
    var decoder: String
    var description: String
    var live: Bool
    var maxValue: Int
    var minValue: Int
}

public class ConfigurationService {
    static var shared = ConfigurationService()
    var connectionType: ConnectionType {
        get {
            let rawValue = UserDefaults.standard.string(forKey: "connectionType") ?? "Bluetooth"
            return ConnectionType(rawValue: rawValue) ?? .bluetooth
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "connectionType")
        }
    }
}

/// A class that provides an interface to the ELM327 OBD2 adapter and the vehicle.
///
/// - Key Responsibilities:
///   - Establishing a connection to the adapter and the vehicle.
///   - Sending and receiving OBD2 commands.
///   - Providing information about the vehicle.
///   - Managing the connection state.
public class OBDService: ObservableObject {
    @Published public private(set) var connectionState: ConnectionState = .disconnected
    @Published public private(set) var isScanning: Bool = false
    @Published public private(set) var connectedPeripheral: CBPeripheral?
    @Published public var connectionType: ConnectionType {
        didSet {
            switchConnectionType(connectionType)
            ConfigurationService.shared.connectionType = connectionType
        }
    }

    /// The internal ELM327 object responsible for direct adapter interaction.
    internal var elm327: ELM327

    private var cancellables = Set<AnyCancellable>()

    /// Initializes the OBDService object.
    ///
    /// - Parameter connectionType: The desired connection type (default is Bluetooth).
    ///
    ///
    public init(connectionType: ConnectionType = .bluetooth) {
        self.connectionType = connectionType
#if targetEnvironment(simulator)
        elm327 = ELM327(comm: MOCKComm())
#else
        switch connectionType {
        case .bluetooth:
            let bleManager = BLEManager()
            elm327 = ELM327(comm: bleManager)
        case .wifi:
            elm327 = ELM327(comm: WifiManager())
        case .demo:
            elm327 = ELM327(comm: MOCKComm())
        }
#endif
        setupConnectionStateSubscription()
    }

    private func setupConnectionStateSubscription() {
        elm327.connectionStatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$connectionState)
    }

    // MARK: - Connection Handling

    /**
     Establishes a connection to the OBD-II adapter and initializes the vehicle communication.

     This function performs the following steps:
     1. Connects to the ELM327 adapter (e.g., via Bluetooth or Wi-Fi).
     2. Initializes the adapter by sending a standard set of AT commands.
     3. Detects the correct OBD-II protocol to use for vehicle communication.
     4. Retrieves initial vehicle information, such as VIN and supported PIDs.

     - Parameter preferredProtocol: An optional `PROTOCOL` to try first. If `nil`, the service will automatically detect the protocol.
     - Parameter timeout: The maximum time in seconds to wait for the connection to be established.
     - Returns: An `OBDInfo` object containing details about the vehicle.
     - Throws: An `OBDServiceError` if the connection fails at any stage.
     */
    public func startConnection(preferredProtocol: PROTOCOL? = nil, timeout: TimeInterval = 7) async throws -> OBDInfo {
        let startTime = CFAbsoluteTimeGetCurrent()
        obdInfo("Starting connection with timeout: \(timeout)s", category: .connection)
        
        do {
            obdDebug("Connecting to adapter...", category: .connection)
            try await elm327.connectToAdapter(timeout: timeout)
            
            obdDebug("Initializing adapter...", category: .connection)
            try await elm327.adapterInitialization()
            
            obdDebug("Initializing vehicle connection...", category: .connection)
            let vehicleInfo = try await initializeVehicle(preferedProtocol)

            let duration = CFAbsoluteTimeGetCurrent() - startTime
            OBDLogger.shared.logPerformance("Connection established", duration: duration, success: true)
            obdInfo("Successfully connected to vehicle: \(vehicleInfo.vin ?? "Unknown")", category: .connection)

            return vehicleInfo
        } catch {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            OBDLogger.shared.logPerformance("Connection failed", duration: duration, success: false)
            obdError("Connection failed: \(error.localizedDescription)", category: .connection)
            throw OBDServiceError.adapterConnectionFailed(underlyingError: error) // Propagate
        }
    }

    /// Initializes communication with the vehicle and retrieves vehicle information.
    ///
    /// - Parameter preferredProtocol: The optional OBD2 protocol to use (if supported).
    /// - Returns: Information about the connected vehicle (`OBDInfo`).
    /// - Throws: Errors if the vehicle initialization process fails.
    func initializeVehicle(_ preferredProtocol: PROTOCOL?) async throws -> OBDInfo {
        let obd2info = try await elm327.setupVehicle(preferredProtocol: preferredProtocol)
        return obd2info
    }

    /**
     Disconnects from the OBD-II adapter.

     This function terminates the communication session and releases any underlying resources.
     */
    public func stopConnection() {
        elm327.stopConnection()
    }

    /// Switches the active connection type (between Bluetooth and Wi-Fi).
    ///
    /// - Parameter connectionType: The new desired connection type.
    private func switchConnectionType(_ connectionType: ConnectionType) {
        stopConnection()
        initializeELM327()
    }

    private func initializeELM327() {
        switch connectionType {
        case .bluetooth:
            let bleManager = BLEManager()
            elm327 = ELM327(comm: bleManager)
        case .wifi:
            elm327 = ELM327(comm: WifiManager())
        case .demo:
            elm327 = ELM327(comm: MOCKComm())
        }
        setupConnectionStateSubscription()
    }

    // MARK: - Request Handling

    private var pidList: [OBDCommand] = []
    private let pidListActor = PIDListManager()

    /**
     Starts a continuous stream of OBD-II data for the PIDs in the `pidList`.

     This function creates an `AsyncStream` that periodically polls the vehicle for the latest data
     for the commands currently in the `pidList`. The stream continues until the task is cancelled.

     - Parameters:
       - unit: The desired `MeasurementUnit` for the results (e.g., `.metric` or `.imperial`). Defaults to `.metric`.
       - interval: The polling interval in seconds. Defaults to `0.3` seconds.
     - Returns: An `AsyncStream` that yields dictionaries of `[OBDCommand: MeasurementResult]`.
     */
    public func startContinuousUpdates(unit: MeasurementUnit = .metric, interval: TimeInterval = 0.3) -> AsyncThrowingStream<[OBDCommand: MeasurementResult], Error> {
        return AsyncThrowingStream { continuation in
            let task = Task(priority: .userInitiated) {
                while !Task.isCancelled {
                    do {
                        let pids = await pidListActor.getPIDs()
                        let results = try await self.requestPIDs(pids, unit: unit)
                        continuation.yield(results)
                        try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                    } catch {
                        continuation.finish(throwing: error)
                        return
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

    /**
     Adds a command to the `pidList` for continuous polling.

     - Parameter pid: The `OBDCommand` to add.
     */
    public func addPID(_ pid: OBDCommand) async {
        await pidListActor.addPID(pid)
    }

    /**
     Removes a command from the `pidList`.

     - Parameter pid: The `OBDCommand` to remove.
     */
    public func removePID(_ pid: OBDCommand) async {
        await pidListActor.removePID(pid)
    }

    /**
     Requests data for a specific list of OBD-II commands.

     This function sends requests for the specified commands and decodes the responses.
     It automatically handles batching requests to avoid overwhelming the adapter.

     - Parameters:
       - commands: An array of `OBDCommand` to request from the vehicle.
       - unit: The desired `MeasurementUnit` for the results.
     - Returns: A dictionary mapping each `OBDCommand` to its `MeasurementResult`.
     - Throws: An `OBDServiceError` if the request fails.
     */
    public func requestPIDs(_ commands: [OBDCommand], unit: MeasurementUnit) async throws -> [OBDCommand: MeasurementResult] {
        let commandChunks = commands.chunked(into: 6)
        var results: [OBDCommand: MeasurementResult] = [:]

        for chunk in commandChunks {
            let pids = chunk.compactMap { $0.properties.command.dropFirst(2) }.joined()
            let response = try await sendCommandInternal("01" + pids, retries: 10)
            guard let responseData = try elm327.canProtocol?.parse(response).first?.data else { continue }

            var batchedResponse = BatchedResponse(response: responseData, unit)

            for command in chunk {
                if let measurement = batchedResponse.extractValue(command) {
                    results[command] = measurement
                }
            }
        }
        return results
    }

    /**
     Sends a single OBD-II command to the vehicle.

     - Parameter command: The `OBDCommand` to send.
     - Returns: A `DecodeResult` containing the decoded response from the vehicle.
     - Throws: An `OBDServiceError` if the command fails.
     */
    public func sendCommand(_ command: OBDCommand) async throws -> DecodeResult {
        do {
            let response = try await sendCommandInternal(command.properties.command, retries: 3)
            guard let responseData = try elm327.canProtocol?.parse(response).first?.data else {
                throw DecodeError.noData
            }
            return try command.properties.decode(data: responseData.dropFirst()).get()
        } catch {
            throw OBDServiceError.commandFailed(command: command.properties.command, error: error)
        }
    }

    /**
     Retrieves a list of OBD-II PIDs supported by the vehicle.

     - Returns: An array of `OBDCommand` that the vehicle supports.
     */
    public func getSupportedPIDs() async -> [OBDCommand] {
        await elm327.getSupportedPIDs()
    }

    /**
     Scans the vehicle for Diagnostic Trouble Codes (DTCs).

     - Returns: A dictionary where keys are `ECUID`s and values are arrays of `TroubleCode` found for that ECU.
     - Throws: An `OBDServiceError` if the scan fails.
     */
    public func scanForTroubleCodes() async throws -> [ECUID: [TroubleCode]] {
        do {
            return try await elm327.scanForTroubleCodes()
        } catch {
            throw OBDServiceError.scanFailed(underlyingError: error)
        }
    }

    /**
     Retrieves the monitor status since the DTCs were last cleared.

     - Returns: A `DecodeResult` containing the status information.
     - Throws: An error if the request fails.
     */
    public func getStatusSinceDTCCleared() async throws -> DecodeResult {
        do {
            return try await elm327.getStatusSinceDTCCleared()
        } catch {
            throw error
        }
    }

    /**
     Runs OBD system tests (Mode 0x07) to check for pending trouble codes.

     - Returns: `true` if any pending trouble codes are found, otherwise `false`.
     - Throws: An `OBDServiceError` if the test fails.
     */
    public func runOBDTests() async throws -> Bool {
        do {
            return try await elm327.runOBDTests()
        } catch {
            throw OBDServiceError.scanFailed(underlyingError: error)
        }
    }

    /**
     Clears all Diagnostic Trouble Codes (DTCs) from the vehicle's ECU.

     - Throws: An `OBDServiceError` if the clear operation fails.
     */
    public func clearTroubleCodes() async throws {
        do {
            try await elm327.clearTroubleCodes()
        } catch {
            throw OBDServiceError.clearFailed(underlyingError: error)
        }
    }

    /**
     Retrieves the overall status of the vehicle's onboard systems.

     - Returns: A `DecodeResult` containing the status information.
     - Throws: An error if the request fails.
     */
    public func getStatus() async throws -> DecodeResult {
        do {
            return try await elm327.getStatus()
        } catch {
            throw error
        }
    }

    //    public func switchToDemoMode(_ isDemoMode: Bool) {
    //        elm327.switchToDemoMode(isDemoMode)
    //    }

    /// Sends a raw command to the vehicle and returns the raw response.
    /// - Parameter message: The raw command to send.
    /// - Returns: The raw response from the vehicle.
    /// - Throws: Errors that might occur during the request process.
    public func sendCommandInternal(_ message: String, retries: Int) async throws -> [String] {
        do {
            return try await elm327.sendCommand(message, retries: retries)
        } catch {
            throw OBDServiceError.commandFailed(command: message, error: error)
        }
    }

    public func connectToPeripheral(peripheral: CBPeripheral) async throws {
        do {
            try await elm327.connectToAdapter(timeout: 5, peripheral: peripheral)
        } catch {
            throw OBDServiceError.adapterConnectionFailed(underlyingError: error)
        }
    }

    public func scanForPeripherals() async throws {
        self.isScanning = true
        defer { self.isScanning = false }
        do {
            try await elm327.scanForPeripherals()
        } catch {
            throw OBDServiceError.scanFailed(underlyingError: error)
        }
    }


}

public enum OBDServiceError: Error {
    case noAdapterFound
    case notConnectedToVehicle
    case adapterConnectionFailed(underlyingError: Error)
    case scanFailed(underlyingError: Error)
    case clearFailed(underlyingError: Error)
    case commandFailed(command: String, error: Error)
}

public struct MeasurementResult: Equatable {
    public var value: Double
    public let unit: Unit
	
	public init(value: Double, unit: Unit) {
		self.value = value
		self.unit = unit
	}
}

public extension MeasurementResult {
	static func mock(_ value: Double = 125, _ suffix: String = "km/h") -> MeasurementResult {
		.init(value: value, unit: .init(symbol: suffix))
	}
}

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

