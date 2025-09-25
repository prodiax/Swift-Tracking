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
        
        // Convert model code to readable name
        let deviceModel = modelCode ?? "Unknown"
        
        // Map common model codes to readable names
        let modelMapping: [String: String] = [
            // Simulators
            "arm64": "iOS Simulator",
            "x86_64": "iOS Simulator",
            "i386": "iOS Simulator",
            
            // iPhone models
            "iPhone14,7": "iPhone 13",
            "iPhone14,8": "iPhone 13 Pro",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone13,1": "iPhone 12 mini",
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",
            "iPhone11,2": "iPhone XS",
            "iPhone11,4": "iPhone XS Max",
            "iPhone11,6": "iPhone XS Max",
            "iPhone11,8": "iPhone XR",
            "iPhone10,3": "iPhone X",
            "iPhone10,6": "iPhone X",
            "iPhone9,1": "iPhone 7",
            "iPhone9,2": "iPhone 7 Plus",
            "iPhone9,3": "iPhone 7",
            "iPhone9,4": "iPhone 7 Plus",
            "iPhone8,1": "iPhone 6s",
            "iPhone8,2": "iPhone 6s Plus",
            "iPhone8,4": "iPhone SE (1st generation)",
            "iPhone7,1": "iPhone 6 Plus",
            "iPhone7,2": "iPhone 6",
            "iPhone6,1": "iPhone 5s",
            "iPhone6,2": "iPhone 5s",
            "iPhone5,3": "iPhone 5c",
            "iPhone5,4": "iPhone 5c",
            "iPhone5,1": "iPhone 5",
            "iPhone5,2": "iPhone 5",
            "iPhone4,1": "iPhone 4S",
            "iPhone3,1": "iPhone 4",
            "iPhone3,2": "iPhone 4",
            "iPhone3,3": "iPhone 4",
            "iPhone2,1": "iPhone 3GS",
            "iPhone1,2": "iPhone 3G",
            "iPhone1,1": "iPhone",
            
            // iPad models
            "iPad13,1": "iPad Air (4th generation)",
            "iPad13,2": "iPad Air (4th generation)",
            "iPad13,16": "iPad Air (5th generation)",
            "iPad13,17": "iPad Air (5th generation)",
            "iPad14,1": "iPad mini (6th generation)",
            "iPad14,2": "iPad mini (6th generation)",
            "iPad8,1": "iPad Pro 11-inch (3rd generation)",
            "iPad8,2": "iPad Pro 11-inch (3rd generation)",
            "iPad8,3": "iPad Pro 11-inch (3rd generation)",
            "iPad8,4": "iPad Pro 11-inch (3rd generation)",
            "iPad8,5": "iPad Pro 12.9-inch (3rd generation)",
            "iPad8,6": "iPad Pro 12.9-inch (3rd generation)",
            "iPad8,7": "iPad Pro 12.9-inch (3rd generation)",
            "iPad8,8": "iPad Pro 12.9-inch (3rd generation)",
            "iPad8,9": "iPad Pro 11-inch (4th generation)",
            "iPad8,10": "iPad Pro 11-inch (4th generation)",
            "iPad8,11": "iPad Pro 12.9-inch (4th generation)",
            "iPad8,12": "iPad Pro 12.9-inch (4th generation)",
            "iPad7,1": "iPad Pro 12.9-inch (2nd generation)",
            "iPad7,2": "iPad Pro 12.9-inch (2nd generation)",
            "iPad7,3": "iPad Pro 10.5-inch",
            "iPad7,4": "iPad Pro 10.5-inch",
            "iPad7,5": "iPad (6th generation)",
            "iPad7,6": "iPad (6th generation)",
            "iPad7,11": "iPad (7th generation)",
            "iPad7,12": "iPad (7th generation)",
            "iPad11,1": "iPad mini (5th generation)",
            "iPad11,2": "iPad mini (5th generation)",
            "iPad11,3": "iPad Air (3rd generation)",
            "iPad11,4": "iPad Air (3rd generation)",
            "iPad11,6": "iPad (8th generation)",
            "iPad11,7": "iPad (8th generation)",
            "iPad12,1": "iPad (9th generation)",
            "iPad12,2": "iPad (9th generation)",
            "iPad13,8": "iPad Pro 11-inch (5th generation)",
            "iPad13,9": "iPad Pro 11-inch (5th generation)",
            "iPad13,10": "iPad Pro 11-inch (5th generation)",
            "iPad13,11": "iPad Pro 11-inch (5th generation)",
            "iPad13,12": "iPad Pro 12.9-inch (5th generation)",
            "iPad13,13": "iPad Pro 12.9-inch (5th generation)",
            "iPad13,14": "iPad Pro 12.9-inch (5th generation)",
            "iPad13,15": "iPad Pro 12.9-inch (5th generation)",
            "iPad14,3": "iPad Pro 11-inch (6th generation)",
            "iPad14,4": "iPad Pro 11-inch (6th generation)",
            "iPad14,5": "iPad Pro 12.9-inch (6th generation)",
            "iPad14,6": "iPad Pro 12.9-inch (6th generation)",
            
            // Apple Watch models (if needed)
            "Watch6,1": "Apple Watch Series 6",
            "Watch6,2": "Apple Watch Series 6",
            "Watch6,3": "Apple Watch Series 6",
            "Watch6,4": "Apple Watch Series 6",
            "Watch5,1": "Apple Watch Series 5",
            "Watch5,2": "Apple Watch Series 5",
            "Watch5,3": "Apple Watch Series 5",
            "Watch5,4": "Apple Watch Series 5",
            "Watch4,1": "Apple Watch Series 4",
            "Watch4,2": "Apple Watch Series 4",
            "Watch4,3": "Apple Watch Series 4",
            "Watch4,4": "Apple Watch Series 4",
            "Watch3,1": "Apple Watch Series 3",
            "Watch3,2": "Apple Watch Series 3",
            "Watch3,3": "Apple Watch Series 3",
            "Watch3,4": "Apple Watch Series 3",
            "Watch2,6": "Apple Watch Series 2",
            "Watch2,7": "Apple Watch Series 2",
            "Watch2,3": "Apple Watch Series 1",
            "Watch2,4": "Apple Watch Series 1",
            "Watch1,1": "Apple Watch",
            "Watch1,2": "Apple Watch"
        ]
        
        return modelMapping[deviceModel] ?? deviceModel
    }
    
    /// Convert to dictionary for JSON serialization
    public func toDictionary() -> [String: Any] {
        return [
            "os": os,
            "version": version,
            "model": model,
            "deviceId": deviceId
        ]
    }
}
