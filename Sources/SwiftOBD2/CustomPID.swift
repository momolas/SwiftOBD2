import Foundation

public protocol PID {
    var command: String { get }
    var description: String { get }
    var bytes: Int { get }
    var decoder: Decoders { get }
    func decode(data: Data) -> Result<DecodeResult, DecodeError>
}

public struct CustomPID: PID {
    public let command: String
    public let description: String
    public let bytes: Int
    public let decoder: Decoders

    public init(command: String, description: String, bytes: Int, decoder: Decoders) {
        self.command = command
        self.description = description
        self.bytes = bytes
        self.decoder = decoder
    }

    public func decode(data: Data) -> Result<DecodeResult, DecodeError> {
        return decoder.getDecoder()!.decode(data: data)
    }
}
