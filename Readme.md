![Header](https://github.com/kkonteh97/SwiftOBD2/blob/main/Sources/Assets/github-header-image.png)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/kkonteh97/SwiftOBD2/blob/main/LICENSE) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com) ![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20-lightgrey) ![Swift Version](https://img.shields.io/badge/swift-5.0-orange) ![iOS Version](https://img.shields.io/badge/iOS-^14.0-blue) ![macOS Version](https://img.shields.io/badge/macOS-11.0%20%7C%2012.0-blue)

[![GitHub stars](https://img.shields.io/github/stars/kkonteh97/SwiftOBD2?style=social)](https://github.com/kkonteh97/SwiftOBD2/stargazers) [![GitHub forks](https://img.shields.io/github/forks/kkonteh97/SwiftOBD2?style=social)](https://github.com/kkonteh97/SwiftOBD2/network/members)

## 🌟 Show Your Support

**⭐ Star this repo** if you find SwiftOBD2 useful! Your support helps the project grow and reach more developers.

[![GitHub contributors](https://img.shields.io/github/contributors/kkonteh97/SwiftOBD2)](https://github.com/kkonteh97/SwiftOBD2/graphs/contributors) [![GitHub issues](https://img.shields.io/github/issues/kkonteh97/SwiftOBD2)](https://github.com/kkonteh97/SwiftOBD2/issues) [![GitHub last commit](https://img.shields.io/github/last-commit/kkonteh97/SwiftOBD2)](https://github.com/kkonteh97/SwiftOBD2/commits/main)

------------


SwiftOBD2 is a Swift package designed to simplify communication with vehicles using an ELM327 OBD2 adapter. It provides a straightforward and powerful interface for interacting with your vehicle's onboard diagnostics system, allowing you to retrieve real-time data and perform diagnostics. [Sample App](https://github.com/kkonteh97/SwiftOBD2App).

## 🚗 See It In Action

> **Demo coming soon!** We're preparing a comprehensive demo video showcasing real-time vehicle data retrieval, DTC scanning, and more.

### Screenshots
- Real-time RPM, Speed, and Engine Load monitoring
- Diagnostic Trouble Code (DTC) scanning and clearing
- Live sensor data visualization
- Bluetooth connection management

*Screenshots and demo GIF will be added in the next release*

## ⚡ Quick Start

Get up and running in 2 minutes:

```swift
// 1. Add to your project via Swift Package Manager
// File > Add Packages... > https://github.com/kkonteh97/SwiftOBD2

// 2. Import and connect
import SwiftOBD2

let obdService = OBDService(connectionType: .bluetooth)
let obd2Info = try await obdService.startConnection()

// 3. Get real-time data
Task {
    await obdService.addPID(.mode1(.rpm))
    await obdService.addPID(.mode1(.speed))
    for await measurements in obdService.startContinuousUpdates() {
        print("RPM: \(measurements[.mode1(.rpm)]?.value ?? 0)")
        print("Speed: \(measurements[.mode1(.speed)]?.value ?? 0)")
    }
}
```

**Expected Output:**
```
RPM: 2150.0 
Speed: 65.0
```

### Requirements

- iOS 26.0+ / macOS 16.0+
- Swift 6.2+

### Key Features

* Connection Management:
    * Establishes connections to the OBD2 adapter via Bluetooth or Wi-Fi.
    * Handles the initialization of the adapter and the vehicle connection process.
    * Manages connection states (disconnected, connectedToAdapter, connectedToVehicle).
    
* Command Interface:
    * Send and receive OBD2 commands for powerful interaction with your vehicle.
    
* Data Retrieval:
    * Supports requests for real-time vehicle data (RPM, speed, etc.) using standard OBD2 PIDs (Parameter IDs).
    * Provides functions to continuously poll and retrieve updated measurements.
    * Can get a list of supported PIDs from the vehicle.
    
* Diagnostics:
    * Retrieves and clears diagnostic trouble codes (DTCs) (confirmed, pending, permanent).
    * Gets the overall status of the vehicle's onboard systems.
    * Retrieves Freeze Frame data.
    * Retrieves Vehicle Information (VIN, Calibration ID, CVN).
    
* Sensor Monitoring:
    * Retrieve and view data from various vehicle sensors in real time.
    
* Adaptability and Configuration
    * Can switch between Bluetooth and Wi-Fi communication seamlessly.
    * Allows for testing and development with a demo mode.
    

### Roadmap

- [x] Connect to an OBD2 adapter via Bluetooth Low Energy (BLE) 
- [x] Retrieve error codes (DTCs) stored in the vehicle's OBD2 system
- [x] Retrieve various OBD2 Parameter IDs (PIDs) for monitoring vehicle parameters
- [x] Retrieve real-time vehicle data (RPM, speed, etc.) using standard OBD2 PIDs
- [x] Get supported PIDs from the vehicle
- [x] Clear error codes (DTCs) stored in the vehicle's OBD2 system
- [x] Connect to an OBD2 adapter via WIFI
- [x] Run tests on the OBD2 system
- [x] Retrieve vehicle status since DTCs cleared
- [x] Add support for custom PIDs
- [x] Retrieve Permanent DTCs (Mode 0A)
- [x] Retrieve Pending DTCs (Mode 07)
- [x] Retrieve Vehicle Information (VIN, CALID, CVN) (Mode 09)
- [x] Retrieve Freeze Frame Data (Mode 02)
    
    
### Setting Up a Project

1. Create a New Swift Project:
    * Open Xcode and start a new iOS project (You can use a simple "App" template).

2. Add the SwiftOBD2 Package:
    * In Xcode, navigate to File > Add Packages...
    * Enter this repository's URL: https://github.com/kkonteh97/SwiftOBD2/
    * Select the desired dependency rule (version, branch, or commit).

3. Permissions and Capabilities:
    * If your app will use Bluetooth, you need to request the appropriate permissions and capabilities:
        * Add NSBluetoothAlwaysUsageDescription to your Info.plist file with a brief description of why your app needs to use Bluetooth.
        * Navigate to the Signing & Capabilities tab in your project settings and add the Background Modes capability. Enable the Uses Bluetooth LE Accessories option.
    * If your app will use Wi-Fi, you need to add the following key to your Info.plist to allow local network access:
        * Add `NSLocalNetworkUsageDescription` with a description of why your app needs to access the local network.
        * Add `NSBonjourServices` as an array and add `_obd2._tcp` and `_obd2._udp` to it.

4. Configuration (Wi-Fi):
    * The default Wi-Fi settings are Host: `192.168.0.10` and Port: `35000`.
    * You can customize these settings when initializing the `WifiManager`.

### Key Concepts

* SwiftUI & Observation: Your code leverages the SwiftUI framework and the Observation framework for reactive UI updates.
* OBDService: This is the core class within the SwiftOBD2 package. It handles communication with the OBD-II adapter and processes data from the vehicle.
* OBDCommand: These represent specific requests you can make to the vehicle's ECU (Engine Control Unit) for data.

### Usage

1. Import and Setup
    * Begin by importing the necessary modules:


```Swift
import SwiftUI
import SwiftOBD2
import Observation
```

2. ViewModel
    * Create a ViewModel class annotated with `@Observable`.
    * Inside the ViewModel:
        * Define properties for `measurements` and `connectionState`.
        * Initialize an OBDService instance.

3. Connection Handling
    * Observe `obdService.connectionState` directly.
    
4. Starting the Connection
    * Create a startConnection function to initiate the connection process with the OBD-II adapter.
    
5. Stopping the Connection
    * Create a stopConnection function to cleanly disconnect the service.
    
6. Retrieving Information
    * Use the OBDService's methods to retrieve data from the vehicle.
        * `scanForTroubleCodes()`: Retrieve confirmed DTCs.
        * `scanForPendingTroubleCodes()`: Retrieve pending DTCs.
        * `scanForPermanentTroubleCodes()`: Retrieve permanent DTCs.
        * `getStatus()`: Retrieves Status since DTCs cleared.
        * `getVehicleCalibrationID()`: Retrieves Calibration ID.
        * `getCVN()`: Retrieves Calibration Verification Number.
        * `getFreezeFrame(for:)`: Retrieves freeze frame data.

7. Continuous Updates
    * Use the startContinuousUpdates method to continuously poll and retrieve updated measurements from the vehicle via an `AsyncStream`.
    
### Code Example
```Swift
@Observable
class ViewModel {
    var measurements: [OBDCommand: MeasurementResult] = [:]

    var requestingPIDs: [OBDCommand] = [.mode1(.rpm)] {
        didSet {
            if let lastPID = requestingPIDs.last {
                addPID(command: lastPID)
            }
        }
    }
    
    let obdService = OBDService(connectionType: .bluetooth)

    var connectionState: ConnectionState {
        obdService.connectionState
    }

    func startContinousUpdates() {
        Task {
            for await measurements in obdService.startContinuousUpdates() {
                self.measurements = measurements
            }
        }
    }

    func addPID(command: OBDCommand) {
        Task {
            await obdService.addPID(command)
        }
    }

    func stopContinuousUpdates() {
        // Task cancellation logic if needed
    }

    func startConnection() async throws  {
        let obd2info = try await obdService.startConnection(preferredProtocol: .protocol6)
        print(obd2info)
    }

    func stopConnection() {
        obdService.stopConnection()
    }

    func switchConnectionType() {
        obdService.switchConnectionType(.wifi)
    }

    func getStatus() async {
        let status = try? await obdService.getStatus()
        print(status ?? "nil")
    }

    func getTroubleCodes() async {
        let troubleCodes = try? await obdService.scanForTroubleCodes()
        print(troubleCodes ?? "nil")
    }

    func getPendingCodes() async {
        let codes = try? await obdService.scanForPendingTroubleCodes()
        print(codes ?? "nil")
    }

    func getVehicleInfo() async {
        let calid = try? await obdService.getVehicleCalibrationID()
        let cvn = try? await obdService.getCVN()
        print("CALID: \(calid ?? "nil"), CVN: \(cvn ?? "nil")")
    }
}

struct ContentView: View {
    @State var viewModel = ViewModel()
    var body: some View {
        VStack(spacing: 20) {
            Text("Connection State: \(viewModel.connectionState.description)")
            ForEach(viewModel.requestingPIDs, id: \.self) { pid in
                Text("\(pid.properties.description): \(viewModel.measurements[pid]?.value ?? 0) \(viewModel.measurements[pid]?.unit.symbol ?? "")")
            }
            Button("Connect") {
                Task {
                    do {
                        try await viewModel.startConnection()
                        viewModel.startContinousUpdates()
                    } catch {
                        print(error)
                    }
                }
            }
            .buttonStyle(.bordered)

            Button("Stop") {
                viewModel.stopContinuousUpdates()
            }
            .buttonStyle(.bordered)

            Button("Add PID") {
                viewModel.requestingPIDs.append(.mode1(.speed))
            }
        }
        .padding()
    }
}

```

### Supported OBD2 Commands

A comprehensive list of supported OBD2 commands will be available in the full documentation (coming soon).

## 🛠️ Troubleshooting

### Common Issues

**Q: Bluetooth connection fails**
- Ensure Bluetooth permissions are granted in iOS Settings
- Verify your ELM327 adapter is in pairing mode
- Try restarting Bluetooth on your device

**Q: No data received from vehicle**
- Check that your vehicle is OBD2 compatible (1996+ in US)
- Ensure the ELM327 adapter is properly connected to the OBD2 port
- Verify the vehicle is running (some data requires engine on)

**Q: App crashes on connection**
- Update to the latest version of SwiftOBD2
- Check that you've added required Bluetooth permissions to Info.plist

### Hardware Compatibility

✅ **Tested ELM327 Adapters:**
- BAFX Products Bluetooth OBD2
- OBDLink MX+ Bluetooth
- VEEPEAK Mini WiFi OBD2

⚠️ **Known Issues:**
- Some cheap ELM327 clones may have connectivity issues
- WiFi adapters require network configuration

### Getting Help

- 📋 [Open an issue](https://github.com/kkonteh97/SwiftOBD2/issues) for bug reports
- 💡 [Start a discussion](https://github.com/kkonteh97/SwiftOBD2/discussions) for questions
- 📱 Check out the [sample app](https://github.com/kkonteh97/SwiftOBD2App) for implementation examples

### Important Considerations

* Ensure you have a compatible ELM327 OBD2 adapter.
* Permissions: If using Bluetooth, your app may need to request Bluetooth permissions from the user.
* Error Handling:  Implement robust error handling mechanisms to gracefully handle potential communication issues.
* Background Updates (Optional): If your app needs background OBD2 data updates, explore iOS background fetch capabilities and fine-tune your library and app to work effectively in the background.


## Contributing

This project welcomes your contributions! Feel free to open issues for bug reports or feature requests. To contribute code:

1. Fork the repository.
2. Create your feature branch.
3. Commit your changes with descriptive messages.
4. Submit a pull request for review.

## License

The Swift OBD package is distributed under the MIT license. See the [LICENSE](https://github.com/kkonteh97/SwiftOBD2/blob/main/LICENSE) file for more details.

---

## 💖 Support the Project

Love SwiftOBD2? Here's how you can help:

- ⭐ **Star this repository** - It really makes a difference!
- 🐛 **Report bugs** - Help us improve by reporting issues
- 💡 **Suggest features** - Share your ideas for new functionality  
- 🔀 **Contribute code** - Submit PRs for fixes and enhancements
- 📢 **Spread the word** - Share with other iOS/Swift developers

**Current Stars: 106+ and growing! 🚀**

[![Star History Chart](https://api.star-history.com/svg?repos=kkonteh97/SwiftOBD2&type=Date)](https://star-history.com/#kkonteh97/SwiftOBD2&Date)

### Related Projects

- [SwiftOBD2App](https://github.com/kkonteh97/SwiftOBD2App) - Sample iOS app demonstrating SwiftOBD2
- Want your project listed here? Open a PR!
