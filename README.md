# SwiftTracking

A comprehensive Swift tracking SDK inspired by Amplitude-Swift, designed for SwiftUI applications with extensive auto-capture capabilities.

## Features

### Core Tracking
- **Event Tracking**: Track custom events with flexible data payloads
- **Screen View Tracking**: Automatic screen view tracking for SwiftUI
- **Session Management**: Automatic session start/end tracking with timeout handling
- **Device Information**: Automatic device info collection across all platforms
- **User Identification**: Support for anonymous and identified users

### Auto-Capture Features
- **Application Lifecycle**: Track app install, update, open, and background events
- **Session Events**: Automatic session_start and session_end events
- **Screen Views**: Track screen navigation with proper screen name extraction
- **Element Interactions**: Track button taps, text field interactions, and list item selections
- **Deep Link Tracking**: Track deep link opens with URL and referrer information
- **Network Request Tracking**: Monitor HTTP requests with timing, status codes, and error handling
- **Frustration Interactions**: Detect rage clicks and dead clicks
- **Gesture Tracking**: Track tap, long press, drag, pinch, and rotation gestures
- **Accessibility Support**: Track accessibility labels and identifiers for UI elements

### SwiftUI Integration
- **View Modifiers**: Easy-to-use modifiers for automatic tracking
- **Custom Components**: Pre-built tracking-aware UI components
- **Gesture Integration**: Built-in gesture tracking for common interactions
- **Cross-Platform**: Works on iOS, macOS, tvOS, and watchOS

### Advanced Features
- **Network Connectivity**: Monitor online/offline status and queue events
- **Event Batching**: Efficient event queuing and batching
- **Background Processing**: Handle events when app is backgrounded
- **Storage Management**: Persistent storage for session and version tracking

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/SwiftTracking.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version and add to your target

## Quick Start

### 1. Initialize the Tracker

```swift
import SwiftTracking

// Configure tracking
let config = TrackingConfig(
    productId: "your-product-id",
    trackingEndpoint: "https://your-api.com/track",
    enableAutoCapture: true,
    sessionTimeoutSeconds: 300,
    batchSize: 10,
    flushIntervalSeconds: 30
)

// Start tracking
Tracker.shared.start(with: config)

// Set user ID separately if needed
Tracker.shared.setUserId("user-123")
```

### 2. Track Events

```swift
// Track a custom event
Tracker.shared.track(eventType: "button_clicked", data: [
    "button_name": "sign_up",
    "screen": "onboarding"
])

// Track screen views
Tracker.shared.trackScreenView("Home Screen", data: [
    "user_type": "premium"
])

// Track element interactions
Tracker.shared.trackElementInteraction(
    action: "tap",
    targetViewClass: "Button",
    targetText: "Sign Up",
    accessibilityLabel: "Sign up button",
    accessibilityIdentifier: "sign_up_button",
    data: ["section": "onboarding"]
)
```

### 3. SwiftUI Integration

```swift
import SwiftUI
import SwiftTracking

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Hello, World!")
                    .trackScreenView("Home Screen")
                
                Button("Click me!") {
                    // Your action
                }
                .trackButtonTap("Click me!")
                
                // Use custom tracking components
                TrackingButton("Custom Button", data: ["section": "demo"]) {
                    // Your action
                } label: {
                    Text("Custom Button")
                }
            }
            .navigationTitle("Home")
            .trackNavigationTitle("Home", data: ["section": "main"])
        }
    }
}
```

### 4. Navigation Title Tracking

The SDK automatically captures navigation titles and uses them as the `page_title` in events:

```swift
struct DetailView: View {
    var body: some View {
        VStack {
            Text("Detail Content")
        }
        .navigationTitle("Detail Screen")
        .trackNavigationTitle("Detail Screen", data: ["source": "navigation"])
    }
}
```

For automatic detection without manual specification:

```swift
struct AutoTrackedView: View {
    var body: some View {
        VStack {
            Text("Auto-tracked content")
        }
        .autoTrackWithNavigationTitle(data: ["auto": true])
    }
}
```

## Auto-Capture Events

The SDK automatically tracks the following events when `enableAutoCapture` is true:

### Application Events
- `Application Installed` - First app launch
- `Application Updated` - App version changes
- `Application Opened` - App becomes active (with from_background property)
- `Application Backgrounded` - App goes to background

### Session Events
- `session_start` - New session begins
- `session_end` - Session ends (timeout or app background)

### Screen Events
- `Screen Viewed` - Screen navigation with screen name

### Interaction Events
- `Element Interacted` - UI element interactions with accessibility info
- `Deep Link Opened` - Deep link navigation with URL and referrer

### Network Events
- `Network Request` - HTTP requests with timing and status information

### Frustration Events
- `Rage Click` - Multiple rapid clicks in same area
- `Dead Click` - Clicks that don't trigger responses

## Configuration

### TrackingConfig

```swift
public struct TrackingConfig {
    public let productId: String                    // Your product identifier
    public let trackingEndpoint: String            // API endpoint for events
    public let enableAutoCapture: Bool             // Enable auto-capture features
    public let sessionTimeoutSeconds: Double       // Session timeout
    public let batchSize: Int                      // Batch size for flushing
    public let flushIntervalSeconds: Double        // Auto-flush interval
}
```

