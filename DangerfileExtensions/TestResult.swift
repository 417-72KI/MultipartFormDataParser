import Foundation

struct TestResult: Decodable {
    let devices: [Device]
    let testNodes: [TestNode]
    let testPlanConfigurations: [TestPlanConfiguration]
}

extension TestResult {
    var isAllPassed: Bool { testNodes.allSatisfy(\.isPassed) }
}

extension TestResult: CustomStringConvertible {
    var description: String {
        [
            "Devices: \(devices.map(\.description).joined(separator: ", "))",
            "Test Nodes: \(testNodes.map(\.description).joined(separator: ", "))",
            "Test Plan Configurations: \(testPlanConfigurations.map(\.description).joined(separator: ", "))"
        ].joined(separator: "\n")
    }
}

extension TestResult {
    struct Device: Decodable {
        let architecture: String
        let deviceId: String
        let deviceName: String
        let modelName: String
        let osBuildNumber: String
        let osVersion: String
        let platform: String
    }
}

extension TestResult.Device: CustomStringConvertible {
    var description: String {
        "\(deviceName) (\(modelName)) - \(osVersion)"
    }
}

extension TestResult.Device: Comparable {
    static func < (lhs: TestResult.Device, rhs: TestResult.Device) -> Bool {
        if lhs.platform == rhs.platform {
            if lhs.osBuildNumber == rhs.osBuildNumber {
                lhs.deviceName < rhs.deviceName
            } else {
                lhs.osBuildNumber < rhs.osBuildNumber
            }
        } else {
            lhs.platform < rhs.platform
        }
    }
}

extension TestResult {
    struct TestNode: Decodable {
        let children: [TestNode]?
        let duration: String?
        let durationInSeconds: Double?
        let name: String
        let nodeIdentifier: String?
        let nodeIdentifierURL: String?
        let nodeType: String
        let result: Result?
    }
}

extension TestResult.TestNode {
    var isPassed: Bool { result == .passed }
}

extension TestResult.TestNode: CustomStringConvertible {
    var description: String {
        "\(name)\(result.map { " - (\($0.rawValue))" } ?? "")"
    }
}

extension TestResult.TestNode {
    enum Result: String, Decodable {
        case passed = "Passed"
        case failed = "Failed"
        case skipped = "Skipped"
        case expectedFailure = "Expected Failure"
    }
}

extension TestResult {
    struct TestPlanConfiguration: Decodable {
        let configurationId: String
        let configurationName: String
    }
}

extension TestResult.TestPlanConfiguration: CustomStringConvertible {
    var description: String {
        "\(configurationName) (\(configurationId))"
    }
}

extension TestResult {
    static func from(jsonFile: URL) throws -> TestResult {
        let data = try Data(contentsOf: jsonFile)
        let decoder = JSONDecoder()
        return try decoder.decode(TestResult.self, from: data)
    }
}
