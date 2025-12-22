import CoreBluetooth
import Foundation
import Observation

/// A class that provides an interface to the ELM327 OBD2 adapter and the vehicle.
///
/// - Key Responsibilities:
///   - Establishing a connection to the adapter and the vehicle.
///   - Sending and receiving OBD2 commands.
///   - Providing information about the vehicle.
///   - Managing the connection state.
@Observable
@MainActor
public class OBDService {
    /// The current state of the connection to the OBD-II adapter.
    public private(set) var connectionState: ConnectionState = .disconnected
    /// A Boolean value indicating whether the service is currently scanning for peripherals.
    public private(set) var isScanning: Bool = false
    /// The `CBPeripheral` that is currently connected. `nil` if not connected.
    /// - Note: This property will be deprecated in a future version in favor of a generic `Device` type.
    public private(set) var connectedPeripheral: CBPeripheral?
    /// The selected connection type (e.g., Bluetooth, Wi-Fi).
    public var connectionType: ConnectionType {
        didSet {
            switchConnectionType(connectionType)
            ConfigurationService.shared.connectionType = connectionType
        }
    }

    /// The internal ELM327 object responsible for direct adapter interaction.
    internal var elm327: ELM327

    private var connectionStateTask: Task<Void, Never>?

    /// Initializes a new instance of `OBDService`.
    ///
    /// This initializer sets up the service with the specified connection type.
    /// In a simulator environment, it defaults to using a mock communicator (`MOCKComm`).
    ///
    /// - Parameter connectionType: The desired method of connecting to the OBD-II adapter (e.g., `.bluetooth`, `.wifi`).
    /// The default value is `.bluetooth`.
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
            // Uses default host (192.168.0.10) and port (35000)
            elm327 = ELM327(comm: WifiManager())
        case .demo:
            elm327 = ELM327(comm: MOCKComm())
        }
