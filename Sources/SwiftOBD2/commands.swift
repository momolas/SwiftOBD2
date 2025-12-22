//
//  commands.swift
//  SmartOBD2
//
//  Created by kemo konteh on 9/14/23.
//

import Foundation

public extension DecodeResult {
//    var stringResult: String? {
//        if case let .stringResult(res) = self { return res as String }
//        return nil
//    }

    var statusResult: Status? {
        if case let .statusResult(res) = self { return res as Status }
        return nil
    }

    var measurementResult: MeasurementResult? {
        if case let .measurementResult(res) = self { return res as MeasurementResult }
        return nil
    }

    var troubleCode: [TroubleCode]? {
        if case let .troubleCode(res) = self { return res as [TroubleCode] }
        return nil
    }

    var measurementMonitor: Monitor? {
        if case let .measurementMonitor(res) = self { return res as Monitor }
        return nil
    }
}

public struct Mode2Wrapper: PID, Codable, Hashable {
    public let mode1: OBDCommand.Mode1

    public var command: String {
        return "02" + String(mode1.command.dropFirst(2))
    }

    public var description: String {
        return "Freeze Frame: " + mode1.description
    }

    public var bytes: Int {
        return mode1.bytes
    }

    public var decoder: Decoders {
        return mode1.decoder
    }

    public func decode(data: Data, unit: MeasurementUnit) -> Result<DecodeResult, DecodeError> {
        return mode1.decode(data: data, unit: unit)
    }
}

public enum OBDCommand: Codable, Hashable, Comparable, Identifiable {
    case general(General)
    case mode1(Mode1)
    case mode2(Mode1)
    case mode3(Mode3)
    case mode5(Mode5)
    case mode6(Mode6)
    case mode7(Mode7)
    case mode8(Mode8)
    case mode9(Mode9)
    case modeA(ModeA)
    case protocols(Protocols)
    case custom(CustomPID)
	
	public var id: Self { return self }

    public var properties: PID {
        switch self {
        case let .general(command):
            return command
        case let .mode1(command):
            return command
        case let .mode2(command):
            return Mode2Wrapper(mode1: command)
        case let .mode9(command):
            return command
        case let .mode6(command):
            return command
        case let .mode3(command):
            return command
        case let .mode5(command):
            return command
        case let .mode7(command):
            return command
        case let .mode8(command):
            return command
        case let .mode9(command):
            return command
        case let .modeA(command):
            return command
        case let .protocols(command):
            return command
        case let .custom(pid):
            return pid
        }
    }

    public enum General: CaseIterable, Codable, Comparable {
        case ATD
        case ATZ
        case ATRV
        case ATL0
        case ATE0
        case ATH1
        case ATH0
        case ATAT1
        case ATSTFF
        case ATDPN
    }

    public enum Protocols: CaseIterable, Codable, Comparable, PID {
        case ATSP0
        case ATSP6

        public var command: String {
            switch self {
            case .ATSP0: return "ATSP0"
            case .ATSP6: return "ATSP6"
            }
        }

        public var description: String {
            switch self {
            case .ATSP0: return "Auto protocol"
            case .ATSP6: return "Auto protocol"
            }
        }

        public var bytes: Int {
            return 0
        }

        public var decoder: Decoders {
            return .none
        }

        public func decode(data: Data, unit: MeasurementUnit) -> Result<DecodeResult, DecodeError> {
            return .failure(.unsupportedDecoder)
        }
    }

    public enum Mode1: CaseIterable, Codable, Comparable, PID {
        case pidsA
        case status
        case freezeDTC
        case fuelStatus
        case engineLoad
        case coolantTemp
        case shortFuelTrim1
        case longFuelTrim1
        case shortFuelTrim2
        case longFuelTrim2
        case fuelPressure
        case intakePressure
        case rpm
        case speed
        case timingAdvance
        case intakeTemp
        case maf
        case throttlePos
        case airStatus
        case O2Sensor
        case O2Bank1Sensor1
        case O2Bank1Sensor2
        case O2Bank1Sensor3
        case O2Bank1Sensor4
        case O2Bank2Sensor1
        case O2Bank2Sensor2
        case O2Bank2Sensor3
        case O2Bank2Sensor4
        case obdcompliance
        case O2SensorsALT
        case auxInputStatus
        case runTime
        case pidsB
        case distanceWMIL
        case fuelRailPressureVac
        case fuelRailPressureDirect
        case O2Sensor1WRVolatage
        case O2Sensor2WRVolatage
        case O2Sensor3WRVolatage
        case O2Sensor4WRVolatage
        case O2Sensor5WRVolatage
        case O2Sensor6WRVolatage
        case O2Sensor7WRVolatage
        case O2Sensor8WRVolatage
        case commandedEGR
        case EGRError
        case evaporativePurge
        case fuelLevel
        case warmUpsSinceDTCCleared
        case distanceSinceDTCCleared
        case evapVaporPressure
        case barometricPressure
        case O2Sensor1WRCurrent
        case O2Sensor2WRCurrent
        case O2Sensor3WRCurrent
        case O2Sensor4WRCurrent
        case O2Sensor5WRCurrent
        case O2Sensor6WRCurrent
        case O2Sensor7WRCurrent
        case O2Sensor8WRCurrent
        case catalystTempB1S1
        case catalystTempB2S1
        case catalystTempB1S2
        case catalystTempB2S2
        case pidsC
        case statusDriveCycle
        case controlModuleVoltage
        case absoluteLoad
        case commandedEquivRatio
        case relativeThrottlePos
        case ambientAirTemp
        case throttlePosB
        case throttlePosC
        case throttlePosD
        case throttlePosE
        case throttlePosF
        case throttleActuator
        case runTimeMIL
        case timeSinceDTCCleared
        case maxValues
        case maxMAF
        case fuelType
        case ethanoPercent
        case evapVaporPressureAbs
        case evapVaporPressureAlt
        case shortO2TrimB1
        case longO2TrimB1
        case shortO2TrimB2
        case longO2TrimB2
        case fuelRailPressureAbs
        case relativeAccelPos
        case hybridBatteryLife
        case engineOilTemp
        case fuelInjectionTiming
        case fuelRate
        case emissionsReq
    }

    public enum Mode3: CaseIterable, Codable, Comparable, PID {
        case GET_DTC

        public var command: String {
            switch self {
            case .GET_DTC: return "03"
            }
        }

        public var description: String {
            switch self {
            case .GET_DTC: return "Get DTCs"
            }
        }

        public var bytes: Int {
            return 0
        }

        public var decoder: Decoders {
            return .dtc
        }

        public func decode(data: Data, unit: MeasurementUnit) -> Result<DecodeResult, DecodeError> {
            return decoder.getDecoder()!.decode(data: data, unit: unit)
        }
    }

    public enum Mode4: CaseIterable, Codable, Comparable, PID {
        case CLEAR_DTC

        public var command: String {
            switch self {
            case .CLEAR_DTC: return "04"
            }
        }

        public var description: String {
            switch self {
            case .CLEAR_DTC: return "Clear DTCs and freeze data"
            }
        }

        public var bytes: Int {
            return 0
        }

        public var decoder: Decoders {
            return .none
        }

        public func decode(data: Data, unit: MeasurementUnit) -> Result<DecodeResult, DecodeError> {
            return .failure(.unsupportedDecoder)
        }
    }

    public enum Mode5: CaseIterable, Codable, Comparable, PID {
        case RTL_THRESHOLD_VOLTAGE
        case LTR_THRESHOLD_VOLTAGE
        case LOW_VOLTAGE_SWITCH_TIME
        case HIGH_VOLTAGE_SWITCH_TIME
        case RTL_SWITCH_TIME
        case LTR_SWITCH_TIME
        case MIN_VOLTAGE
        case MAX_VOLTAGE
        case TRANSITION_TIME

        public var command: String {
            switch self {
            case .RTL_THRESHOLD_VOLTAGE: return "0501"
            case .LTR_THRESHOLD_VOLTAGE: return "0502"
            case .LOW_VOLTAGE_SWITCH_TIME: return "0503"
            case .HIGH_VOLTAGE_SWITCH_TIME: return "0504"
            case .RTL_SWITCH_TIME: return "0505"
            case .LTR_SWITCH_TIME: return "0506"
            case .MIN_VOLTAGE: return "0507"
            case .MAX_VOLTAGE: return "0508"
            case .TRANSITION_TIME: return "0509"
            }
        }

        public var description: String {
            switch self {
            case .RTL_THRESHOLD_VOLTAGE: return "Rich to Lean Sensor Threshold Voltage"
            case .LTR_THRESHOLD_VOLTAGE: return "Lean to Rich Sensor Threshold Voltage"
            case .LOW_VOLTAGE_SWITCH_TIME: return "Low Sensor Voltage for Switch Time Calculation"
            case .HIGH_VOLTAGE_SWITCH_TIME: return "High Sensor Voltage for Switch Time Calculation"
            case .RTL_SWITCH_TIME: return "Rich to Lean Sensor Switch Time"
            case .LTR_SWITCH_TIME: return "Lean to Rich Sensor Switch Time"
            case .MIN_VOLTAGE: return "Minimum Sensor Voltage for Test Cycle"
            case .MAX_VOLTAGE: return "Maximum Sensor Voltage for Test Cycle"
            case .TRANSITION_TIME: return "Time between Sensor Transitions"
            }
        }

        public var bytes: Int {
            return 0 // Variable response
        }

        public var decoder: Decoders {
            return .monitor
        }

        public func decode(data: Data, unit: MeasurementUnit) -> Result<DecodeResult, DecodeError> {
            // Mode 5 decoding is complex and depends on ECU.
            // For now, using MonitorDecoder which handles similar structures?
            // Actually Mode 5 response includes TID, CID, Val, Min, Max.
            // MonitorDecoder is designed for Mode 6 but might work if structure is compatible.
            // I'll use a new case in Decoders or reuse MonitorDecoder.
            return decoder.getDecoder()!.decode(data: data, unit: unit)
        }
    }

    public enum Mode7: CaseIterable, Codable, Comparable, PID {
        case GET_PENDING_DTC

        public var command: String {
            switch self {
            case .GET_PENDING_DTC: return "07"
            }
        }

        public var description: String {
            switch self {
            case .GET_PENDING_DTC: return "Get Pending DTCs"
            }
        }

        public var bytes: Int {
            return 0
        }

        public var decoder: Decoders {
            return .dtc
        }

