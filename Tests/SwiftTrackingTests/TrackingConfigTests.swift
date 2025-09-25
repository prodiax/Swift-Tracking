import XCTest
@testable import SwiftTracking

final class TrackingConfigTests: XCTestCase {
    
    func testTrackingConfigInitialization() {
        let config = TrackingConfig(
            productId: "test-product",
            trackingEndpoint: "https://example.com/track"
        )
        
        XCTAssertEqual(config.productId, "test-product")
        XCTAssertEqual(config.trackingEndpoint, "https://example.com/track")
        XCTAssertNil(config.userId)
        XCTAssertNil(config.anonymousId)
        XCTAssertTrue(config.enableAutoCapture)
        XCTAssertEqual(config.sessionTimeoutSeconds, 3600)
        XCTAssertEqual(config.batchSize, 10)
        XCTAssertEqual(config.flushIntervalSeconds, 30)
    }
    
    func testTrackingConfigWithAllParameters() {
        let config = TrackingConfig(
            productId: "test-product",
            trackingEndpoint: "https://example.com/track",
            userId: "user-123",
            anonymousId: "anon-456",
            enableAutoCapture: false,
            sessionTimeoutSeconds: 1800,
            batchSize: 5,
            flushIntervalSeconds: 15
        )
        
        XCTAssertEqual(config.productId, "test-product")
        XCTAssertEqual(config.trackingEndpoint, "https://example.com/track")
        XCTAssertEqual(config.userId, "user-123")
        XCTAssertEqual(config.anonymousId, "anon-456")
        XCTAssertFalse(config.enableAutoCapture)
        XCTAssertEqual(config.sessionTimeoutSeconds, 1800)
        XCTAssertEqual(config.batchSize, 5)
        XCTAssertEqual(config.flushIntervalSeconds, 15)
    }
}
