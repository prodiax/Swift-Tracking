# Amplitude-Swift Auto-Capture Events Analysis

## Complete List of Auto-Capture Events from Amplitude-Swift

### 1. Session Events
- **session_start** - When a new session begins
- **session_end** - When a session ends (timeout or app background)

### 2. App Lifecycle Events
- **Application Installed** - First app launch after installation
- **Application Updated** - App launch after version/build change
- **Application Opened** - App becomes active (with from_background property)
- **Application Backgrounded** - App goes to background

### 3. Screen Tracking
- **Screen Viewed** - Automatic screen view tracking with screen name

### 4. Element Interaction Events
- **Element Interacted** - UI element interactions with:
  - Target Accessibility Label
  - Target Accessibility Identifier
  - Action type
  - Target View Class
  - Target Text
  - View Hierarchy
  - Action Method
  - Gesture Recognizer

### 5. Network Tracking
- **Network Request** - HTTP requests with:
  - URL
  - Request Method
  - Status Code
  - Error Code/Message
  - Start Time
  - Completion Time
  - Request Body Size
  - Response Body Size
  - Request Headers
  - Response Headers
  - Request Body
  - Response Body

### 6. Frustration Interaction Events
- **Rage Click** - Multiple rapid clicks on same element with:
  - Click coordinates (X, Y)
  - Click timestamps
  - Click count
  - Duration
  - Begin/End time
- **Dead Click** - Clicks that don't trigger any response

### 7. Deep Link Events
- **Deep Link Opened** - Deep link handling with:
  - Link URL
  - Link Referrer

### 8. Gesture Recognition Events
- **Tap** - Single tap gestures
- **Long Press** - Long press gestures
- **Pinch** - Pinch gestures (iOS only)
- **Rotation** - Rotation gestures (iOS only)
- **Screen Edge Pan** - Edge pan gestures (iOS only)
- **Hover** - Hover gestures (iOS only)

## Auto-Capture Options in Amplitude-Swift

```swift
public struct AutocaptureOptions: OptionSet {
    public static let sessions            = AutocaptureOptions(rawValue: 1 << 0)
    public static let appLifecycles       = AutocaptureOptions(rawValue: 1 << 1)
    public static let screenViews         = AutocaptureOptions(rawValue: 1 << 2)
    public static let elementInteractions = AutocaptureOptions(rawValue: 1 << 3)
    public static let networkTracking     = AutocaptureOptions(rawValue: 1 << 4)
    public static let frustrationInteractions = AutocaptureOptions(rawValue: 1 << 5)
}
```

## Event Properties and Data

### App Lifecycle Properties
- `[Amplitude] Version` - App version
- `[Amplitude] Build` - App build number
- `[Amplitude] Previous Version` - Previous app version
- `[Amplitude] Previous Build` - Previous app build
- `[Amplitude] From Background` - Whether app opened from background

### Screen View Properties
- `[Amplitude] Screen Name` - Name of the screen viewed

### Element Interaction Properties
- `[Amplitude] Target Accessibility Label` - Accessibility label
- `[Amplitude] Target Accessibility Identifier` - Accessibility identifier
- `[Amplitude] Action` - Action performed
- `[Amplitude] Target View Class` - View class name
- `[Amplitude] Target Text` - Text content
- `[Amplitude] Hierarchy` - View hierarchy
- `[Amplitude] Action Method` - Method name for action
- `[Amplitude] Gesture Recognizer` - Gesture recognizer type

### Network Properties
- `[Amplitude] URL` - Request URL
- `[Amplitude] URL Query` - URL query parameters
- `[Amplitude] URL Fragment` - URL fragment
- `[Amplitude] Request Method` - HTTP method
- `[Amplitude] Status Code` - HTTP status code
- `[Amplitude] Error Code` - Error code
- `[Amplitude] Error Message` - Error message
- `[Amplitude] Start Time` - Request start time
- `[Amplitude] Completion Time` - Request completion time
- `[Amplitude] Request Body Size` - Request body size
- `[Amplitude] Response Body Size` - Response body size
- `[Amplitude] Request Headers` - Request headers
- `[Amplitude] Response Headers` - Response headers
- `[Amplitude] Request Body` - Request body content
- `[Amplitude] Response Body` - Response body content

### Frustration Interaction Properties
- `[Amplitude] Begin Time` - First click time
- `[Amplitude] End Time` - Last click time
- `[Amplitude] Duration` - Total duration
- `[Amplitude] Clicks` - Array of click coordinates and times
- `[Amplitude] Click Count` - Number of clicks
- `[Amplitude] X` - X coordinate
- `[Amplitude] Y` - Y coordinate

### Deep Link Properties
- `[Amplitude] Link URL` - Deep link URL
- `[Amplitude] Link Referrer` - Referrer URL

## Implementation Priority for Swift-Tracking

### High Priority (Core Functionality)
1. ✅ Session Events (session_start, session_end)
2. ✅ App Lifecycle Events (Application Opened, Backgrounded)
3. ✅ Screen View Tracking
4. ✅ Basic Element Interactions (button taps)

### Medium Priority (Enhanced Tracking)
5. Application Install/Update Events
6. Deep Link Tracking
7. Enhanced Element Interactions (accessibility labels, view hierarchy)
8. Gesture Recognition (tap, long press)

### Low Priority (Advanced Features)
9. Network Request Tracking
10. Frustration Interactions (rage click, dead click)
11. Advanced Gestures (pinch, rotation, edge pan)
12. Network Connectivity Checking

## SwiftUI-Specific Considerations

- SwiftUI doesn't have UIKit's view hierarchy, so some properties need adaptation
- Gesture tracking in SwiftUI uses different APIs
- Screen tracking needs to be manual with view modifiers
- Element identification relies on accessibility labels and custom identifiers
- Network tracking can use URLSession monitoring
- Deep link handling uses SwiftUI's onOpenURL modifier