        public func decode(data: Data, unit: MeasurementUnit) -> Result<DecodeResult, DecodeError> {
            return decoder.getDecoder()!.decode(data: data, unit: unit)
        }
    }

    public enum Mode8: CaseIterable, Codable, Comparable, PID {
        case EVAP_LEAK_TEST

        public var command: String {
            switch self {
            case .EVAP_LEAK_TEST: return "0801"
            }
        }

        public var description: String {
            switch self {
            case .EVAP_LEAK_TEST: return "EVAP System Leak Test"
            }
        }

        public var bytes: Int {
            return 0
        }

        public var decoder: Decoders {
            return .none
        }

        public func decode(data: Data, unit: MeasurementUnit) -> Result<DecodeResult, DecodeError> {
            // Mode 8 response is usually just positive response (48 ...) or error
            // If we get data, it might be status.
            // For EVAP test, standard doesn't define specific data return other than success.
            return .success(.stringResult("Test Initiated"))
        }
    }

    public enum ModeA: CaseIterable, Codable, Comparable, PID {
        case GET_PERMANENT_DTC

        public var command: String {
            switch self {
            case .GET_PERMANENT_DTC: return "0A"
            }
        }

        public var description: String {
            switch self {
            case .GET_PERMANENT_DTC: return "Get Permanent DTCs"
            }
        }

        public var bytes: Int {
            return 0
        }

        public var decoder: Decoders {
            return .dtc
        }

        public func decode(data: Data, unit: MeasurementUnit) -> Result<DecodeResult, DecodeError> {
            return decoder.getDecoder()!.decode(data: data, unit: unit)
        }
    }

    public enum Mode6: CaseIterable, Codable, Comparable, PID {
        case MIDS_A
        case MONITOR_O2_B1S1
        case MONITOR_O2_B1S2
        case MONITOR_O2_B1S3
        case MONITOR_O2_B1S4
        case MONITOR_O2_B2S1
        case MONITOR_O2_B2S2
        case MONITOR_O2_B2S3
        case MONITOR_O2_B2S4
        case MONITOR_O2_B3S1
        case MONITOR_O2_B3S2
        case MONITOR_O2_B3S3
        case MONITOR_O2_B3S4
        case MONITOR_O2_B4S1
        case MONITOR_O2_B4S2
        case MONITOR_O2_B4S3
        case MONITOR_O2_B4S4
        case MIDS_B
        case MONITOR_CATALYST_B1
        case MONITOR_CATALYST_B2
        case MONITOR_CATALYST_B3
        case MONITOR_CATALYST_B4
        case MONITOR_EGR_B1
        case MONITOR_EGR_B2
        case MONITOR_EGR_B3
        case MONITOR_EGR_B4
        case MONITOR_VVT_B1
        case MONITOR_VVT_B2
        case MONITOR_VVT_B3
        case MONITOR_VVT_B4
        case MONITOR_EVAP_150
        case MONITOR_EVAP_090
        case MONITOR_EVAP_040
        case MONITOR_EVAP_020
        case MONITOR_PURGE_FLOW
        case MIDS_C
        case MONITOR_O2_HEATER_B1S1
        case MONITOR_O2_HEATER_B1S2
        case MONITOR_O2_HEATER_B1S3
        case MONITOR_O2_HEATER_B1S4
        case MONITOR_O2_HEATER_B2S1
        case MONITOR_O2_HEATER_B2S2
        case MONITOR_O2_HEATER_B2S3
        case MONITOR_O2_HEATER_B2S4
        case MONITOR_O2_HEATER_B3S1
        case MONITOR_O2_HEATER_B3S2
        case MONITOR_O2_HEATER_B3S3
        case MONITOR_O2_HEATER_B3S4
        case MONITOR_O2_HEATER_B4S1
        case MONITOR_O2_HEATER_B4S2
        case MONITOR_O2_HEATER_B4S3
        case MONITOR_O2_HEATER_B4S4
        case MIDS_D
        case MONITOR_HEATED_CATALYST_B1
        case MONITOR_HEATED_CATALYST_B2
        case MONITOR_HEATED_CATALYST_B3
        case MONITOR_HEATED_CATALYST_B4
        case MONITOR_SECONDARY_AIR_1
        case MONITOR_SECONDARY_AIR_2
        case MONITOR_SECONDARY_AIR_3
        case MONITOR_SECONDARY_AIR_4
        case MIDS_E
        case MONITOR_FUEL_SYSTEM_B1
        case MONITOR_FUEL_SYSTEM_B2
        case MONITOR_FUEL_SYSTEM_B3
        case MONITOR_FUEL_SYSTEM_B4
        case MONITOR_BOOST_PRESSURE_B1
        case MONITOR_BOOST_PRESSURE_B2
        case MONITOR_NOX_ABSORBER_B1
        case MONITOR_NOX_ABSORBER_B2
        case MONITOR_NOX_CATALYST_B1
        case MONITOR_NOX_CATALYST_B2
        case MIDS_F
        case MONITOR_MISFIRE_GENERAL
        case MONITOR_MISFIRE_CYLINDER_1
        case MONITOR_MISFIRE_CYLINDER_2
        case MONITOR_MISFIRE_CYLINDER_3
        case MONITOR_MISFIRE_CYLINDER_4
        case MONITOR_MISFIRE_CYLINDER_5
        case MONITOR_MISFIRE_CYLINDER_6
        case MONITOR_MISFIRE_CYLINDER_7
        case MONITOR_MISFIRE_CYLINDER_8
        case MONITOR_MISFIRE_CYLINDER_9
        case MONITOR_MISFIRE_CYLINDER_10
        case MONITOR_MISFIRE_CYLINDER_11
        case MONITOR_MISFIRE_CYLINDER_12
        case MONITOR_PM_FILTER_B1
        case MONITOR_PM_FILTER_B2
    }

    public enum Mode9: CaseIterable, Codable, Comparable, PID {
        case PIDS_9A
        case VIN_MESSAGE_COUNT
        case VIN
        case CALIBRATION_ID_MESSAGE_COUNT
        case CALIBRATION_ID
        case CVN_MESSAGE_COUNT
        case CVN

        public var command: String {
            switch self {
            case .PIDS_9A: return "0900"
            case .VIN_MESSAGE_COUNT: return "0901"
            case .VIN: return "0902"
            case .CALIBRATION_ID_MESSAGE_COUNT: return "0903"
            case .CALIBRATION_ID: return "0904"
            case .CVN_MESSAGE_COUNT: return "0905"
            case .CVN: return "0906"
            }
        }

        public var description: String {
            switch self {
            case .PIDS_9A: return "Supported PIDs [01-20]"
            case .VIN_MESSAGE_COUNT: return "VIN Message Count"
            case .VIN: return "Vehicle Identification Number"
            case .CALIBRATION_ID_MESSAGE_COUNT: return "Calibration ID message count for PID 04"
            case .CALIBRATION_ID: return "Calibration ID"
            case .CVN_MESSAGE_COUNT: return "CVN Message Count for PID 06"
            case .CVN: return "Calibration Verification Numbers"
            }
        }

        public var bytes: Int {
            switch self {
            case .PIDS_9A: return 7
            case .VIN_MESSAGE_COUNT: return 3
            case .VIN: return 22
            case .CALIBRATION_ID_MESSAGE_COUNT: return 3
            case .CALIBRATION_ID: return 18
            case .CVN_MESSAGE_COUNT: return 3
            case .CVN: return 10
            }
        }

    public var decoder: Decoders {
        switch self {
        case .PIDS_9A: return .pid
        case .VIN_MESSAGE_COUNT: return .count
        case .VIN: return .encoded_string
        case .CALIBRATION_ID_MESSAGE_COUNT: return .count
        case .CALIBRATION_ID: return .encoded_string
        case .CVN_MESSAGE_COUNT: return .count
        case .CVN: return .cvn
        }
    }

    public func decode(data: Data, unit: MeasurementUnit) -> Result<DecodeResult, DecodeError> {
        return decoder.getDecoder()!.decode(data: data, unit: unit)
        }
    }

    nonisolated(unsafe) static let pidGetters: [OBDCommand] = {
        var getters: [OBDCommand] = []
        for command in OBDCommand.Mode1.allCases {
            if case .pid = command.decoder {
                getters.append(.mode1(command))
            }
        }

        for command in OBDCommand.Mode6.allCases {
            if case .pid = command.decoder {
                getters.append(.mode6(command))
            }
        }

        for command in OBDCommand.Mode9.allCases {
            if case .pid = command.decoder {
                getters.append(.mode9(command))
            }
        }
        return getters
    }()

    nonisolated(unsafe) static public let allCommands: [OBDCommand] = {
        var commands: [OBDCommand] = []
        for command in OBDCommand.General.allCases {
            commands.append(.general(command))
        }

        for command in OBDCommand.Mode1.allCases {
            commands.append(.mode1(command))
        }

        for command in OBDCommand.Mode1.allCases {
            commands.append(.mode2(command))
        }

        for command in OBDCommand.Mode3.allCases {
            commands.append(.mode3(command))
        }

        for command in OBDCommand.Mode5.allCases {
            commands.append(.mode5(command))
        }

        for command in OBDCommand.Mode6.allCases {
            commands.append(.mode6(command))
        }

        for command in OBDCommand.Mode7.allCases {
            commands.append(.mode7(command))
        }

        for command in OBDCommand.Mode8.allCases {
            commands.append(.mode8(command))
        }

        for command in OBDCommand.Mode9.allCases {
            commands.append(.mode9(command))
        }

        for command in OBDCommand.ModeA.allCases {
            commands.append(.modeA(command))
        }
        for command in OBDCommand.Protocols.allCases {
            commands.append(.protocols(command))
        }
        return commands
    }()
}

extension OBDCommand.General: PID {
    public var command: String {
        switch self {
        case .ATD: return "ATD"
        case .ATZ: return "ATZ"
        case .ATRV: return "ATRV"
        case .ATL0: return "ATL0"
        case .ATE0: return "ATE0"
        case .ATH1: return "ATH1"
        case .ATH0: return "ATH0"
        case .ATAT1: return "ATAT1"
        case .ATSTFF: return "ATSTFF"
        case .ATDPN: return "ATDPN"
        }
    }