## API Reference

### Core Tracking Methods

```swift
// Basic event tracking
func track(eventType: String, data: [String: Any])

// Screen view tracking
func trackScreenView(_ screenName: String, data: [String: Any])

// Element interaction tracking
func trackElementInteraction(
    action: String,
    targetViewClass: String?,
    targetText: String?,
    accessibilityLabel: String?,
    accessibilityIdentifier: String?,
    hierarchy: [String]?,
    data: [String: Any]
)

// Deep link tracking
func trackDeepLinkOpened(url: String, referrer: String?)
func trackDeepLinkOpened(url: URL, referrer: URL?)

// Network request tracking
func trackNetworkRequest(
    url: String,
    method: String,
    statusCode: Int?,
    errorCode: Int?,
    errorMessage: String?,
    startTime: Date,
    completionTime: Date?,
    requestBodySize: Int?,
    responseBodySize: Int?,
    requestHeaders: [String: String]?,
    responseHeaders: [String: String]?,
    requestBody: String?,
    responseBody: String?
)

// Frustration interaction tracking
func trackClick(x: Double, y: Double)
func markClickResponse()

// Gesture tracking
func trackTapGesture(location: CGPoint, accessibilityLabel: String?, accessibilityIdentifier: String?, data: [String: Any])
func trackLongPressGesture(location: CGPoint, duration: TimeInterval, accessibilityLabel: String?, accessibilityIdentifier: String?, data: [String: Any])
func trackDragGesture(startLocation: CGPoint, endLocation: CGPoint, translation: CGSize, accessibilityLabel: String?, accessibilityIdentifier: String?, data: [String: Any])
func trackPinchGesture(location: CGPoint, scale: CGFloat, accessibilityLabel: String?, accessibilityIdentifier: String?, data: [String: Any])
func trackRotationGesture(location: CGPoint, angle: Angle, accessibilityLabel: String?, accessibilityIdentifier: String?, data: [String: Any])

// Utility methods
func flush() // Force flush events
func setUserId(_ userId: String) // Set user ID
func setCurrentScreenName(_ screenName: String) // Set current screen
func setCurrentNavigationTitle(_ navigationTitle: String?) // Set current navigation title
```

### SwiftUI Modifiers

```swift
// Screen view tracking
.trackScreenView(_ screenName: String, data: [String: Any])

// Navigation title tracking (automatically sets page_title to navigation title)
.trackNavigationTitle(_ title: String, data: [String: Any])

// Automatic navigation title detection
.autoTrackWithNavigationTitle(data: [String: Any])

// Button tap tracking
.trackButtonTap(_ buttonTitle: String, data: [String: Any])

// Element interaction tracking
.trackElementInteraction(action: String, targetViewClass: String?, targetText: String?, accessibilityLabel: String?, accessibilityIdentifier: String?, hierarchy: [String]?, data: [String: Any])

// Gesture tracking
.trackTapGesture(accessibilityLabel: String?, accessibilityIdentifier: String?, data: [String: Any])
.trackLongPressGesture(minimumDuration: Double, accessibilityLabel: String?, accessibilityIdentifier: String?, data: [String: Any])
.trackDragGesture(accessibilityLabel: String?, accessibilityIdentifier: String?, data: [String: Any])
.trackMagnificationGesture(accessibilityLabel: String?, accessibilityIdentifier: String?, data: [String: Any])
.trackRotationGesture(accessibilityLabel: String?, accessibilityIdentifier: String?, data: [String: Any])

// Frustration interaction tracking
.trackClicks() // Track clicks for rage click detection
.markClickResponse() // Mark click responses for dead click detection
```

### Custom Components

```swift
// Tracking-aware button
TrackingButton(
    _ buttonTitle: String,
    data: [String: Any],
    action: @escaping () -> Void,
    @ViewBuilder label: @escaping () -> Label
)

// Tracking-aware text field
TrackingTextField(
    _ placeholder: String,
    text: Binding<String>,
    accessibilityLabel: String?,
    accessibilityIdentifier: String?,
    data: [String: Any]
)
```

## Event Structure

Events are automatically structured with the following properties:

```swift
{
    "eventType": "button_clicked",
    "timestamp_utc": 1234567890.123,
    "data": {
        "button_name": "sign_up",
        "screen": "onboarding",
        "Action": "tap",
        "Target View Class": "Button",
        "Target Text": "Sign Up",
        "Target Accessibility Label": "Sign up button",
        "Target Accessibility Identifier": "sign_up_button"
    },
    "element_details": "SwiftUI Button(title=Sign Up)",
    "productId": "your-product-id",
    "sessionId": "session-uuid",
    "anonymousId": "device-uuid",
    "userId": "user-uuid",
    "device_info": {
        "os": "iOS",
        "version": "17.0",
        "model": "iPhone 15 Pro",
        "deviceId": "device-uuid"
    }
}
```

## Platform Support

- **iOS**: 13.0+
- **macOS**: 10.15+
- **tvOS**: 13.0+
- **watchOS**: 6.0+

## Examples

See the `Examples/` directory for comprehensive examples:

- `ComprehensiveExampleApp.swift` - Complete demo of all features
- `ExampleApp.swift` - Basic usage example

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

## Support

For support and questions, please open an issue on GitHub or contact our team.