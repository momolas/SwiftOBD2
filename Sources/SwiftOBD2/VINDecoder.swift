import Foundation

public struct VehicleDetails: Codable {
    public let vin: String
    public let make: String
    public let year: Int?
    public let country: String
    public let region: String
}

public struct VINDecoder {
    public static func decode(vin: String) -> VehicleDetails {
        let cleanedVIN = vin.uppercased().replacing(" ", with: "")
        guard cleanedVIN.count == 17 else {
            return VehicleDetails(vin: vin, make: "Invalid VIN", year: nil, country: "Unknown", region: "Unknown")
        }

        let wmi = String(cleanedVIN.prefix(3))
        let yearChar = cleanedVIN[cleanedVIN.index(cleanedVIN.startIndex, offsetBy: 9)]

        let make = decodeMake(wmi: wmi)
        let (country, region) = decodeRegionAndCountry(wmi: wmi)
        let year = decodeYear(char: yearChar)

        return VehicleDetails(vin: vin, make: make, year: year, country: country, region: region)
    }

    private static func decodeYear(char: Character) -> Int? {
        let yearMap: [Character: Int] = [
            "A": 2010, "B": 2011, "C": 2012, "D": 2013, "E": 2014, "F": 2015, "G": 2016, "H": 2017,
            "J": 2018, "K": 2019, "L": 2020, "M": 2021, "N": 2022, "P": 2023, "R": 2024, "S": 2025,
            "T": 2026, "V": 2027, "W": 2028, "X": 2029, "Y": 2030,
            "1": 2001, "2": 2002, "3": 2003, "4": 2004, "5": 2005, "6": 2006, "7": 2007, "8": 2008, "9": 2009
        ]
        // Note: VIN years cycle every 30 years. This simple logic assumes 2000+.
        // For older cars, context is needed or assumption.
        // Assuming 2010+ for letters A-Y based on current era, but older cars exist.
        // Let's support a wider range or return one possibility.
        // Simplified:
        if let y = yearMap[char] { return y }
        // Fallback for older cycle?
        let oldYearMap: [Character: Int] = [
            "L": 1990, "M": 1991, "N": 1992, "P": 1993, "R": 1994, "S": 1995, "T": 1996, "V": 1997,
            "W": 1998, "X": 1999, "Y": 2000
        ]
        // This overlap (L=2020 or 1990) makes it ambiguous without other data.
        // I'll return the modern one by default.
        return nil
    }

    private static func decodeRegionAndCountry(wmi: String) -> (String, String) {
        guard let first = wmi.first else { return ("Unknown", "Unknown") }

        switch first {
        case "1", "4", "5": return ("United States", "North America")
        case "2": return ("Canada", "North America")
        case "3": return ("Mexico", "North America")
        case "J": return ("Japan", "Asia")
        case "K": return ("South Korea", "Asia")
        case "S": return ("United Kingdom", "Europe")
        case "W": return ("Germany", "Europe")
        case "V":
            if wmi.starts(with: "VF") || wmi.starts(with: "VR") { return ("France", "Europe") }
            if wmi.starts(with: "VS") { return ("Spain", "Europe") }
            return ("Europe", "Europe")
        case "Z": return ("Italy", "Europe")
        default: return ("Unknown", "Unknown")
        }
    }

    private static func decodeMake(wmi: String) -> String {
        // Simplified WMI table
        let wmiMap: [String: String] = [
            "1FA": "Ford", "1FB": "Ford", "1FC": "Ford",
            "1FM": "Ford", "1FT": "Ford",
            "1J4": "Jeep", "1C3": "Chrysler", "1C4": "Chrysler",
            "1G1": "Chevrolet", "1G2": "Pontiac", "1G3": "Oldsmobile", "1G4": "Buick", "1G6": "Cadillac",
            "1GC": "Chevrolet Truck",
            "2HM": "Hyundai", "2HG": "Honda", "2HK": "Honda",
            "3VW": "Volkswagen", "3FA": "Ford",
            "WAU": "Audi", "WBA": "BMW", "WBS": "BMW M",
            "WDB": "Mercedes-Benz", "WDC": "DaimlerChrysler", "WDD": "Mercedes-Benz",
            "VF1": "Renault", "VF3": "Peugeot", "VF7": "Citroën",
            "ZFA": "Fiat", "ZAR": "Alfa Romeo",
            "JA3": "Mitsubishi", "JA4": "Mitsubishi",
            "JN1": "Nissan", "JN6": "Nissan",
            "JM1": "Mazda",
            "JTD": "Toyota", "JT2": "Toyota", "JTE": "Toyota",
            "KNA": "Kia", "KMH": "Hyundai",
            "SAL": "Land Rover", "SAJ": "Jaguar",
            "SHS": "Honda"
        ]

        if let make = wmiMap[wmi] { return make }
        // Prefix matching
        if wmi.starts(with: "1G") { return "General Motors" }
        if wmi.starts(with: "WV") { return "Volkswagen" }

        return "Unknown (\(wmi))"
    }
}