    public var description: String {
        switch self {
        case .ATD: return "Set to default"
        case .ATZ: return "Reset"
        case .ATRV: return "Voltage"
        case .ATL0: return "Linefeeds Off"
        case .ATE0: return "Echo Off"
        case .ATH1: return "Headers On"
        case .ATH0: return "Headers Off"
        case .ATAT1: return "Adaptive Timing On"
        case .ATSTFF: return "Set Time to Fast"
        case .ATDPN: return "Describe Protocol Number"
        }
    }

    public var bytes: Int {
        return 5
    }

    public var decoder: Decoders {
        return .none
    }

    public func decode(data: Data, unit: MeasurementUnit) -> Result<DecodeResult, DecodeError> {
        return .failure(.unsupportedDecoder)
    }
}

extension OBDCommand.Mode1 {
    public var command: String {
        switch self {
        case .pidsA: return "0100"
        case .status: return "0101"
        case .freezeDTC: return "0102"
        case .fuelStatus: return "0103"
        case .engineLoad: return "0104"
        case .coolantTemp: return "0105"
        case .shortFuelTrim1: return "0106"
        case .longFuelTrim1: return "0107"
        case .shortFuelTrim2: return "0108"
        case .longFuelTrim2: return "0109"
        case .fuelPressure: return "010A"
        case .intakePressure: return "010B"
        case .rpm: return "010C"
        case .speed: return "010D"
        case .timingAdvance: return "010E"
        case .intakeTemp: return "010F"
        case .maf: return "0110"
        case .throttlePos: return "0111"
        case .airStatus: return "0112"
        case .O2Sensor: return "0113"
        case .O2Bank1Sensor1: return "0114"
        case .O2Bank1Sensor2: return "0115"
        case .O2Bank1Sensor3: return "0116"
        case .O2Bank1Sensor4: return "0117"
        case .O2Bank2Sensor1: return "0118"
        case .O2Bank2Sensor2: return "0119"
        case .O2Bank2Sensor3: return "011A"
        case .O2Bank2Sensor4: return "011B"
        case .obdcompliance: return "011C"
        case .O2SensorsALT: return "011D"
        case .auxInputStatus: return "011E"
        case .runTime: return "011F"
        case .pidsB: return "0120"
        case .distanceWMIL: return "0121"
        case .fuelRailPressureVac: return "0122"
        case .fuelRailPressureDirect: return "0123"
        case .O2Sensor1WRVolatage: return "0124"
        case .O2Sensor2WRVolatage: return "0125"
        case .O2Sensor3WRVolatage: return "0126"
        case .O2Sensor4WRVolatage: return "0127"
        case .O2Sensor5WRVolatage: return "0128"
        case .O2Sensor6WRVolatage: return "0129"
        case .O2Sensor7WRVolatage: return "012A"
        case .O2Sensor8WRVolatage: return "012B"
        case .commandedEGR: return "012C"
        case .EGRError: return "012D"
        case .evaporativePurge: return "012E"
        case .fuelLevel: return "012F"
        case .warmUpsSinceDTCCleared: return "0130"
        case .distanceSinceDTCCleared: return "0131"
        case .evapVaporPressure: return "0132"
        case .barometricPressure: return "0133"
        case .O2Sensor1WRCurrent: return "0134"
        case .O2Sensor2WRCurrent: return "0135"
        case .O2Sensor3WRCurrent: return "0136"
        case .O2Sensor4WRCurrent: return "0137"
        case .O2Sensor5WRCurrent: return "0138"
        case .O2Sensor6WRCurrent: return "0139"
        case .O2Sensor7WRCurrent: return "013A"
        case .O2Sensor8WRCurrent: return "013B"
        case .catalystTempB1S1: return "013C"
        case .catalystTempB2S1: return "013D"
        case .catalystTempB1S2: return "013E"
        case .catalystTempB2S2: return "013F"
        case .pidsC: return "0140"
        case .statusDriveCycle: return "0141"
        case .controlModuleVoltage: return "0142"
        case .absoluteLoad: return "0143"
        case .commandedEquivRatio: return "0144"
        case .relativeThrottlePos: return "0145"
        case .ambientAirTemp: return "0146"
        case .throttlePosB: return "0147"
        case .throttlePosC: return "0148"
        case .throttlePosD: return "0149"
        case .throttlePosE: return "014A"
        case .throttlePosF: return "014B"
        case .throttleActuator: return "014C"
        case .runTimeMIL: return "014D"
        case .timeSinceDTCCleared: return "014E"
        case .maxValues: return "014F"
        case .maxMAF: return "0150"
        case .fuelType: return "0151"
        case .ethanoPercent: return "0152"
        case .evapVaporPressureAbs: return "0153"
        case .evapVaporPressureAlt: return "0154"
        case .shortO2TrimB1: return "0155"
        case .longO2TrimB1: return "0156"
        case .shortO2TrimB2: return "0157"
        case .longO2TrimB2: return "0158"
        case .fuelRailPressureAbs: return "0159"
        case .relativeAccelPos: return "015A"
        case .hybridBatteryLife: return "015B"
        case .engineOilTemp: return "015C"
        case .fuelInjectionTiming: return "015D"
        case .fuelRate: return "015E"
        case .emissionsReq: return "015F"
        }
    }

    public var description: String {
        switch self {
        case .pidsA: return "Supported PIDs [01-20]"
        case .status: return "Status since DTCs cleared"
        case .freezeDTC: return "DTC that triggered the freeze frame"
        case .fuelStatus: return "Fuel System Status"
        case .engineLoad: return "Calculated Engine Load"
        case .coolantTemp: return "Coolant temperature"
        case .shortFuelTrim1: return "Short Term Fuel Trim - Bank 1"
        case .longFuelTrim1: return "Long Term Fuel Trim - Bank 1"
        case .shortFuelTrim2: return "Short Term Fuel Trim - Bank 2"
        case .longFuelTrim2: return "Long Term Fuel Trim - Bank 2"
        case .fuelPressure: return "Fuel Pressure"
        case .intakePressure: return "Intake Manifold Pressure"
        case .rpm: return "RPM"
        case .speed: return "Vehicle Speed"
        case .timingAdvance: return "Timing Advance"
        case .intakeTemp: return "Intake Air Temp"
        case .maf: return "Air Flow Rate (MAF)"
        case .throttlePos: return "Throttle Position"
        case .airStatus: return "Secondary Air Status"
        case .O2Sensor: return "O2 Sensors Present"
        case .O2Bank1Sensor1: return "O2: Bank 1 - Sensor 1 Voltage"
        case .O2Bank1Sensor2: return "O2: Bank 1 - Sensor 2 Voltage"
        case .O2Bank1Sensor3: return "O2: Bank 1 - Sensor 3 Voltage"
        case .O2Bank1Sensor4: return "O2: Bank 1 - Sensor 4 Voltage"
        case .O2Bank2Sensor1: return "O2: Bank 2 - Sensor 1 Voltage"
        case .O2Bank2Sensor2: return "O2: Bank 2 - Sensor 2 Voltage"
        case .O2Bank2Sensor3: return "O2: Bank 2 - Sensor 3 Voltage"
        case .O2Bank2Sensor4: return "O2: Bank 2 - Sensor 4 Voltage"
        case .obdcompliance: return "OBD Standards Compliance"
        case .O2SensorsALT: return "O2 Sensors Present (alternate)"
        case .auxInputStatus: return "Auxiliary input status (power take off)"
        case .runTime: return "Engine Run Time"
        case .pidsB: return "Supported PIDs [21-40]"
        case .distanceWMIL: return "Distance Traveled with MIL on"
        case .fuelRailPressureVac: return "Fuel Rail Pressure (relative to vacuum)"
        case .fuelRailPressureDirect: return "Fuel Rail Pressure (direct inject)"
        case .O2Sensor1WRVolatage: return "02 Sensor 1 WR Lambda Voltage"
        case .O2Sensor2WRVolatage: return "02 Sensor 2 WR Lambda Voltage"
        case .O2Sensor3WRVolatage: return "02 Sensor 3 WR Lambda Voltage"
        case .O2Sensor4WRVolatage: return "02 Sensor 4 WR Lambda Voltage"
        case .O2Sensor5WRVolatage: return "02 Sensor 5 WR Lambda Voltage"
        case .O2Sensor6WRVolatage: return "02 Sensor 6 WR Lambda Voltage"
        case .O2Sensor7WRVolatage: return "02 Sensor 7 WR Lambda Voltage"
        case .O2Sensor8WRVolatage: return "02 Sensor 8 WR Lambda Voltage"
        case .commandedEGR: return "Commanded EGR"
        case .EGRError: return "EGR Error"
        case .evaporativePurge: return "Commanded Evaporative Purge"
        case .fuelLevel: return "Fuel Tank Level Input"
        case .warmUpsSinceDTCCleared: return "Number of warm-ups since codes cleared"
        case .distanceSinceDTCCleared: return "Distance traveled since codes cleared"
        case .evapVaporPressure: return "Evaporative system vapor pressure"
        case .barometricPressure: return "Barometric Pressure"
        case .O2Sensor1WRCurrent: return "02 Sensor 1 WR Lambda Current"
        case .O2Sensor2WRCurrent: return "02 Sensor 2 WR Lambda Current"
        case .O2Sensor3WRCurrent: return "02 Sensor 3 WR Lambda Current"
        case .O2Sensor4WRCurrent: return "02 Sensor 4 WR Lambda Current"
        case .O2Sensor5WRCurrent: return "02 Sensor 5 WR Lambda Current"
        case .O2Sensor6WRCurrent: return "02 Sensor 6 WR Lambda Current"
        case .O2Sensor7WRCurrent: return "02 Sensor 7 WR Lambda Current"
        case .O2Sensor8WRCurrent: return "02 Sensor 8 WR Lambda Current"
        case .catalystTempB1S1: return "Catalyst Temperature: Bank 1 - Sensor 1"
        case .catalystTempB2S1: return "Catalyst Temperature: Bank 2 - Sensor 1"
        case .catalystTempB1S2: return "Catalyst Temperature: Bank 1 - Sensor 2"
        case .catalystTempB2S2: return "Catalyst Temperature: Bank 1 - Sensor 2"
        case .pidsC: return "Supported PIDs [41-60]"
        case .statusDriveCycle: return "Monitor status this drive cycle"
        case .controlModuleVoltage: return "Control module voltage"
        case .absoluteLoad: return "Absolute load value"
        case .commandedEquivRatio: return "Commanded equivalence ratio"
        case .relativeThrottlePos: return "Relative throttle position"
        case .ambientAirTemp: return "Ambient air temperature"
        case .throttlePosB: return "Absolute throttle position B"
        case .throttlePosC: return "Absolute throttle position C"
        case .throttlePosD: return "Absolute throttle position D"
        case .throttlePosE: return "Absolute throttle position E"
        case .throttlePosF: return "Absolute throttle position F"
        case .throttleActuator: return "Commanded throttle actuator"
        case .runTimeMIL: return "Time run with MIL on"
        case .timeSinceDTCCleared: return "Time since trouble codes cleared"
        case .maxValues: return "Maximum value for various values"
        case .maxMAF: return "Maximum value for air flow rate from mass air flow sensor"
        case .fuelType: return "Fuel Type"
        case .ethanoPercent: return "Ethanol fuel %"
        case .evapVaporPressureAbs: return "Absolute Evap system vapor pressure"
        case .evapVaporPressureAlt: return "Evap system vapor pressure"
        case .shortO2TrimB1: return "Short term secondary O2 trim - Bank 1"
        case .longO2TrimB1: return "Long term secondary O2 trim - Bank 1"
        case .shortO2TrimB2: return "Short term secondary O2 trim - Bank 2"
        case .longO2TrimB2: return "Long term secondary O2 trim - Bank 2"
        case .fuelRailPressureAbs: return "Fuel rail pressure (absolute)"
        case .relativeAccelPos: return "Relative accelerator pedal position"
        case .hybridBatteryLife: return "Hybrid battery pack remaining life"
        case .engineOilTemp: return "Engine oil temperature"
        case .fuelInjectionTiming: return "Fuel injection timing"
        case .fuelRate: return "Engine fuel rate"
        case .emissionsReq: return "Designed emission requirements"
        }
    }

