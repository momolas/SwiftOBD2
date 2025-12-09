import Foundation
import Network

public enum WifiError: Error, LocalizedError {
    case invalidResponse
    case noData
    case connectionFailed(Error)
    case sendFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from Wi-Fi adapter."
        case .noData:
            return "No data received from Wi-Fi adapter."
        case .connectionFailed(let error):
            return "Wi-Fi connection failed: \(error.localizedDescription)"
        case .sendFailed(let error):
            return "Failed to send data to Wi-Fi adapter: \(error.localizedDescription)"
        }
    }
}

class WifiManager: NSObject, CommProtocol {
    var connectionState: ConnectionState = .disconnected {
        didSet {
            continuation?.yield(connectionState)
        }
    }

    private var continuation: AsyncStream<ConnectionState>.Continuation?
    var connectionStateStream: AsyncStream<ConnectionState> {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.yield(connectionState)
        }
    }

    private var connection: NWConnection?
    private let host: NWEndpoint.Host
    private let port: NWEndpoint.Port

    init(host: String = "192.168.0.10", port: UInt16 = 35000) {
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(integerLiteral: port)
    }

    func connectAsync(timeout: TimeInterval, device: Device?) async throws {
        let endpoint = NWEndpoint.hostPort(host: host, port: port)
        let parameters = NWParameters.tcp

        connection = NWConnection(to: endpoint, using: parameters)

        return try await withCheckedThrowingContinuation { continuation in
            connection?.stateUpdateHandler = { [weak self] state in
                switch state {
                case .ready:
                    self?.connectionState = .connectedToAdapter
                    continuation.resume()
                case .failed(let error):
                    self?.connectionState = .disconnected
                    continuation.resume(throwing: WifiError.connectionFailed(error))
                case .cancelled:
                    self?.connectionState = .disconnected
                default:
                    break
                }
            }
            connection?.start(queue: .global())
        }
    }

    func sendCommand(_ command: String, retries: Int) async throws -> [String] {
        guard let connection = connection else {
            throw WifiError.connectionFailed(NSError(domain: "WifiManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not connected"]))
        }

        for i in 0..<retries {
            do {
                let data = (command + "\r").data(using: .utf8)!

                return try await withCheckedThrowingContinuation { continuation in
                    connection.send(content: data, completion: .contentProcessed { error in
                        if let error = error {
                            continuation.resume(throwing: WifiError.sendFailed(error))
                            return
                        }
                    })

                    connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { content, _, isComplete, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }

                        if let content = content, !content.isEmpty {
                            let responseString = String(data: content, encoding: .utf8) ?? ""
                            let lines = responseString.components(separatedBy: .newlines).filter { !$0.isEmpty && $0 != ">" }
                            continuation.resume(returning: lines)
                        } else if isComplete {
                            continuation.resume(throwing: WifiError.noData)
                        }
                    }
                }
            } catch {
                if i < retries - 1 {
                    try await Task.sleep(for: .milliseconds(100))
                } else {
                    throw error
                }
            }
        }
        throw WifiError.sendFailed(NSError(domain: "WifiManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed after multiple retries"]))
    }

    func disconnectPeripheral() {
        connection?.cancel()
        connection = nil
        connectionState = .disconnected
    }

    func scanForPeripherals() -> AsyncStream<Device> {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }
}
