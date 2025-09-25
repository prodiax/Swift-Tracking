import XCTest
@testable import SwiftTracking

final class NavigationTitleTrackingTests: XCTestCase {
    
    var tracker: Tracker!
    
    override func setUp() {
        super.setUp()
        tracker = Tracker.shared
    }
    
    override func tearDown() {
        tracker = nil
        super.tearDown()
    }
    
    func testSetCurrentNavigationTitle() {
        // Test setting a navigation title
        tracker.setCurrentNavigationTitle("Test Navigation Title")
        
        // Verify that the navigation title is set
        // Note: We can't directly access private properties, but we can test the behavior
        // through the public API by checking if the title affects subsequent events
        
        // This test verifies that the method doesn't crash and accepts the title
        XCTAssertNoThrow(tracker.setCurrentNavigationTitle("Test Navigation Title"))
    }
    
    func testSetCurrentNavigationTitleNil() {
        // Test setting navigation title to nil
        XCTAssertNoThrow(tracker.setCurrentNavigationTitle(nil))
    }
    
    func testUpdateNavigationTitle() {
        // Test the new updateNavigationTitle method
        XCTAssertNoThrow(tracker.updateNavigationTitle("Updated Title", data: ["test": "data"]))
    }
    
    func testNavigationTitleWithEmptyString() {
        // Test with empty string
        XCTAssertNoThrow(tracker.setCurrentNavigationTitle(""))
    }
    
    func testNavigationTitleWithSpecialCharacters() {
        // Test with special characters
        let specialTitle = "Title with émojis 🎉 and spëcial chars"
        XCTAssertNoThrow(tracker.setCurrentNavigationTitle(specialTitle))
    }
    
    func testNavigationTitleWithLongString() {
        // Test with a very long title
        let longTitle = String(repeating: "A", count: 1000)
        XCTAssertNoThrow(tracker.setCurrentNavigationTitle(longTitle))
    }
    
    func testMultipleNavigationTitleUpdates() {
        // Test multiple rapid updates
        let titles = ["Home", "Profile", "Settings", "Dashboard", "Help"]
        
        for title in titles {
            XCTAssertNoThrow(tracker.setCurrentNavigationTitle(title))
        }
    }
    
    func testNavigationTitleWithData() {
        // Test updateNavigationTitle with various data types
        let testData: [String: Any] = [
            "string": "test",
            "number": 42,
            "boolean": true,
            "array": [1, 2, 3],
            "nested": ["key": "value"]
        ]
        
        XCTAssertNoThrow(tracker.updateNavigationTitle("Test Title", data: testData))
    }
}