    public var bytes: Int {
        switch self {
        case .pidsA: return 5
        case .status: return 5
        case .freezeDTC: return 5
        case .fuelStatus: return 5
        case .engineLoad: return 2
        case .coolantTemp: return 2
        case .shortFuelTrim1: return 2
        case .longFuelTrim1: return 2
        case .shortFuelTrim2: return 2
        case .longFuelTrim2: return 2
        case .fuelPressure: return 2
        case .intakePressure: return 3
        case .rpm: return 3
        case .speed: return 2
        case .timingAdvance: return 2
        case .intakeTemp: return 2
        case .maf: return 3
        case .throttlePos: return 2
        case .airStatus: return 2
        case .O2Sensor: return 2
        case .O2Bank1Sensor1: return 3
        case .O2Bank1Sensor2: return 3
        case .O2Bank1Sensor3: return 3
        case .O2Bank1Sensor4: return 3
        case .O2Bank2Sensor1: return 3
        case .O2Bank2Sensor2: return 3
        case .O2Bank2Sensor3: return 3
        case .O2Bank2Sensor4: return 3
        case .obdcompliance: return 2
        case .O2SensorsALT: return 2
        case .auxInputStatus: return 2
        case .runTime: return 3
        case .pidsB: return 5
        case .distanceWMIL: return 4
        case .fuelRailPressureVac: return 4
        case .fuelRailPressureDirect: return 4
        case .O2Sensor1WRVolatage: return 6
        case .O2Sensor2WRVolatage: return 6
        case .O2Sensor3WRVolatage: return 6
        case .O2Sensor4WRVolatage: return 6
        case .O2Sensor5WRVolatage: return 6
        case .O2Sensor6WRVolatage: return 6
        case .O2Sensor7WRVolatage: return 6
        case .O2Sensor8WRVolatage: return 6
        case .commandedEGR: return 4
        case .EGRError: return 4
        case .evaporativePurge: return 4
        case .fuelLevel: return 4
        case .warmUpsSinceDTCCleared: return 4
        case .distanceSinceDTCCleared: return 4
        case .evapVaporPressure: return 4
        case .barometricPressure: return 4
        case .O2Sensor1WRCurrent: return 4
        case .O2Sensor2WRCurrent: return 4
        case .O2Sensor3WRCurrent: return 4
        case .O2Sensor4WRCurrent: return 4
        case .O2Sensor5WRCurrent: return 4
        case .O2Sensor6WRCurrent: return 4
        case .O2Sensor7WRCurrent: return 4
        case .O2Sensor8WRCurrent: return 4
        case .catalystTempB1S1: return 4
        case .catalystTempB2S1: return 4
        case .catalystTempB1S2: return 4
        case .catalystTempB2S2: return 4
        case .pidsC: return 6
        case .statusDriveCycle: return 6
        case .controlModuleVoltage: return 4
        case .absoluteLoad: return 4
        case .commandedEquivRatio: return 4
        case .relativeThrottlePos: return 4
        case .ambientAirTemp: return 4
        case .throttlePosB: return 4
        case .throttlePosC: return 4
        case .throttlePosD: return 4
        case .throttlePosE: return 4
        case .throttlePosF: return 4
        case .throttleActuator: return 4
        case .runTimeMIL: return 4
        case .timeSinceDTCCleared: return 4
        case .maxValues: return 6
        case .maxMAF: return 4
        case .fuelType: return 2
        case .ethanoPercent: return 2
        case .evapVaporPressureAbs: return 4
        case .evapVaporPressureAlt: return 4
        case .shortO2TrimB1: return 4
        case .longO2TrimB1: return 4
        case .shortO2TrimB2: return 4
        case .longO2TrimB2: return 4
        case .fuelRailPressureAbs: return 4
        case .relativeAccelPos: return 3
        case .hybridBatteryLife: return 3
        case .engineOilTemp: return 3
        case .fuelInjectionTiming: return 4
        case .fuelRate: return 4
        case .emissionsReq: return 3
        }
    }

    public var decoder: Decoders {
        switch self {
        case .pidsA: return .pid
        case .status: return .status
        case .freezeDTC: return .singleDTC
        case .fuelStatus: return .fuelStatus
        case .engineLoad: return .percent
        case .coolantTemp: return .temp
        case .shortFuelTrim1: return .percentCentered
        case .longFuelTrim1: return .percentCentered
        case .shortFuelTrim2: return .percentCentered
        case .longFuelTrim2: return .percentCentered
        case .fuelPressure: return .fuelPressure
        case .intakePressure: return .pressure
        case .rpm: return .uas(0x07)
        case .speed: return .uas(0x09)
        case .timingAdvance: return .timingAdvance
        case .intakeTemp: return .temp
        case .maf: return .uas(0x27)
        case .throttlePos: return .percent
        case .airStatus: return .airStatus
        case .O2Sensor: return .o2Sensors
        case .O2Bank1Sensor1: return .sensorVoltage
        case .O2Bank1Sensor2: return .sensorVoltage
        case .O2Bank1Sensor3: return .sensorVoltage
        case .O2Bank1Sensor4: return .sensorVoltage
        case .O2Bank2Sensor1: return .sensorVoltage
        case .O2Bank2Sensor2: return .sensorVoltage
        case .O2Bank2Sensor3: return .sensorVoltage
        case .O2Bank2Sensor4: return .sensorVoltage
        case .obdcompliance: return .obdCompliance
        case .O2SensorsALT: return .o2SensorsAlt
        case .auxInputStatus: return .auxInputStatus
        case .runTime: return .uas(0x12)
        case .pidsB: return .pid
        case .distanceWMIL: return .uas(0x25)
        case .fuelRailPressureVac: return .uas(0x19)
        case .fuelRailPressureDirect: return .uas(0x1B)
        case .O2Sensor1WRVolatage: return .sensorVoltageBig
        case .O2Sensor2WRVolatage: return .sensorVoltageBig
        case .O2Sensor3WRVolatage: return .sensorVoltageBig
        case .O2Sensor4WRVolatage: return .sensorVoltageBig
        case .O2Sensor5WRVolatage: return .sensorVoltageBig
        case .O2Sensor6WRVolatage: return .sensorVoltageBig
        case .O2Sensor7WRVolatage: return .sensorVoltageBig
        case .O2Sensor8WRVolatage: return .sensorVoltageBig
        case .commandedEGR: return .percent
        case .EGRError: return .percentCentered
        case .evaporativePurge: return .percent
        case .fuelLevel: return .percent
        case .warmUpsSinceDTCCleared: return .uas(0x01)
        case .distanceSinceDTCCleared: return .uas(0x25)
        case .evapVaporPressure: return .evapPressure
        case .barometricPressure: return .pressure
        case .O2Sensor1WRCurrent: return .currentCentered
        case .O2Sensor2WRCurrent: return .currentCentered
        case .O2Sensor3WRCurrent: return .currentCentered
        case .O2Sensor4WRCurrent: return .currentCentered
        case .O2Sensor5WRCurrent: return .currentCentered
        case .O2Sensor6WRCurrent: return .currentCentered
        case .O2Sensor7WRCurrent: return .currentCentered
        case .O2Sensor8WRCurrent: return .currentCentered
        case .catalystTempB1S1: return .uas(0x16)
        case .catalystTempB2S1: return .uas(0x16)
        case .catalystTempB1S2: return .uas(0x16)
        case .catalystTempB2S2: return .uas(0x16)
        case .pidsC: return .pid
        case .statusDriveCycle: return .status
        case .controlModuleVoltage: return .uas(0x0B)
        case .absoluteLoad: return .percent
        case .commandedEquivRatio: return .uas(0x1E)
        case .relativeThrottlePos: return .percent
        case .ambientAirTemp: return .temp
        case .throttlePosB: return .percent
        case .throttlePosC: return .percent
        case .throttlePosD: return .percent
        case .throttlePosE: return .percent
        case .throttlePosF: return .percent
        case .throttleActuator: return .percent
        case .runTimeMIL: return .uas(0x34)
        case .timeSinceDTCCleared: return .uas(0x34)
        case .maxValues: return .none
        case .maxMAF: return .maxMaf
        case .fuelType: return .fuelType
        case .ethanoPercent: return .percent
        case .evapVaporPressureAbs: return .evapPressureAlt
        case .evapVaporPressureAlt: return .evapPressureAlt
        case .shortO2TrimB1: return .percentCentered
        case .longO2TrimB1: return .percentCentered
        case .shortO2TrimB2: return .percentCentered
        case .longO2TrimB2: return .percentCentered
        case .fuelRailPressureAbs: return .uas(0x1B)
        case .relativeAccelPos: return .percent
        case .hybridBatteryLife: return .percent
        case .engineOilTemp: return .temp
        case .fuelInjectionTiming: return .injectTiming
        case .fuelRate: return .fuelRate
        case .emissionsReq: return .none
        }
    }

