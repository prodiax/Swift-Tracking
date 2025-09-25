import XCTest
@testable import SwiftTracking

final class EventTests: XCTestCase {
    
    func testTrackingEventInitialization() {
        let event = TrackingEvent(
            eventType: "test_event",
            pageUrl: "https://example.com",
            pageTitle: "Test Page",
            data: ["key": "value"],
            elementDetails: "Test Element"
        )
        
        XCTAssertEqual(event.eventType, "test_event")
        XCTAssertEqual(event.pageUrl, "https://example.com")
        XCTAssertEqual(event.pageTitle, "Test Page")
        XCTAssertEqual(event.data["key"]?.value as? String, "value")
        XCTAssertEqual(event.elementDetails, "Test Element")
        XCTAssertFalse(event.eventId.isEmpty)
        XCTAssertFalse(event.timestampUtc.isEmpty)
    }
    
    func testTrackingPayloadInitialization() {
        let event = TrackingEvent(eventType: "test_event")
        let payload = TrackingPayload(
            productId: "test-product",
            sessionId: "test-session",
            anonymousId: "test-anon",
            userId: "test-user",
            pageUrl: "https://example.com",
            events: [event],
            deviceInfo: ["os": "iOS", "version": "17.0"]
        )
        
        XCTAssertEqual(payload.productId, "test-product")
        XCTAssertEqual(payload.sessionId, "test-session")
        XCTAssertEqual(payload.anonymousId, "test-anon")
        XCTAssertEqual(payload.userId, "test-user")
        XCTAssertEqual(payload.pageUrl, "https://example.com")
        XCTAssertEqual(payload.events.count, 1)
        XCTAssertEqual(payload.events.first?.eventType, "test_event")
        XCTAssertEqual(payload.deviceInfo["os"]?.value as? String, "iOS")
        XCTAssertEqual(payload.deviceInfo["version"]?.value as? String, "17.0")
        XCTAssertFalse(payload.timestampUtc.isEmpty)
    }
    
    func testAnyCodableEncoding() {
        let anyCodable = AnyCodable("test string")
        XCTAssertEqual(anyCodable.value as? String, "test string")
        
        let intCodable = AnyCodable(42)
        XCTAssertEqual(intCodable.value as? Int, 42)
        
        let boolCodable = AnyCodable(true)
        XCTAssertEqual(boolCodable.value as? Bool, true)
        
        let arrayCodable = AnyCodable([1, 2, 3])
        XCTAssertEqual(arrayCodable.value as? [Int], [1, 2, 3])
        
        let dictCodable = AnyCodable(["key": "value"])
        XCTAssertEqual(dictCodable.value as? [String: String], ["key": "value"])
    }
    
    func testEventJSONEncoding() throws {
        let event = TrackingEvent(
            eventType: "test_event",
            data: ["count": 42, "enabled": true]
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(event)
        
        XCTAssertFalse(data.isEmpty)
        
        // Verify we can decode it back
        let decoder = JSONDecoder()
        let decodedEvent = try decoder.decode(TrackingEvent.self, from: data)
        
        XCTAssertEqual(decodedEvent.eventType, "test_event")
        XCTAssertEqual(decodedEvent.data["count"]?.value as? Int, 42)
        XCTAssertEqual(decodedEvent.data["enabled"]?.value as? Bool, true)
    }
}
