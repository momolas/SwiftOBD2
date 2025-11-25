import Foundation

public protocol PID {
    var command: String { get }
    var description: String { get }
    var bytes: Int { get }
    func decode(data: Data) -> Result<DecodeResult, DecodeError>
}

public struct CustomPID: PID {
    public let command: String
    public let description: String
    public let bytes: Int
    private let decoder: (Data) -> Result<DecodeResult, DecodeError>

    public init(command: String, description: String, bytes: Int, decoder: @escaping (Data) -> Result<DecodeResult, DecodeError>) {
        self.command = command
        self.description = description
        self.bytes = bytes
        self.decoder = decoder
    }

    public func decode(data: Data) -> Result<DecodeResult, DecodeError> {
        return decoder(data)
    }
}