    public func decode(data: Data, unit: MeasurementUnit) -> Result<DecodeResult, DecodeError> {
        return decoder.getDecoder()!.decode(data: data, unit: unit)
    }
}

extension OBDCommand.Mode6 {
    public var command: String {
        switch self {
        case .MIDS_A: return "0600"
        case .MONITOR_O2_B1S1: return "0601"
        case .MONITOR_O2_B1S2: return "0602"
        case .MONITOR_O2_B1S3: return "0603"
        case .MONITOR_O2_B1S4: return "0604"
        case .MONITOR_O2_B2S1: return "0605"
        case .MONITOR_O2_B2S2: return "0606"
        case .MONITOR_O2_B2S3: return "0607"
        case .MONITOR_O2_B2S4: return "0608"
        case .MONITOR_O2_B3S1: return "0609"
        case .MONITOR_O2_B3S2: return "060A"
        case .MONITOR_O2_B3S3: return "060B"
        case .MONITOR_O2_B3S4: return "060C"
        case .MONITOR_O2_B4S1: return "060D"
        case .MONITOR_O2_B4S2: return "060E"
        case .MONITOR_O2_B4S3: return "060F"
        case .MONITOR_O2_B4S4: return "0610"
        case .MIDS_B: return "0620"
        case .MONITOR_CATALYST_B1: return "0621"
        case .MONITOR_CATALYST_B2: return "0622"
        case .MONITOR_CATALYST_B3: return "0623"
        case .MONITOR_CATALYST_B4: return "0624"
        case .MONITOR_EGR_B1: return "0631"
        case .MONITOR_EGR_B2: return "0632"
        case .MONITOR_EGR_B3: return "0633"
        case .MONITOR_EGR_B4: return "0634"
        case .MONITOR_VVT_B1: return "0635"
        case .MONITOR_VVT_B2: return "0636"
        case .MONITOR_VVT_B3: return "0637"
        case .MONITOR_VVT_B4: return "0638"
        case .MONITOR_EVAP_150: return "0639"
        case .MONITOR_EVAP_090: return "063A"
        case .MONITOR_EVAP_040: return "063B"
        case .MONITOR_EVAP_020: return "063C"
        case .MONITOR_PURGE_FLOW: return "063D"
        case .MIDS_C: return "0640"
        case .MONITOR_O2_HEATER_B1S1: return "0641"
        case .MONITOR_O2_HEATER_B1S2: return "0642"
        case .MONITOR_O2_HEATER_B1S3: return "0643"
        case .MONITOR_O2_HEATER_B1S4: return "0644"
        case .MONITOR_O2_HEATER_B2S1: return "0645"
        case .MONITOR_O2_HEATER_B2S2: return "0646"
        case .MONITOR_O2_HEATER_B2S3: return "0647"
        case .MONITOR_O2_HEATER_B2S4: return "0648"
        case .MONITOR_O2_HEATER_B3S1: return "0649"
        case .MONITOR_O2_HEATER_B3S2: return "064A"
        case .MONITOR_O2_HEATER_B3S3: return "064B"
        case .MONITOR_O2_HEATER_B3S4: return "064C"
        case .MONITOR_O2_HEATER_B4S1: return "064D"
        case .MONITOR_O2_HEATER_B4S2: return "064E"
        case .MONITOR_O2_HEATER_B4S3: return "064F"
        case .MONITOR_O2_HEATER_B4S4: return "0650"
        case .MIDS_D: return "0660"
        case .MONITOR_HEATED_CATALYST_B1: return "0661"
        case .MONITOR_HEATED_CATALYST_B2: return "0662"
        case .MONITOR_HEATED_CATALYST_B3: return "0663"
        case .MONITOR_HEATED_CATALYST_B4: return "0664"
        case .MONITOR_SECONDARY_AIR_1: return "0671"
        case .MONITOR_SECONDARY_AIR_2: return "0672"
        case .MONITOR_SECONDARY_AIR_3: return "0673"
        case .MONITOR_SECONDARY_AIR_4: return "0674"
        case .MIDS_E: return "0680"
        case .MONITOR_FUEL_SYSTEM_B1: return "0681"
        case .MONITOR_FUEL_SYSTEM_B2: return "0682"
        case .MONITOR_FUEL_SYSTEM_B3: return "0683"
        case .MONITOR_FUEL_SYSTEM_B4: return "0684"
        case .MONITOR_BOOST_PRESSURE_B1: return "0685"
        case .MONITOR_BOOST_PRESSURE_B2: return "0686"
        case .MONITOR_NOX_ABSORBER_B1: return "0690"
        case .MONITOR_NOX_ABSORBER_B2: return "0691"
        case .MONITOR_NOX_CATALYST_B1: return "0698"
        case .MONITOR_NOX_CATALYST_B2: return "0699"
        case .MIDS_F: return "06A0"
        case .MONITOR_MISFIRE_GENERAL: return "06A1"
        case .MONITOR_MISFIRE_CYLINDER_1: return "06A2"
        case .MONITOR_MISFIRE_CYLINDER_2: return "06A3"
        case .MONITOR_MISFIRE_CYLINDER_3: return "06A4"
        case .MONITOR_MISFIRE_CYLINDER_4: return "06A5"
        case .MONITOR_MISFIRE_CYLINDER_5: return "06A6"
        case .MONITOR_MISFIRE_CYLINDER_6: return "06A7"
        case .MONITOR_MISFIRE_CYLINDER_7: return "06A8"
        case .MONITOR_MISFIRE_CYLINDER_8: return "06A9"
        case .MONITOR_MISFIRE_CYLINDER_9: return "06AA"
        case .MONITOR_MISFIRE_CYLINDER_10: return "06AB"
        case .MONITOR_MISFIRE_CYLINDER_11: return "06AC"
        case .MONITOR_MISFIRE_CYLINDER_12: return "06AD"
        case .MONITOR_PM_FILTER_B1: return "06B0"
        case .MONITOR_PM_FILTER_B2: return "06B1"
        }
    }

