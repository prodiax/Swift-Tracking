import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Device information helper for tracking
public struct DeviceInfo {
    /// Operating system name
    public let os: String
    
    /// Operating system version
    public let version: String
    
    /// Device model
    public let model: String
    
    /// Device identifier (IDFV)
    public let deviceId: String
    
    public init() {
        #if canImport(UIKit)
        self.os = "iOS"
        self.version = UIDevice.current.systemVersion
        self.deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        #elseif os(macOS)
        self.os = "macOS"
        self.version = ProcessInfo.processInfo.operatingSystemVersionString
        self.deviceId = UUID().uuidString
        #elseif os(tvOS)
        self.os = "tvOS"
        self.version = ProcessInfo.processInfo.operatingSystemVersionString
        self.deviceId = UUID().uuidString
        #elseif os(watchOS)
        self.os = "watchOS"
        self.version = ProcessInfo.processInfo.operatingSystemVersionString
        self.deviceId = UUID().uuidString
        #else
        self.os = "Unknown"
        self.version = ProcessInfo.processInfo.operatingSystemVersionString
        self.deviceId = UUID().uuidString
        #endif
        
        self.model = Self.getDeviceModel()
    }
    
    private static func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return modelCode ?? "Unknown"
    }
    
    /// Convert to dictionary for JSON serialization
    public func toDictionary() -> [String: Any] {
        return [
            "os": os,
            "version": version,
            "model": model
        ]
    }
}
