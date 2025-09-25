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
}