    public var description: String {
        switch self {
        case .MIDS_A: return "Supported MIDs [01-20]"
        case .MONITOR_O2_B1S1: return "O2 Sensor Monitor Bank 1 - Sensor 1"
        case .MONITOR_O2_B1S2: return "O2 Sensor Monitor Bank 1 - Sensor 2"
        case .MONITOR_O2_B1S3: return "O2 Sensor Monitor Bank 1 - Sensor 3"
        case .MONITOR_O2_B1S4: return "O2 Sensor Monitor Bank 1 - Sensor 4"
        case .MONITOR_O2_B2S1: return "O2 Sensor Monitor Bank 2 - Sensor 1"
        case .MONITOR_O2_B2S2: return "O2 Sensor Monitor Bank 2 - Sensor 2"
        case .MONITOR_O2_B2S3: return "O2 Sensor Monitor Bank 2 - Sensor 3"
        case .MONITOR_O2_B2S4: return "O2 Sensor Monitor Bank 2 - Sensor 4"
        case .MONITOR_O2_B3S1: return "O2 Sensor Monitor Bank 3 - Sensor 1"
        case .MONITOR_O2_B3S2: return "O2 Sensor Monitor Bank 3 - Sensor 2"
        case .MONITOR_O2_B3S3: return "O2 Sensor Monitor Bank 3 - Sensor 3"
        case .MONITOR_O2_B3S4: return "O2 Sensor Monitor Bank 3 - Sensor 4"
        case .MONITOR_O2_B4S1: return "O2 Sensor Monitor Bank 4 - Sensor 1"
        case .MONITOR_O2_B4S2: return "O2 Sensor Monitor Bank 4 - Sensor 2"
        case .MONITOR_O2_B4S3: return "O2 Sensor Monitor Bank 4 - Sensor 3"
        case .MONITOR_O2_B4S4: return "O2 Sensor Monitor Bank 4 - Sensor 4"
        case .MIDS_B: return "Supported MIDs [21-40]"
        case .MONITOR_CATALYST_B1: return "Catalyst Monitor Bank 1"
        case .MONITOR_CATALYST_B2: return "Catalyst Monitor Bank 2"
        case .MONITOR_CATALYST_B3: return "Catalyst Monitor Bank 3"
        case .MONITOR_CATALYST_B4: return "Catalyst Monitor Bank 4"
        case .MONITOR_EGR_B1: return "EGR Monitor Bank 1"
        case .MONITOR_EGR_B2: return "EGR Monitor Bank 2"
        case .MONITOR_EGR_B3: return "EGR Monitor Bank 3"
        case .MONITOR_EGR_B4: return "EGR Monitor Bank 4"
        case .MONITOR_VVT_B1: return "VVT Monitor Bank 1"
        case .MONITOR_VVT_B2: return "VVT Monitor Bank 2"
        case .MONITOR_VVT_B3: return "VVT Monitor Bank 3"
        case .MONITOR_VVT_B4: return "VVT Monitor Bank 4"
        case .MONITOR_EVAP_150: return "EVAP Monitor (Cap Off / 0.150\")"
        case .MONITOR_EVAP_090: return "EVAP Monitor (0.090\")"
        case .MONITOR_EVAP_040: return "EVAP Monitor (0.040\")"
        case .MONITOR_EVAP_020: return "EVAP Monitor (0.020\")"
        case .MONITOR_PURGE_FLOW: return "Purge Flow Monitor"
        case .MIDS_C: return "Supported MIDs [41-60]"
        case .MONITOR_O2_HEATER_B1S1: return "O2 Sensor Heater Monitor Bank 1 - Sensor 1"
        case .MONITOR_O2_HEATER_B1S2: return "O2 Sensor Heater Monitor Bank 1 - Sensor 2"
        case .MONITOR_O2_HEATER_B1S3: return "O2 Sensor Heater Monitor Bank 1 - Sensor 3"
        case .MONITOR_O2_HEATER_B1S4: return "O2 Sensor Heater Monitor Bank 1 - Sensor 4"
        case .MONITOR_O2_HEATER_B2S1: return "O2 Sensor Heater Monitor Bank 2 - Sensor 1"
        case .MONITOR_O2_HEATER_B2S2: return "O2 Sensor Heater Monitor Bank 2 - Sensor 2"
        case .MONITOR_O2_HEATER_B2S3: return "O2 Sensor Heater Monitor Bank 2 - Sensor 3"
        case .MONITOR_O2_HEATER_B2S4: return "O2 Sensor Heater Monitor Bank 2 - Sensor 4"
        case .MONITOR_O2_HEATER_B3S1: return "O2 Sensor Heater Monitor Bank 3 - Sensor 1"
        case .MONITOR_O2_HEATER_B3S2: return "O2 Sensor Heater Monitor Bank 3 - Sensor 2"
        case .MONITOR_O2_HEATER_B3S3: return "O2 Sensor Heater Monitor Bank 3 - Sensor 3"
        case .MONITOR_O2_HEATER_B3S4: return "O2 Sensor Heater Monitor Bank 3 - Sensor 4"
        case .MONITOR_O2_HEATER_B4S1: return "O2 Sensor Heater Monitor Bank 4 - Sensor 1"
        case .MONITOR_O2_HEATER_B4S2: return "O2 Sensor Heater Monitor Bank 4 - Sensor 2"
        case .MONITOR_O2_HEATER_B4S3: return "O2 Sensor Heater Monitor Bank 4 - Sensor 3"
        case .MONITOR_O2_HEATER_B4S4: return "O2 Sensor Heater Monitor Bank 4 - Sensor 4"
        case .MIDS_D: return "Supported MIDs [61-80]"
        case .MONITOR_HEATED_CATALYST_B1: return "Heated Catalyst Monitor Bank 1"
        case .MONITOR_HEATED_CATALYST_B2: return "Heated Catalyst Monitor Bank 2"
        case .MONITOR_HEATED_CATALYST_B3: return "Heated Catalyst Monitor Bank 3"
        case .MONITOR_HEATED_CATALYST_B4: return "Heated Catalyst Monitor Bank 4"
        case .MONITOR_SECONDARY_AIR_1: return "Secondary Air Monitor 1"
        case .MONITOR_SECONDARY_AIR_2: return "Secondary Air Monitor 2"
        case .MONITOR_SECONDARY_AIR_3: return "Secondary Air Monitor 3"
        case .MONITOR_SECONDARY_AIR_4: return "Secondary Air Monitor 4"
        case .MIDS_E: return "Supported MIDs [81-A0]"
        case .MONITOR_FUEL_SYSTEM_B1: return "Fuel System Monitor Bank 1"
        case .MONITOR_FUEL_SYSTEM_B2: return "Fuel System Monitor Bank 2"
        case .MONITOR_FUEL_SYSTEM_B3: return "Fuel System Monitor Bank 3"
        case .MONITOR_FUEL_SYSTEM_B4: return "Fuel System Monitor Bank 4"
        case .MONITOR_BOOST_PRESSURE_B1: return "Boost Pressure Control Monitor Bank 1"
        case .MONITOR_BOOST_PRESSURE_B2: return "Boost Pressure Control Monitor Bank 1"
        case .MONITOR_NOX_ABSORBER_B1: return "NOx Absorber Monitor Bank 1"
        case .MONITOR_NOX_ABSORBER_B2: return "NOx Absorber Monitor Bank 2"
        case .MONITOR_NOX_CATALYST_B1: return "NOx Catalyst Monitor Bank 1"
        case .MONITOR_NOX_CATALYST_B2: return "NOx Catalyst Monitor Bank 2"
        case .MIDS_F: return "Supported MIDs [A1-C0]"
        case .MONITOR_MISFIRE_GENERAL: return "Misfire Monitor General Data"
        case .MONITOR_MISFIRE_CYLINDER_1: return "Misfire Cylinder 1 Data"
        case .MONITOR_MISFIRE_CYLINDER_2: return "Misfire Cylinder 2 Data"
        case .MONITOR_MISFIRE_CYLINDER_3: return "Misfire Cylinder 3 Data"
        case .MONITOR_MISFIRE_CYLINDER_4: return "Misfire Cylinder 4 Data"
        case .MONITOR_MISFIRE_CYLINDER_5: return "Misfire Cylinder 5 Data"
        case .MONITOR_MISFIRE_CYLINDER_6: return "Misfire Cylinder 6 Data"
        case .MONITOR_MISFIRE_CYLINDER_7: return "Misfire Cylinder 7 Data"
        case .MONITOR_MISFIRE_CYLINDER_8: return "Misfire Cylinder 8 Data"
        case .MONITOR_MISFIRE_CYLINDER_9: return "Misfire Cylinder 9 Data"
        case .MONITOR_MISFIRE_CYLINDER_10: return "Misfire Cylinder 10 Data"
        case .MONITOR_MISFIRE_CYLINDER_11: return "Misfire Cylinder 11 Data"
        case .MONITOR_MISFIRE_CYLINDER_12: return "Misfire Cylinder 12 Data"
        case .MONITOR_PM_FILTER_B1: return "PM Filter Monitor Bank 1"
        case .MONITOR_PM_FILTER_B2: return "PM Filter Monitor Bank 2"
        }
    }

    public var bytes: Int {
        return 0
    }

    public var decoder: Decoders {
        switch self {
        case .MIDS_A, .MIDS_B, .MIDS_C, .MIDS_D, .MIDS_E, .MIDS_F: return .pid
        default: return .monitor
        }
    }

    public func decode(data: Data, unit: MeasurementUnit) -> Result<DecodeResult, DecodeError> {
        return decoder.getDecoder()!.decode(data: data, unit: unit)
    }
}

extension OBDCommand {
    static public func from(command: String) -> OBDCommand? {
        return OBDCommand.allCommands.first(where: { $0.properties.command == command })
    }
}

