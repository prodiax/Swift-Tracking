import Foundation

/// Simple storage system for tracking data
public class TrackingStorage {
    private let userDefaults: UserDefaults
    
    public init() {
        self.userDefaults = UserDefaults.standard
    }
    
    // MARK: - App Version Tracking
    
    public func getAppVersion() -> String? {
        return userDefaults.string(forKey: TrackingConstants.APP_VERSION_KEY)
    }
    
    public func setAppVersion(_ version: String) {
        userDefaults.set(version, forKey: TrackingConstants.APP_VERSION_KEY)
    }
    
    public func getAppBuild() -> String? {
        return userDefaults.string(forKey: TrackingConstants.APP_BUILD_KEY)
    }
    
    public func setAppBuild(_ build: String) {
        userDefaults.set(build, forKey: TrackingConstants.APP_BUILD_KEY)
    }
    
    // MARK: - Session Tracking
    
    public func getPreviousSessionId() -> String? {
        return userDefaults.string(forKey: TrackingConstants.PREVIOUS_SESSION_ID_KEY)
    }
    
    public func setPreviousSessionId(_ sessionId: String) {
        userDefaults.set(sessionId, forKey: TrackingConstants.PREVIOUS_SESSION_ID_KEY)
    }
    
    public func getLastEventTime() -> Date? {
        return userDefaults.object(forKey: TrackingConstants.LAST_EVENT_TIME_KEY) as? Date
    }
    
    public func setLastEventTime(_ date: Date) {
        userDefaults.set(date, forKey: TrackingConstants.LAST_EVENT_TIME_KEY)
    }
    
    // MARK: - Install Event Tracking
    
    public func hasInstalledEventBeenSent() -> Bool {
        return userDefaults.bool(forKey: TrackingConstants.INSTALLED_EVENT_SENT_KEY)
    }
    
    public func setInstalledEventSent(_ sent: Bool) {
        userDefaults.set(sent, forKey: TrackingConstants.INSTALLED_EVENT_SENT_KEY)
    }
    
    // MARK: - Generic Storage
    
    public func getString(forKey key: String) -> String? {
        return userDefaults.string(forKey: key)
    }
    
    public func setString(_ value: String, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    public func getBool(forKey key: String) -> Bool {
        return userDefaults.bool(forKey: key)
    }
    
    public func setBool(_ value: Bool, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    public func getDate(forKey key: String) -> Date? {
        return userDefaults.object(forKey: key) as? Date
    }
    
    public func setDate(_ value: Date, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
}
