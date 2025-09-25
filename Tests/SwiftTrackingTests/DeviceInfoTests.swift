import XCTest
@testable import SwiftTracking

final class DeviceInfoTests: XCTestCase {
    
    func testDeviceInfoInitialization() {
        let deviceInfo = DeviceInfo()
        
        #if canImport(UIKit)
        XCTAssertEqual(deviceInfo.os, "iOS")
        #elseif os(macOS)
        XCTAssertEqual(deviceInfo.os, "macOS")
        #elseif os(tvOS)
        XCTAssertEqual(deviceInfo.os, "tvOS")
        #elseif os(watchOS)
        XCTAssertEqual(deviceInfo.os, "watchOS")
        #else
        XCTAssertEqual(deviceInfo.os, "Unknown")
        #endif
        
        XCTAssertFalse(deviceInfo.version.isEmpty)
        XCTAssertFalse(deviceInfo.model.isEmpty)
        XCTAssertFalse(deviceInfo.deviceId.isEmpty)
    }
    
    func testDeviceInfoToDictionary() {
        let deviceInfo = DeviceInfo()
        let dictionary = deviceInfo.toDictionary()
        
        #if canImport(UIKit)
        XCTAssertEqual(dictionary["os"] as? String, "iOS")
        #elseif os(macOS)
        XCTAssertEqual(dictionary["os"] as? String, "macOS")
        #elseif os(tvOS)
        XCTAssertEqual(dictionary["os"] as? String, "tvOS")
        #elseif os(watchOS)
        XCTAssertEqual(dictionary["os"] as? String, "watchOS")
        #else
        XCTAssertEqual(dictionary["os"] as? String, "Unknown")
        #endif
        
        XCTAssertNotNil(dictionary["version"] as? String)
        XCTAssertNotNil(dictionary["model"] as? String)
        XCTAssertEqual(dictionary.count, 3)
    }
}