extension OBDCommand {
	public var detailedDescription: String? {
		switch self {
			case .mode1(let mode1):
				switch mode1 {
					case .status: return "Monitor Status of the vehicle's systems"
					case .freezeDTC: return """
						The Freeze DTC (Diagnostic Trouble Codes) PID is used to retrieve trouble codes that were stored in the vehicle's ECU (Engine Control Unit) when a fault condition was detected. Specifically, Freeze DTC will provide the trouble codes for faults that triggered the Malfunction Indicator Light (MIL), also known as the Check Engine Light (CEL).

						These codes represent issues or malfunctions in the vehicle's systems, such as the engine, transmission, emissions controls, and more. The codes are stored in the vehicle's computer memory to help identify what needs to be repaired.
						"""
					case .fuelStatus: return """
						The Fuel Status PID provides information about the fuel system's operating status. Specifically, it indicates whether the engine is running in closed-loop or open-loop operation, and whether the fuel system is in a condition that is optimizing fuel efficiency.

						This data is important because it helps determine how efficiently the engine is operating and if it's using the correct air-fuel ratio based on the engine's operating conditions.
						"""
					case .engineLoad: return """
						The Fuel Status PID provides information about the fuel system's operating status. Specifically, it indicates whether the engine is running in closed-loop or open-loop operation, and whether the fuel system is in a condition that is optimizing fuel efficiency.

						This data is important because it helps determine how efficiently the engine is operating and if it's using the correct air-fuel ratio based on the engine's operating conditions.
						"""
					case .coolantTemp: return """
						The Coolant Temperature PID provides the current temperature of the engine's coolant. This is an important parameter because the engine's cooling system regulates the engine temperature to prevent overheating and to optimize fuel efficiency. The coolant temperature can affect engine performance, fuel efficiency, and emissions.
						"""
					case .shortFuelTrim1: return """
						The Short Term Fuel Trim 1 (STFT1) PID provides the short-term adjustment the engine control unit (ECU) makes to the fuel injector pulse width in response to real-time feedback from the oxygen sensor. This adjustment is used to correct the air-fuel mixture (the ratio of air to fuel) for optimal combustion.

						STFT1 refers to Bank 1, Sensor 1 — the upstream oxygen sensor, which is located before the catalytic converter.
						"""
					case .longFuelTrim1: return """
						The Long Term Fuel Trim 1 (LTFT1) PID provides the long-term adjustment made by the engine control unit (ECU) to the fuel injection system based on sustained trends over time. Unlike Short Term Fuel Trim (STFT), which adjusts in real-time, LTFT1 reflects cumulative changes made to the fuel mixture to address consistent deviations from the ideal air-fuel ratio.

						LTFT1 refers to Bank 1, Sensor 1 — the upstream oxygen sensor for Bank 1 (the side of the engine that typically includes cylinder 1).
						"""
					case .shortFuelTrim2: return """
						The Short Term Fuel Trim 2 (STFT2) PID provides the short-term adjustment to the fuel system for Bank 2 (the opposite side of the engine from Bank 1) based on feedback from the upstream oxygen sensor (O2 sensor). This adjustment helps the engine maintain an optimal air-fuel ratio for combustion in real-time.

						STFT2 is similar to STFT1, but it pertains to Bank 2, and it represents the engine’s short-term response to changes in air-fuel ratio based on sensor feedback.
						"""
					case .longFuelTrim2: return """
						The Long Term Fuel Trim 2 (LTFT2) PID provides the long-term adjustment the engine control unit (ECU) makes to the fuel injector pulse width in response to persistent trends in the air-fuel mixture over time. Unlike the Short Term Fuel Trim (STFT), which adjusts in real-time, LTFT represents a cumulative, long-term correction to fuel delivery, reflecting ongoing conditions.

						LTFT2 refers to Bank 2, Sensor 1 — the upstream oxygen sensor for Bank 2 (the side of the engine opposite to Bank 1, which is typically determined by cylinder numbering in the engine).
						"""
					case .fuelPressure: return """
						Shows the fuel rail pressure. 
						
						Normal Range: Typically between 300–450 kPa depending on the vehicle and operating conditions. 
						Low or high fuel pressure can indicate issues with the fuel pump, fuel filter, or fuel injectors.
						"""
					case .intakePressure: return """
						Indicates intake manifold pressure.
						
						Normal Range: Typically around 20–100 kPa at idle, depending on altitude and engine load.
						Low values usually mean a vacuum is being created in the manifold (idle or light load).
						High values indicate high intake pressures, which happen when the throttle is wide open or under heavy load.
						"""
					case .rpm: return "The Engine RPM PID provides the current revolutions per minute (RPM) of the engine, indicating how fast the engine's crankshaft is rotating. This is a key parameter for monitoring engine performance and efficiency."
					case .speed: return "The Vehicle Speed PID provides the current speed of the vehicle, typically in kilometers per hour (km/h) or miles per hour (mph), depending on the vehicle's configuration."
					case .timingAdvance: return """
						Shows ignition timing advance.
						
						Positive values (e.g., +5°) = advanced timing, which improves performance and efficiency.
						Negative values = retarded timing, typically to prevent knocking or because of high load conditions.
						Normal values typically range from +10° to -10° (depending on load, engine speed, and conditions).
						"""
					case .intakeTemp: return """
						Shows intake air temperature.
						
						Cold air is denser, improving combustion efficiency and power, so lower intake temperatures (e.g., under 20°C) are generally better for performance.
						High intake temperatures (e.g., over 40°C) can reduce engine performance and efficiency, especially under heavy load.
						"""
					case .maf: return """
						Shows the mass air flow (in g/s).
						
						MAF measures the amount of air entering the engine, which the ECU uses to determine the right amount of fuel to inject.
						Low MAF readings could indicate issues with the air intake system (e.g., clogged air filter).
						High MAF readings are common under heavy acceleration or high load.
						"""
					case .throttlePos: return """
						Shows the throttle position as a percentage.
						
						0% = Throttle is closed (idle or off)
						100% = Throttle is fully open (wide open throttle or WOT)
						Normal driving conditions will vary, but you'll often see values between 10-50% during normal driving.
						"""
					case .airStatus: return """
						This is related to the status of the air intake system, which helps in monitoring air quality and air flow for optimal combustion.
						"""
					case .O2Sensor: return """
						Oxygen sensors (also called O2 sensors) measure the amount of oxygen in the exhaust gases, which helps the engine control unit (ECU) adjust the air-fuel mixture for optimal combustion.
						
						Wideband O2 sensors: Voltage range typically from 0 to 5V. Higher voltage indicates a richer mixture, while lower voltage indicates a leaner mixture.
						Narrowband O2 sensors: Typically fluctuate between 0.1V (lean) and 0.9V (rich).
						Normal Range (for narrowband O2 sensor):
						0.1V - 0.9V: Normal sensor behavior (lean to rich conditions)
						"""
					case .O2Bank1Sensor1: return "The Oxygen Sensor Bank 1, Sensor 1 PID provides the data from the first oxygen sensor located before the catalytic converter (also called the pre-catalytic converter O2 sensor) on Bank 1 of the engine. Bank 1 refers to the side of the engine where cylinder #1 is located, and this sensor is critical for monitoring the air-fuel mixture and ensuring proper emissions control."
					case .O2Bank1Sensor2: return "The Oxygen Sensor Bank 1, Sensor 2 PID provides the data from the second oxygen sensor located after the catalytic converter on Bank 1 of the engine. This sensor is often referred to as the post-catalytic converter O2 sensor or downstream O2 sensor. It plays a crucial role in monitoring the performance of the catalytic converter and ensuring it is properly filtering the exhaust gases."
					case .O2Bank1Sensor3: return "The Oxygen Sensor Bank 1, Sensor 3 PID is not part of the standard OBD-II PIDs and generally does not exist for typical gasoline vehicles. The OBD-II standard generally only defines PIDs for upstream (pre-catalytic converter) and downstream (post-catalytic converter) oxygen sensors for each bank."
					case .O2Bank1Sensor4: return "Similar to Oxygen Sensor Bank 1, Sensor 3, the Oxygen Sensor Bank 1, Sensor 4 PID does not exist as part of the standard OBD-II PIDs. The OBD-II standard typically provides only two oxygen sensors per bank: one before (upstream) and one after (downstream) the catalytic converter."
					case .O2Bank2Sensor1: return """
						The Oxygen Sensor Bank 2, Sensor 1 PID provides data from the first oxygen sensor located before the catalytic converter (pre-catalytic converter O2 sensor) on Bank 2 of the engine. Bank 2 refers to the side of the engine opposite to Bank 1 (the side where cylinder #1 is located).

						This upstream O2 sensor plays a critical role in monitoring the air-fuel mixture and sending feedback to the ECU (Engine Control Unit) to adjust fuel delivery for optimal combustion.
						"""
					case .O2Bank2Sensor2: return """
						The Oxygen Sensor Bank 2, Sensor 2 PID provides data from the second oxygen sensor located after the catalytic converter (post-catalytic converter O2 sensor) on Bank 2 of the engine. This sensor is also referred to as the downstream O2 sensor and is crucial for monitoring the efficiency of the catalytic converter.

						It measures the oxygen content in the exhaust gases after the gases have passed through the catalytic converter, which allows the ECU to determine if the catalytic converter is performing correctly in reducing emissions.
						"""
					case .O2Bank2Sensor3: return """
						Similar to Bank 1, Sensor 3, the Oxygen Sensor Bank 2, Sensor 3 PID is not part of the standard OBD-II PIDs. The standard OBD-II system typically provides support for two oxygen sensors per bank:
						Upstream sensor (Sensor 1): Before the catalytic converter (pre-catalytic converter).
						Downstream sensor (Sensor 2): After the catalytic converter (post-catalytic converter).
						"""
					case .O2Bank2Sensor4: return """
						Similar to Oxygen Sensor Bank 2, Sensor 3, the Oxygen Sensor Bank 2, Sensor 4 PID is not part of the standard OBD-II PIDs. The OBD-II standard typically provides support for two oxygen sensors per bank — one upstream (before the catalytic converter) and one downstream (after the catalytic converter).
						"""
					case .obdcompliance: return "OBD Compliance typically refers to a vehicle’s readiness to pass emissions testing."
					case .auxInputStatus: return """
						"Auxiliary Input Status isn't typically a standard OBD-II PID but might relate to manufacturer-specific diagnostics or custom sensor readings.
						You would need the manufacturer-specific PID to access data related to these systems.
						"""
					case .runTime: return """
						Shows engine run time since the last reset or ignition cycle.
						
						Engine Run Time is useful for tracking how long the engine has been operating, especially for maintenance schedules, troubleshooting idle issues, or verifying engine performance.
						It also resets to zero each time the ignition is turned off and back on.
						"""
					case .distanceWMIL: return """
						Distance Since MIL (Malfunction Indicator Light) Was Last Cleared — a useful diagnostic parameter that tracks how many miles (or kilometers) the vehicle has driven since the MIL (check engine light) was last reset or turned off. 
						
						This can help you understand how long the vehicle has been operating with potential engine issues since the MIL was last cleared.
						The MIL (check engine light) is typically triggered when there is a malfunction in the engine or emissions system.
						Distance since MIL tells you how much distance has been driven since the problem was last cleared/reset.
						This is useful for tracking how much time or distance has passed since the vehicle last encountered a fault that triggered the check engine light.
						"""
					case .EGRError: return """
						The term EGR Error refers to a malfunction or issue with the Exhaust Gas Recirculation (EGR) system.
						
						The EGR system helps reduce nitrogen oxide (NOx) emissions by recirculating a portion of the exhaust gases back into the intake air to lower combustion temperatures. When the EGR system isn't functioning properly, it can trigger a fault code and cause the Check Engine Light (MIL) to illuminate.
						"""
					case .evaporativePurge: return """
						The Evaporative Purge refers to the evaporative emission control system (EVAP), which is responsible for managing and purging fuel vapors from the fuel tank. The system captures fuel vapors from the tank and sends them to the engine to be burned, rather than allowing them to escape into the atmosphere.

						The Evaporative Purge process involves the purge valve, which is controlled by the engine control unit (ECU) to allow the fuel vapors to flow into the engine when needed.
						"""
					case .fuelLevel: return """
						The Fuel Level parameter provides the current amount of fuel in the vehicle’s tank, typically expressed as a percentage of the tank’s full capacity. This reading helps the engine control unit (ECU) and the driver monitor the available fuel.
						"""
					case .warmUpsSinceDTCCleared: return """
						The Warm-ups Since DTC Cleared parameter refers to the number of engine warm-up cycles that have occurred since the Diagnostic Trouble Codes (DTCs) were last cleared. A warm-up cycle is typically counted when the engine goes from a cold start to reaching its normal operating temperature.

						This count is important because many vehicle systems, especially those related to emissions control, may perform self-diagnostics during the warm-up phase. These systems might not show faults (DTCs) until the engine has had a chance to warm up and reach certain operational conditions.
						"""
					case .distanceSinceDTCCleared: return """
						The Distance Since DTC Cleared parameter refers to the number of miles (or kilometers) the vehicle has traveled since the Diagnostic Trouble Codes (DTCs) were last cleared. This value can be helpful for determining how much driving has occurred since a fault was last reset in the vehicle's engine control unit (ECU), providing context for how long a problem has persisted.
						"""
					case .evapVaporPressure: return """
						The Evap Vapor Pressure refers to the pressure within the evaporative emission control system (EVAP). This system captures and stores fuel vapors from the fuel tank to prevent them from escaping into the atmosphere. The Evaporative Vapor Pressure is a critical parameter that the vehicle’s ECU monitors to ensure the EVAP system is functioning correctly. It helps to check for potential issues, such as leaks or improper pressure in the fuel system, which could lead to emissions problems.

						This pressure is measured by a vapor pressure sensor in the EVAP system. If the pressure is too high or too low, it can indicate a malfunction, like a blocked vent valve, a faulty pressure sensor, or an EVAP system leak.
						"""
					case .barometricPressure: return """
						The Barometric Pressure refers to the atmospheric pressure at a given location, measured in kilopascals (kPa) or inches of mercury (inHg). In OBD-II systems, this pressure reading is used by the engine control unit (ECU) for various calculations, including air-fuel ratio adjustments and altitude compensation.

						Barometric pressure plays a role in how the ECU calculates other parameters, such as air intake, fuel mixture, and engine load. Since atmospheric pressure decreases with altitude, the ECU uses the barometric pressure reading to adjust for changes in altitude during operation.
						"""
					case .catalystTempB1S1: return """
						The Catalyst Temperature (B1S1) refers to the temperature of the catalytic converter in Bank 1, Sensor 1. The catalytic converter helps reduce harmful emissions by converting toxic gases such as carbon monoxide (CO), hydrocarbons (HC), and nitrogen oxides (NOx) into less harmful substances. The temperature of the catalyst is crucial for its efficiency and effectiveness in this process.
						"""
					case .catalystTempB2S1: return """
						The Catalyst Temperature (B2S1) refers to the temperature of the catalytic converter in Bank 2, Sensor 1. The catalytic converter helps reduce harmful emissions by converting toxic gases such as carbon monoxide (CO), hydrocarbons (HC), and nitrogen oxides (NOx) into less harmful substances. The temperature of the catalyst is crucial for its efficiency and effectiveness in this process.
						"""
					case .catalystTempB1S2: return """
						The Catalyst Temperature (B1S2) refers to the temperature of the catalytic converter in Bank 1, Sensor 2. The catalytic converter helps reduce harmful emissions by converting toxic gases such as carbon monoxide (CO), hydrocarbons (HC), and nitrogen oxides (NOx) into less harmful substances. The temperature of the catalyst is crucial for its efficiency and effectiveness in this process.
						"""
					case .catalystTempB2S2: return """
						The Catalyst Temperature (B1S2) refers to the temperature of the catalytic converter in Bank 2, Sensor 2. The catalytic converter helps reduce harmful emissions by converting toxic gases such as carbon monoxide (CO), hydrocarbons (HC), and nitrogen oxides (NOx) into less harmful substances. The temperature of the catalyst is crucial for its efficiency and effectiveness in this process.
						"""
					case .statusDriveCycle: return """
						The Status of the Drive Cycle is a diagnostic parameter that indicates the current state of the vehicle’s drive cycle. A drive cycle refers to a specific sequence of driving conditions required to allow the vehicle's onboard diagnostic (OBD) system to perform self-tests and verify that various components and systems, such as the catalytic converter, oxygen sensors, and evaporative emissions system, are functioning properly.

						During a drive cycle, the OBD system checks if certain conditions have been met to test components like the catalytic converter, oxygen sensors, and other critical emissions components. The status of the drive cycle helps inform if all tests have been completed successfully or if certain tests are still pending.
						"""
					case .controlModuleVoltage: return """
						The Control Module Voltage refers to the voltage supplied to the engine control module (ECM) or powertrain control module (PCM). These control modules are responsible for managing various engine functions, such as fuel injection, ignition timing, and emissions control. The control module requires a stable voltage supply to ensure proper operation.

						If the voltage to the control module is too low or too high, it can lead to issues with engine performance, poor fuel efficiency, or even cause malfunctioning of sensors and other systems controlled by the module. Monitoring this voltage is essential to ensure the vehicle’s systems are operating within the proper electrical parameters.
						"""
					case .absoluteLoad: return """
						The Absolute Load is a measure of the engine's load in relation to the maximum load it is capable of handling. It reflects the engine’s power demand based on factors such as throttle position, engine speed (RPM), and air intake. The absolute load is useful for understanding the strain on the engine at any given moment, helping diagnose performance issues, fuel efficiency, and emissions.

						Absolute Load is typically given as a percentage of the maximum possible engine load (i.e., the maximum load the engine could handle at full throttle under ideal conditions).
						"""
					case .commandedEquivRatio: return """
						The Commanded Equivalence Ratio is a measure used by the engine control unit (ECU) to adjust the air-fuel mixture in the engine. It represents the target air-fuel ratio the ECU is trying to achieve, which is typically used to optimize engine performance and reduce emissions.

						In an internal combustion engine, the air-fuel ratio is crucial for combustion efficiency. The equivalence ratio is the ratio of the actual air-fuel ratio to the stoichiometric air-fuel ratio, which is the ideal ratio for complete combustion. The stoichiometric ratio for gasoline is typically 14.7:1 (14.7 parts air to 1 part fuel), meaning that when the air-fuel ratio is at this point, the engine is burning all the fuel with all the available oxygen.

						Commanded Equivalence Ratio < 1: Indicates a lean mixture, where there is more air than needed for the fuel.
						Commanded Equivalence Ratio > 1: Indicates a rich mixture, where there is more fuel than needed for the available air.

						The commanded equivalence ratio is used by the ECU to fine-tune fuel delivery based on sensor readings, such as oxygen sensors or mass air flow (MAF) sensors, in order to optimize engine performance and emissions.
						"""
					case .relativeThrottlePos: return """
						The Relative Throttle Position is a parameter that indicates the current position of the throttle valve in the intake system relative to the maximum throttle position. This value is crucial for understanding how much the throttle is being opened, which directly affects the amount of air entering the engine and, in turn, the engine's power output.

						A 0% throttle means the throttle valve is fully closed (idle or minimal acceleration).
						A 100% throttle means the throttle valve is fully open (wide-open throttle or full acceleration).

						This value is often used by the engine control unit (ECU) to adjust fuel delivery and ignition timing for optimal performance, emissions control, and fuel efficiency.
						"""
					case .ambientAirTemp: return """
						The Ambient Air Temperature refers to the temperature of the air surrounding the vehicle, which is typically measured by a temperature sensor located outside the vehicle, often near the front bumper or in the vehicle’s air intake system. This value can influence several aspects of engine performance, including fuel delivery and air intake calculations.

						In an OBD-II context, the ambient air temperature is used by the engine control unit (ECU) to adjust engine parameters based on the outside air conditions. For example, if the ambient temperature is cold, the ECU may adjust fuel injection and ignition timing to compensate for denser air, while in hot weather, adjustments might be made for thinner air.
						"""
					case .throttleActuator: return """
						The Throttle Actuator is a component in a vehicle's throttle system that controls the throttle valve's position based on input from the engine control unit (ECU). This actuator is typically an electric motor that adjusts the throttle valve's position, controlling the amount of air entering the engine and thus the engine’s power output. The throttle actuator is particularly common in drive-by-wire systems, where there is no physical connection between the accelerator pedal and the throttle body, as opposed to traditional cable-operated throttles.

						In modern vehicles, the throttle actuator works in conjunction with various sensors (like the throttle position sensor) to maintain smooth acceleration, fuel efficiency, and emissions control.
						"""
					case .runTimeMIL: return """
						The Run Time MIL (Malfunction Indicator Lamp) refers to the amount of time that the Malfunction Indicator Light (MIL), commonly known as the Check Engine Light (CEL), has been illuminated during a particular driving session since the vehicle was last started. This is important for diagnosing and troubleshooting issues in the vehicle's emissions system or engine performance.

						When the MIL light comes on, it indicates that the engine control unit (ECU) has detected an issue with one of the vehicle’s systems (e.g., fuel, exhaust, ignition). The Run Time MIL provides information on how long the light has been on, which can help a technician understand the severity or persistence of the problem.
						"""
					case .timeSinceDTCCleared: return """
						The Time Since DTC Cleared refers to the amount of time that has passed since the Diagnostic Trouble Codes (DTCs) were last cleared or reset in a vehicle's OBD-II system. This can be useful for understanding when the last diagnostic reset occurred and is often helpful in tracking how long the vehicle has been operating since any issues were cleared from the system.

						DTCs are generated by the engine control unit (ECU) when it detects an issue with the vehicle's performance or systems. These codes remain in the system until they are manually cleared (such as by using a diagnostic scanner or after certain repairs are made). The time since DTC cleared can be important when determining how long a vehicle has been running since any errors or faults were last addressed.
						"""
					case .maxValues: return "Max Values refer to the maximum values recorded by the vehicle’s ECU (Engine Control Unit) for certain parameters since the last DTC reset. This gives insight into how hard the engine has been worked or if it has experienced abnormal conditions."
					case .maxMAF: return "The Max MAF value represents the maximum air intake measured by the Mass Air Flow (MAF) sensor since the last time the Diagnostic Trouble Codes (DTCs) were cleared. It tells you how much air the engine has ever pulled in under peak load or speed conditions."
					case .fuelType: return "The Fuel Type PID tells you what type of fuel the vehicle is designed to run on, as reported by the Engine Control Unit (ECU). It’s a standardized identifier useful for diagnostics, emissions testing, and understanding how to interpret certain sensor values (since they can vary depending on the fuel type)."
					case .ethanoPercent: return "The Ethanol Percentage PID tells you what percentage of the fuel in the tank is ethanol. This is especially relevant for flex-fuel vehicles (FFVs) that can operate on varying blends of gasoline and ethanol (like E10, E15, or E85). Knowing this helps the ECU adjust fuel delivery and timing for optimal performance."
					case .evapVaporPressureAbs: return """
						The Evaporative Vapor Pressure (Absolute) PID provides the absolute pressure inside the EVAP (evaporative emissions) system. This value helps monitor the fuel system for leaks, vapor containment, and emissions compliance.

						It’s similar to other vapor pressure PIDs but reports absolute pressure, meaning it’s measured relative to a perfect vacuum (0 kPa), not atmospheric pressure.
						"""
					case .evapVaporPressureAlt: return """
						The Evap Vapor Pressure (Alternate) PID reports the evaporative system vapor pressure, but depending on the vehicle manufacturer, it may use a different scale, unit, or sensor range than the standard PID 53. This PID is typically used in vehicles where pressure is reported as a signed 16-bit value, and the units vary by manufacturer — most commonly reported in Pascals (Pa) or inches of H₂O.
						"""
					case .fuelRailPressureAbs: return "The Fuel Rail Pressure (Absolute) PID reports the actual pressure in the fuel rail relative to a perfect vacuum (0 kPa). This is useful for diagnosing fuel delivery issues, checking for fuel pump performance, and ensuring proper fuel injector function."
					case .relativeAccelPos: return "The Relative Accelerator Pedal Position PID shows how far the accelerator pedal is pressed relative to its minimum and maximum calibrated values, not just raw voltage or angle. This PID provides a normalized percentage (0–100%), making it easier to compare across vehicles."
					case .engineOilTemp: return "The Engine Oil Temperature PID provides the current temperature of the engine's lubricating oil, which is critical for monitoring engine health, thermal load, and lubrication performance. This sensor is not mandatory on all vehicles, so availability may vary."
					case .fuelInjectionTiming: return "The Fuel Injection Timing PID provides the timing of fuel injection relative to the crankshaft position, typically expressed in degrees before or after top dead center (BTDC/ATDC). This is essential for understanding combustion efficiency, engine performance, and diagnosing timing-related issues."
					case .fuelRate: return "The Fuel Flow Rate PID reports the rate at which fuel is being consumed by the engine. It is typically expressed in liters per hour (L/h) or gallons per hour (GPH), and is useful for monitoring fuel efficiency, consumption trends, and overall engine performance."
					case .emissionsReq: return "The Emissions Requirements PID provides information about the status of emissions system readiness and compliance with the vehicle’s emission control systems. This PID is often used to check if the vehicle is ready for an emissions inspection or if any emission-related issues are affecting the vehicle’s systems."
					default: return nil
				}
			default: return nil
		}
	}
}
