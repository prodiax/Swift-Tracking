import Foundation

/// Utility class for tracking deep link events
public class DeepLinkTracker {
    private weak var tracker: Tracker?
    
    public init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /// Track a deep link opened event
    public func trackDeepLinkOpened(url: String, referrer: String? = nil) {
        var eventData: [String: Any] = [:]
        eventData[TrackingConstants.APP_LINK_URL_PROPERTY] = url
        
        if let referrer = referrer {
            eventData[TrackingConstants.APP_LINK_REFERRER_PROPERTY] = referrer
        }
        
        tracker?.track(eventType: TrackingConstants.DEEP_LINK_OPENED_EVENT, data: eventData)
    }
    
    /// Track a deep link opened event with URL object
    public func trackDeepLinkOpened(url: URL, referrer: URL? = nil) {
        trackDeepLinkOpened(url: url.absoluteString, referrer: referrer?.absoluteString)
    }
    
    /// Track a deep link opened event with NSUserActivity
    @available(iOS 11.0, tvOS 11.0, macOS 10.13, watchOS 4.0, *)
    public func trackDeepLinkOpened(activity: NSUserActivity) {
        let url = activity.webpageURL?.absoluteString
        let referrer = activity.referrerURL?.absoluteString
        trackDeepLinkOpened(url: url ?? "", referrer: referrer)
    }
}
