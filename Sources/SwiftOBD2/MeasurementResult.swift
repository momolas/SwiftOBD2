import Foundation

/// A structure representing the result of a measurement from an OBD-II sensor.
public struct MeasurementResult: Equatable {
    /// The numerical value of the measurement.
    public var value: Double
    /// The unit of measurement (e.g., kPa, °C, km/h).
    public let unit: Unit

    /// Initializes a new `MeasurementResult`.
    /// - Parameters:
    ///   - value: The numerical value of the measurement.
    ///   - unit: The unit of the measurement.
    public init(value: Double, unit: Unit) {
        self.value = value
        self.unit = unit
    }
}

internal extension MeasurementResult {
	static func mock(_ value: Double = 125, _ suffix: String = "km/h") -> MeasurementResult {
		.init(value: value, unit: .init(symbol: suffix))
	}
}
