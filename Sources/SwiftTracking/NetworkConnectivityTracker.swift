import Foundation
import Network

/// Tracker for network connectivity and offline mode handling
@available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 5.0, *)
public class NetworkConnectivityTracker {
    private weak var tracker: Tracker?
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.swifttracking.network")
    private var isOnline: Bool = true
    private var isEnabled: Bool = false
    
    public init(tracker: Tracker) {
        self.tracker = tracker
        setupNetworkMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    /// Enable or disable network connectivity tracking
    public func setEnabled(_ enabled: Bool) {
        self.isEnabled = enabled
        if enabled {
            monitor.start(queue: queue)
        } else {
            monitor.cancel()
        }
    }
    
    /// Check if device is currently online
    public var isDeviceOnline: Bool {
        return isOnline
    }
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self, self.isEnabled else { return }
            
            let wasOnline = self.isOnline
            self.isOnline = path.status == .satisfied
            
            // Track connectivity changes
            if wasOnline != self.isOnline {
                self.trackConnectivityChange(isOnline: self.isOnline)
            }
        }
    }
    
    private func trackConnectivityChange(isOnline: Bool) {
        var eventData: [String: Any] = [:]
        eventData["is_online"] = isOnline
        eventData["connection_type"] = getConnectionType()
        
        tracker?.track(eventType: "network_connectivity_changed", data: eventData)
    }
    
    private func getConnectionType() -> String {
        // This would need to be implemented based on the specific platform
        // For now, return a generic type
        return "unknown"
    }
    
    /// Track offline events when network requests fail due to connectivity
    public func trackOfflineEvent(url: String, method: String) {
        guard !isOnline else { return }
        
        var eventData: [String: Any] = [:]
        eventData["url"] = url
        eventData["method"] = method
        eventData["reason"] = "offline"
        
        tracker?.track(eventType: "network_request_failed_offline", data: eventData)
    }
    
    /// Queue events for later sending when connectivity is restored
    public func queueEventForLater(_ event: TrackingEvent) {
        // This would implement offline event queuing
        // For now, we'll just track that an event was queued
        var eventData: [String: Any] = [:]
        eventData["event_type"] = event.eventType
        eventData["queued_at"] = Date().timeIntervalSince1970
        
        tracker?.track(eventType: "event_queued_offline", data: eventData)
    }
}