#endif
        setupConnectionStateSubscription()
    }

    private func setupConnectionStateSubscription() {
        connectionStateTask?.cancel()
        connectionStateTask = Task { [weak self] in
            guard let self = self else { return }
            for await state in self.elm327.connectionStateStream {
                self.connectionState = state
            }
        }
    }

    // MARK: - Connection Handling

    /// Establishes a connection to the OBD-II adapter and initializes communication with the vehicle.
    ///
    /// This asynchronous function orchestrates the entire connection process, including:
    /// 1. Connecting to the ELM327 adapter.
    /// 2. Initializing the adapter with a standard set of AT commands.
    /// 3. Automatically detecting the correct OBD-II protocol for vehicle communication.
    /// 4. Retrieving essential vehicle information like VIN and supported PIDs.
    ///
    /// - Parameters:
    ///   - preferredProtocol: An optional `PROTOCOL` to attempt first. If `nil` or unsupported, the service
    ///     will automatically cycle through available protocols.
    ///   - timeout: The maximum duration (in seconds) to wait for the connection to be established.
    /// - Returns: An `OBDInfo` object containing key details about the vehicle upon a successful connection.
    /// - Throws: An `OBDServiceError` if any stage of the connection process fails, containing details about the failure.
    public func startConnection(preferredProtocol: PROTOCOL? = nil, timeout: TimeInterval = 7) async throws -> OBDInfo {
        let startTime = CFAbsoluteTimeGetCurrent()
        obdInfo("Starting connection with timeout: \(timeout)s", category: .connection)
        
        do {
            obdDebug("Connecting to adapter...", category: .connection)
            try await elm327.connectToAdapter(timeout: timeout)
            
            obdDebug("Initializing adapter...", category: .connection)
            try await elm327.adapterInitialization()
            
            obdDebug("Initializing vehicle connection...", category: .connection)
            let vehicleInfo = try await initializeVehicle(preferredProtocol)

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

    /// Disconnects from the OBD-II adapter.
    ///
    /// This function terminates the communication session and releases any associated resources.
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
            // Uses default host (192.168.0.10) and port (35000)
            elm327 = ELM327(comm: WifiManager())
        case .demo:
            elm327 = ELM327(comm: MOCKComm())
        }
        setupConnectionStateSubscription()
    }

    // MARK: - Request Handling

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
                        try await Task.sleep(for: .seconds(interval))
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

    /// Adds a command to the list for continuous polling.
    ///
    /// - Parameter pid: The `OBDCommand` to be added to the continuous update stream.
    public func addPID(_ pid: OBDCommand) async {
        await pidListActor.addPID(pid)
    }

    /// Removes a command from the list for continuous polling.
    ///
    /// - Parameter pid: The `OBDCommand` to be removed from the continuous update stream.
    public func removePID(_ pid: OBDCommand) async {
        await pidListActor.removePID(pid)
    }

    /// Requests data for a specific list of OBD-II PIDs.
    ///
    /// This function efficiently queries the vehicle for the specified commands. It automatically
    /// handles batching of requests to optimize communication with the adapter.
    ///
    /// - Parameters:
    ///   - commands: An array of `OBDCommand` to request from the vehicle.
    ///   - unit: The measurement unit (`.metric` or `.imperial`) for the decoded results.
    /// - Returns: A dictionary where keys are the requested `OBDCommand`s and values are the corresponding `MeasurementResult`s.
    /// - Throws: An `OBDServiceError` if the request fails or the response cannot be decoded.
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

    /// Sends a single OBD-II command to the vehicle.
    ///
    /// - Parameter command: The `OBDCommand` to be sent.
    /// - Returns: A `DecodeResult` containing the decoded value from the vehicle's response.
    /// - Throws: An `OBDServiceError` if the command fails or the response cannot be decoded.
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

    /// Retrieves a list of OBD-II PIDs supported by the connected vehicle.
    ///
    /// - Returns: An array of `OBDCommand` corresponding to the PIDs the vehicle claims to support.
    public func getSupportedPIDs() async -> [OBDCommand] {
        await elm327.getSupportedPIDs()
    }

    /// Scans the vehicle for Diagnostic Trouble Codes (DTCs).
    ///
    /// This function queries all Electronic Control Units (ECUs) for stored trouble codes.
    ///
    /// - Returns: A dictionary where keys are `ECUID`s and values are arrays of `TroubleCode`
    ///   objects found for that specific ECU.
    /// - Throws: An `OBDServiceError.scanFailed` error if the DTC scan fails.
    public func scanForTroubleCodes() async throws -> [ECUID: [TroubleCode]] {
        do {
            return try await elm327.scanForTroubleCodes()
        } catch {
            throw OBDServiceError.scanFailed(underlyingError: error)
        }
    }

    /// Scans the vehicle for Pending Diagnostic Trouble Codes (DTCs) - Mode 07.
    ///
    /// - Returns: A dictionary where keys are `ECUID`s and values are arrays of `TroubleCode`.
    /// - Throws: An `OBDServiceError.scanFailed` error if the DTC scan fails.
    public func scanForPendingTroubleCodes() async throws -> [ECUID: [TroubleCode]] {
        do {
            return try await elm327.scanForPendingTroubleCodes()
        } catch {
            throw OBDServiceError.scanFailed(underlyingError: error)
        }
    }

    /// Scans the vehicle for Permanent Diagnostic Trouble Codes (DTCs) - Mode 0A.
    ///
    /// - Returns: A dictionary where keys are `ECUID`s and values are arrays of `TroubleCode`.
    /// - Throws: An `OBDServiceError.scanFailed` error if the DTC scan fails.
    public func scanForPermanentTroubleCodes() async throws -> [ECUID: [TroubleCode]] {
        do {
            return try await elm327.scanForPermanentTroubleCodes()
        } catch {
            throw OBDServiceError.scanFailed(underlyingError: error)
        }
    }

    /// Retrieves the vehicle's Calibration ID (CALID) - Mode 09 PID 04.
    public func getVehicleCalibrationID() async throws -> String? {
        return try await elm327.getCalibrationID()
    }

    /// Retrieves the vehicle's Calibration Verification Number (CVN) - Mode 09 PID 06.
    public func getCVN() async throws -> String? {
        return try await elm327.getCVN()
    }

    /// Retrieves and decodes the Vehicle Identification Number (VIN).
    public func getDecodedVIN() async throws -> VehicleDetails? {
        guard let vin = try await elm327.requestVin() else { return nil }
        return VINDecoder.decode(vin: vin)
    }

    /// Retrieves freeze frame data for a specific PID - Mode 02.
    public func getFreezeFrame(for pid: OBDCommand.Mode1) async throws -> MeasurementResult? {
        return try await elm327.requestFreezeFrame(for: pid)
    }

    /// Initiates an EVAP System Leak Test (Mode 08).
    /// - Returns: `true` if the test initiation request was successful.
    public func startEvapLeakTest() async throws -> Bool {
        return try await elm327.controlEvapLeakTest()
    }

    /// Retrieves the monitor status since the Diagnostic Trouble Codes (DTCs) were last cleared.
    ///
    /// This is useful for checking the readiness of emissions-related systems.
    ///
    /// - Returns: A `DecodeResult` containing the monitor status information.
    /// - Throws: An `OBDServiceError` if the request fails.
    public func getStatusSinceDTCCleared() async throws -> DecodeResult {
        do {
            return try await elm327.getStatusSinceDTCCleared()
        } catch {
            throw error
        }
    }

    /// Runs OBD system tests to check for pending trouble codes (Mode 0x07).
    ///
    /// - Returns: `true` if any pending trouble codes are detected, otherwise `false`.
    /// - Throws: An `OBDServiceError.scanFailed` if the test cannot be completed.
    public func runOBDTests() async throws -> Bool {
        do {
            return try await elm327.runOBDTests()
        } catch {
            throw OBDServiceError.scanFailed(underlyingError: error)
        }
    }

    /// Clears all stored Diagnostic Trouble Codes (DTCs) from the vehicle's ECUs.
    ///
    /// - Important: This action will reset emission readiness monitors.
    /// - Throws: An `OBDServiceError.clearFailed` if the operation fails.
    public func clearTroubleCodes() async throws {
        do {
            try await elm327.clearTroubleCodes()
        } catch {
            throw OBDServiceError.clearFailed(underlyingError: error)
        }
    }

    /// Retrieves the overall status of the vehicle's onboard systems.
    ///
    /// This typically includes information about MIL (Malfunction Indicator Lamp) status and DTC counts.
    ///
    /// - Returns: A `DecodeResult` containing the overall vehicle status.
    /// - Throws: An `OBDServiceError` if the request fails.
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

    /// Connects to a specific OBD-II adapter.
    ///
    /// This method is used to establish a connection with a previously discovered device.
    ///
    /// - Parameter device: The `Device` to connect to.
    /// - Throws: An `OBDServiceError.adapterConnectionFailed` if the connection attempt fails.
    public func connectToDevice(_ device: Device) async throws {
        do {
            try await elm327.connectToAdapter(timeout: 5, device: device)
        } catch {
            throw OBDServiceError.adapterConnectionFailed(underlyingError: error)
        }
    }

    /// Scans for nearby OBD-II peripherals.
    ///
    /// - Returns: An `AsyncStream` that yields `Device` objects as they are discovered.
    public func scanForPeripherals() -> AsyncStream<Device> {
        return elm327.scanForPeripherals()
    }


}
