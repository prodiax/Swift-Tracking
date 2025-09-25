import Foundation

/// Constants for tracking events and properties
public struct TrackingConstants {
    // MARK: - Event Types
    public static let SESSION_START_EVENT = "session_start"
    public static let SESSION_END_EVENT = "session_end"
    public static let APPLICATION_INSTALLED_EVENT = "Application Installed"
    public static let APPLICATION_UPDATED_EVENT = "Application Updated"
    public static let APPLICATION_OPENED_EVENT = "Application Opened"
    public static let APPLICATION_BACKGROUNDED_EVENT = "Application Backgrounded"
    public static let DEEP_LINK_OPENED_EVENT = "Deep Link Opened"
    public static let SCREEN_VIEWED_EVENT = "Screen Viewed"
    public static let ELEMENT_INTERACTED_EVENT = "Element Interacted"
    public static let NETWORK_REQUEST_EVENT = "Network Request"
    public static let RAGE_CLICK_EVENT = "Rage Click"
    public static let DEAD_CLICK_EVENT = "Dead Click"
    
    // MARK: - Event Properties
    public static let APP_VERSION_PROPERTY = "Version"
    public static let APP_BUILD_PROPERTY = "Build"
    public static let APP_PREVIOUS_VERSION_PROPERTY = "Previous Version"
    public static let APP_PREVIOUS_BUILD_PROPERTY = "Previous Build"
    public static let APP_FROM_BACKGROUND_PROPERTY = "From Background"
    public static let APP_LINK_URL_PROPERTY = "Link URL"
    public static let APP_LINK_REFERRER_PROPERTY = "Link Referrer"
    public static let APP_SCREEN_NAME_PROPERTY = "Screen Name"
    public static let APP_TARGET_AXLABEL_PROPERTY = "Target Accessibility Label"
    public static let APP_TARGET_AXIDENTIFIER_PROPERTY = "Target Accessibility Identifier"
    public static let APP_ACTION_PROPERTY = "Action"
    public static let APP_TARGET_VIEW_CLASS_PROPERTY = "Target View Class"
    public static let APP_TARGET_TEXT_PROPERTY = "Target Text"
    public static let APP_HIERARCHY_PROPERTY = "Hierarchy"
    public static let APP_ACTION_METHOD_PROPERTY = "Action Method"
    public static let APP_GESTURE_RECOGNIZER_PROPERTY = "Gesture Recognizer"
    
    // MARK: - Network Properties
    public static let NETWORK_URL_PROPERTY = "URL"
    public static let NETWORK_URL_QUERY_PROPERTY = "URL Query"
    public static let NETWORK_URL_FRAGMENT_PROPERTY = "URL Fragment"
    public static let NETWORK_REQUEST_METHOD_PROPERTY = "Request Method"
    public static let NETWORK_STATUS_CODE_PROPERTY = "Status Code"
    public static let NETWORK_ERROR_CODE_PROPERTY = "Error Code"
    public static let NETWORK_ERROR_MESSAGE_PROPERTY = "Error Message"
    public static let NETWORK_START_TIME_PROPERTY = "Start Time"
    public static let NETWORK_COMPLETION_TIME_PROPERTY = "Completion Time"
    public static let NETWORK_REQUEST_BODY_SIZE_PROPERTY = "Request Body Size"
    public static let NETWORK_RESPONSE_BODY_SIZE_PROPERTY = "Response Body Size"
    public static let NETWORK_REQUEST_HEADERS_PROPERTY = "Request Headers"
    public static let NETWORK_RESPONSE_HEADERS_PROPERTY = "Response Headers"
    public static let NETWORK_REQUEST_BODY_PROPERTY = "Request Body"
    public static let NETWORK_RESPONSE_BODY_PROPERTY = "Response Body"
    
    // MARK: - Frustration Interaction Properties
    public static let BEGIN_TIME_PROPERTY = "Begin Time"
    public static let END_TIME_PROPERTY = "End Time"
    public static let DURATION_PROPERTY = "Duration"
    public static let CLICKS_PROPERTY = "Clicks"
    public static let CLICK_COUNT_PROPERTY = "Click Count"
    public static let COORDINATE_X_PROPERTY = "X"
    public static let COORDINATE_Y_PROPERTY = "Y"
    
    // MARK: - Storage Keys
    public static let STORAGE_PREFIX = "swift-tracking"
    public static let APP_VERSION_KEY = "app_version"
    public static let APP_BUILD_KEY = "app_build"
    public static let PREVIOUS_SESSION_ID_KEY = "previous_session_id"
    public static let LAST_EVENT_TIME_KEY = "last_event_time"
    public static let INSTALLED_EVENT_SENT_KEY = "installed_event_sent"
}
