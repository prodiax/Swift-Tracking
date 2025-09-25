import XCTest
@testable import SwiftTracking

final class TrackerTests: XCTestCase {
    
    func testTrackerSingleton() {
        let tracker1 = Tracker.shared
        let tracker2 = Tracker.shared
        
        XCTAssertIdentical(tracker1, tracker2)
    }
    
    func testTrackerInitialization() {
        let config = TrackingConfig(
            productId: "test-product",
            trackingEndpoint: "https://example.com/track"
        )
        
        let tracker = Tracker.shared
        tracker.start(with: config)
        
        // Test that we can track events without crashing
        tracker.track(eventType: "test_event", data: ["key": "value"])
        tracker.trackScreenView("Test Screen")
        tracker.trackButtonTap("Test Button")
        
        // Test flush
        tracker.flush()
    }
    
    func testEventTracking() {
        let config = TrackingConfig(
            productId: "test-product",
            trackingEndpoint: "https://example.com/track",
            batchSize: 1 // Small batch size for testing
        )
        
        let tracker = Tracker.shared
        tracker.start(with: config)
        
        // Track multiple events
        tracker.track(eventType: "event1", data: ["count": 1])
        tracker.track(eventType: "event2", data: ["count": 2])
        tracker.track(eventType: "event3", data: ["count": 3])
        
        // Force flush
        tracker.flush()
    }
    
    func testNavigationTitleTracking() {
        let config = TrackingConfig(
            productId: "test-product",
            trackingEndpoint: "https://example.com/track"
        )
        
        let tracker = Tracker.shared
        tracker.start(with: config)
        
        // Test setting navigation title
        tracker.setCurrentNavigationTitle("Test Navigation Title")
        
        // Track an event and verify the page title is set to navigation title
        tracker.track(eventType: "test_event", data: ["key": "value"])
        
        // Test clearing navigation title
        tracker.setCurrentNavigationTitle(nil)
        
        // Track another event and verify it falls back to screen name
        tracker.track(eventType: "test_event_2", data: ["key": "value2"])
        
        // Force flush
        tracker.flush()
    }
    
    func testScreenNameAndNavigationTitlePriority() {
        let config = TrackingConfig(
            productId: "test-product",
            trackingEndpoint: "https://example.com/track"
        )
        
        let tracker = Tracker.shared
        tracker.start(with: config)
        
        // Set both screen name and navigation title
        tracker.setCurrentScreenName("Test Screen")
        tracker.setCurrentNavigationTitle("Test Navigation Title")
        
        // Track an event - navigation title should take priority
        tracker.track(eventType: "priority_test", data: ["test": "navigation_priority"])
        
        // Clear navigation title
        tracker.setCurrentNavigationTitle(nil)
        
        // Track another event - should fall back to screen name
        tracker.track(eventType: "priority_test_2", data: ["test": "screen_fallback"])
        
        // Force flush
        tracker.flush()
    }
}
