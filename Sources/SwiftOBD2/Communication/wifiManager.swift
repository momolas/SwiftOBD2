import Foundation
import Combine
import Network
import CoreBluetooth

enum WifiError: Error {
    case invalidResponse
    case noData
    case connectionFailed(Error)
    case sendFailed(Error)
}

class WifiManager: NSObject, CommProtocol {
    @Published var connectionState: ConnectionState = .disconnected
    var connectionStatePublisher: Published<ConnectionState>.Publisher { $connectionState }

    weak var obdDelegate: OBDServiceDelegate?

    private var connection: NWConnection?
    private let host: NWEndpoint.Host = "192.168.0.10"
    private let port: NWEndpoint.Port = 35000

    func connectAsync(timeout: TimeInterval, peripheral: CBPeripheral?) async throws {
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
    }

    func disconnectPeripheral() {
        connection?.cancel()
        connection = nil
        connectionState = .disconnected
    }

    func scanForPeripherals() async throws {
        // Not applicable for Wi-Fi
    }
}
