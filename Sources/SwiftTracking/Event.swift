import Foundation

/// Individual event structure
public struct TrackingEvent: Codable {
    /// Unique event identifier
    public let eventId: String
    
    /// Event timestamp in UTC ISO format
    public let timestampUtc: String
    
    /// Event type (e.g., "tap/button", "screen_view", "app_lifecycle")
    public let eventType: String
    
    /// Current page URL (for web-like tracking)
    public let pageUrl: String
    
    /// Current page title
    public let pageTitle: String
    
    /// Event data payload
    public let data: [String: AnyCodable]
    
    /// Element details for UI interactions
    public let elementDetails: String?
    
    public init(
        eventType: String,
        pageUrl: String = "",
        pageTitle: String = "",
        data: [String: Any] = [:],
        elementDetails: String? = nil
    ) {
        self.eventId = UUID().uuidString
        self.timestampUtc = Self.getCurrentTimestamp()
        self.eventType = eventType
        self.pageUrl = pageUrl
        self.pageTitle = pageTitle
        self.data = data.mapValues { AnyCodable($0) }
        self.elementDetails = elementDetails
    }
    
    private static func getCurrentTimestamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: Date())
    }
}

/// Main tracking payload structure
public struct TrackingPayload: Codable {
    /// Product identifier
    public let productId: String
    
    /// Session identifier
    public let sessionId: String
    
    /// Anonymous identifier
    public let anonymousId: String
    
    /// User identifier (optional)
    public let userId: String?
    
    /// Payload timestamp in UTC ISO format
    public let timestampUtc: String
    
    /// Device information
    public let deviceInfo: [String: AnyCodable]
    
    /// Current page URL
    public let pageUrl: String
    
    /// Array of events
    public let events: [TrackingEvent]
    
    public init(
        productId: String,
        sessionId: String,
        anonymousId: String,
        userId: String? = nil,
        pageUrl: String = "",
        events: [TrackingEvent],
        deviceInfo: [String: Any]
    ) {
        self.productId = productId
        self.sessionId = sessionId
        self.anonymousId = anonymousId
        self.userId = userId
        self.timestampUtc = Self.getCurrentTimestamp()
        self.pageUrl = pageUrl
        self.events = events
        self.deviceInfo = deviceInfo.mapValues { AnyCodable($0) }
    }
    
    private static func getCurrentTimestamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: Date())
    }
}

/// Helper for encoding Any values in Codable structures
public struct AnyCodable: Codable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.typeMismatch(AnyCodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}
