import Foundation

/// A protocol defining the essential properties of an OBD-II Parameter ID (PID).
///
/// Conforming types can represent both standard OBD-II PIDs and custom, user-defined PIDs.
public protocol PID {
    /// The OBD-II command string for the PID (e.g., "010C" for Engine RPM).
    var command: String { get }
    /// A human-readable description of what the PID measures.
    var description: String { get }
    /// The number of bytes expected in the response data.
    var bytes: Int { get }
    /// The decoder responsible for interpreting the raw data from the vehicle.
    var decoder: Decoders { get }

    /// Decodes the raw `Data` received from the vehicle for this PID.
    ///
    /// - Parameter data: The raw `Data` from the OBD-II response.
    /// - Parameter unit: The `MeasurementUnit` to decode the data into.
    /// - Returns: A `Result` containing either a successful `DecodeResult` or a `DecodeError`.
    func decode(data: Data, unit: MeasurementUnit) -> Result<DecodeResult, DecodeError>
}

/// A structure for defining a custom, non-standard OBD-II PID.
public struct CustomPID: PID, Codable, Hashable, Comparable {
    public static func < (lhs: CustomPID, rhs: CustomPID) -> Bool {
        lhs.command < rhs.command
    }

    /// The OBD-II command string for the PID.
    public let command: String
    /// A human-readable description of the PID.
    public let description: String
    /// The number of bytes expected in the response.
    public let bytes: Int
    /// The decoder used to interpret the response data.
    public let decoder: Decoders

    /// Initializes a new `CustomPID`.
    ///
    /// - Parameters:
    ///   - command: The command string to request the PID.
    ///   - description: A description of what the PID measures.
    ///   - bytes: The number of data bytes in the expected response.
    ///   - decoder: The `Decoders` enum case responsible for decoding the response.
    public init(command: String, description: String, bytes: Int, decoder: Decoders) {
        self.command = command
        self.description = description
        self.bytes = bytes
        self.decoder = decoder
    }

    /// Decodes the raw data for the custom PID.
    ///
    /// - Parameter data: The `Data` received from the vehicle.
    /// - Parameter unit: The `MeasurementUnit` to decode the data into.
    /// - Returns: A `Result` containing the decoded value or an error.
    public func decode(data: Data, unit: MeasurementUnit) -> Result<DecodeResult, DecodeError> {
        guard let decoder = decoder.getDecoder() else {
            return .failure(.unsupportedDecoder)
        }
        return decoder.decode(data: data, unit: unit)
    }
}
