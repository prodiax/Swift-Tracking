import Foundation

/// Utility class for tracking app version changes and install/update events
public class AppVersionTracker {
    private let storage: TrackingStorage
    private weak var tracker: Tracker?
    
    public init(storage: TrackingStorage, tracker: Tracker) {
        self.storage = storage
        self.tracker = tracker
    }
    
    /// Check for app install/update and track appropriate events
    public func checkAndTrackAppVersion() {
        let info = Bundle.main.infoDictionary
        let currentBuild = info?["CFBundleVersion"] as? String
        let currentVersion = info?["CFBundleShortVersionString"] as? String
        
        let previousBuild = storage.getAppBuild()
        let previousVersion = storage.getAppVersion()
        
        // Update stored versions
        if let currentBuild = currentBuild {
            storage.setAppBuild(currentBuild)
        }
        if let currentVersion = currentVersion {
            storage.setAppVersion(currentVersion)
        }
        
        // Check if this is a first install
        if previousBuild == nil || previousVersion == nil {
            if !storage.hasInstalledEventBeenSent() {
                trackAppInstalledEvent(version: currentVersion, build: currentBuild)
                storage.setInstalledEventSent(true)
            }
        } else if currentBuild != previousBuild || currentVersion != previousVersion {
            // App was updated
            trackAppUpdatedEvent(
                currentVersion: currentVersion,
                currentBuild: currentBuild,
                previousVersion: previousVersion,
                previousBuild: previousBuild
            )
        }
    }
    
    private func trackAppInstalledEvent(version: String?, build: String?) {
        var eventData: [String: Any] = [:]
        eventData[TrackingConstants.APP_VERSION_PROPERTY] = version ?? ""
        eventData[TrackingConstants.APP_BUILD_PROPERTY] = build ?? ""
        
        tracker?.track(eventType: TrackingConstants.APPLICATION_INSTALLED_EVENT, data: eventData)
    }
    
    private func trackAppUpdatedEvent(
        currentVersion: String?,
        currentBuild: String?,
        previousVersion: String?,
        previousBuild: String?
    ) {
        var eventData: [String: Any] = [:]
        eventData[TrackingConstants.APP_VERSION_PROPERTY] = currentVersion ?? ""
        eventData[TrackingConstants.APP_BUILD_PROPERTY] = currentBuild ?? ""
        eventData[TrackingConstants.APP_PREVIOUS_VERSION_PROPERTY] = previousVersion ?? ""
        eventData[TrackingConstants.APP_PREVIOUS_BUILD_PROPERTY] = previousBuild ?? ""
        
        tracker?.track(eventType: TrackingConstants.APPLICATION_UPDATED_EVENT, data: eventData)
    }
}
