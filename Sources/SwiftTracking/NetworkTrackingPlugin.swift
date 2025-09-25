import Foundation

/// Plugin for tracking network requests
public class NetworkTrackingPlugin {
    private weak var tracker: Tracker?
    private var isEnabled: Bool = false
    private var config: TrackingConfig? { tracker?.configForPlugins() }
    
    public init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /// Enable or disable network tracking
    public func setEnabled(_ enabled: Bool) {
        self.isEnabled = enabled
    }
    
    /// Track a network request
    public func trackNetworkRequest(
        url: String,
        method: String,
        statusCode: Int? = nil,
        errorCode: Int? = nil,
        errorMessage: String? = nil,
        startTime: Date,
        completionTime: Date? = nil,
        requestBodySize: Int? = nil,
        responseBodySize: Int? = nil,
        requestHeaders: [String: String]? = nil,
        responseHeaders: [String: String]? = nil,
        requestBody: String? = nil,
        responseBody: String? = nil
    ) {
        guard isEnabled else { return }
        
        var eventData: [String: Any] = [:]
        eventData[TrackingConstants.NETWORK_URL_PROPERTY] = url
        eventData[TrackingConstants.NETWORK_REQUEST_METHOD_PROPERTY] = method
        eventData[TrackingConstants.NETWORK_START_TIME_PROPERTY] = startTime.timeIntervalSince1970
        
        // Parse URL components
        if let urlObj = URL(string: url) {
            if config?.captureNetworkQueryParams == true, let query = urlObj.query {
                eventData[TrackingConstants.NETWORK_URL_QUERY_PROPERTY] = Self.redactQuery(query)
            }
            if urlObj.fragment != nil {
                // fragments rarely contain sensitive data but exclude by default
            }
        }
        
        if let statusCode = statusCode {
            eventData[TrackingConstants.NETWORK_STATUS_CODE_PROPERTY] = statusCode
        }
        
        if let errorCode = errorCode {
            eventData[TrackingConstants.NETWORK_ERROR_CODE_PROPERTY] = errorCode
        }
        
        if let errorMessage = errorMessage {
            eventData[TrackingConstants.NETWORK_ERROR_MESSAGE_PROPERTY] = errorMessage
        }
        
        if let completionTime = completionTime {
            eventData[TrackingConstants.NETWORK_COMPLETION_TIME_PROPERTY] = completionTime.timeIntervalSince1970
        }
        
        if let requestBodySize = requestBodySize {
            eventData[TrackingConstants.NETWORK_REQUEST_BODY_SIZE_PROPERTY] = requestBodySize
        }
        
        if let responseBodySize = responseBodySize {
            eventData[TrackingConstants.NETWORK_RESPONSE_BODY_SIZE_PROPERTY] = responseBodySize
        }
        
        if config?.captureNetworkHeaders == true {
            if let requestHeaders = requestHeaders {
                eventData[TrackingConstants.NETWORK_REQUEST_HEADERS_PROPERTY] = Self.redactHeaders(requestHeaders)
            }
            if let responseHeaders = responseHeaders {
                eventData[TrackingConstants.NETWORK_RESPONSE_HEADERS_PROPERTY] = Self.redactHeaders(responseHeaders)
            }
        }
        
        if config?.captureNetworkBodies == true {
            if let requestBody = requestBody {
                eventData[TrackingConstants.NETWORK_REQUEST_BODY_PROPERTY] = Self.redactBody(requestBody)
            }
            if let responseBody = responseBody {
                eventData[TrackingConstants.NETWORK_RESPONSE_BODY_PROPERTY] = Self.redactBody(responseBody)
            }
        }
        
        tracker?.track(eventType: TrackingConstants.NETWORK_REQUEST_EVENT, data: eventData)
    }
    
    /// Track a successful network request
    public func trackSuccessfulRequest(
        url: String,
        method: String,
        statusCode: Int,
        startTime: Date,
        completionTime: Date,
        requestBodySize: Int? = nil,
        responseBodySize: Int? = nil,
        requestHeaders: [String: String]? = nil,
        responseHeaders: [String: String]? = nil
    ) {
        trackNetworkRequest(
            url: url,
            method: method,
            statusCode: statusCode,
            startTime: startTime,
            completionTime: completionTime,
            requestBodySize: requestBodySize,
            responseBodySize: responseBodySize,
            requestHeaders: requestHeaders,
            responseHeaders: responseHeaders
        )
    }
    
    /// Track a failed network request
    public func trackFailedRequest(
        url: String,
        method: String,
        errorCode: Int,
        errorMessage: String,
        startTime: Date,
        completionTime: Date? = nil,
        requestBodySize: Int? = nil
    ) {
        trackNetworkRequest(
            url: url,
            method: method,
            errorCode: errorCode,
            errorMessage: errorMessage,
            startTime: startTime,
            completionTime: completionTime,
            requestBodySize: requestBodySize
        )
    }
}

// MARK: - Redaction

extension NetworkTrackingPlugin {
    private static let sensitiveHeaderKeys: Set<String> = [
        "authorization", "proxy-authorization", "x-api-key", "api-key", "x-auth-token",
        "cookie", "set-cookie"
    ]
    
    private static func redactHeaders(_ headers: [String: String]) -> [String: String] {
        var redacted: [String: String] = [:]
        for (k, v) in headers {
            if sensitiveHeaderKeys.contains(k.lowercased()) {
                redacted[k] = "[REDACTED]"
            } else {
                redacted[k] = v
            }
        }
        return redacted
    }
    
    private static func redactQuery(_ query: String) -> String {
        // Basic redaction for common sensitive params
        let sensitiveParams = ["password", "pass", "pwd", "token", "secret", "apikey", "api_key", "auth"]
        let pairs = query.split(separator: "&")
        let mapped = pairs.map { pair -> String in
            let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { return String(pair) }
            let key = parts[0]
            if sensitiveParams.contains(key.lowercased()) { return "\(key)=[REDACTED]" }
            return String(pair)
        }
        return mapped.joined(separator: "&")
    }
    
    private static func redactBody(_ body: String) -> String {
        // Heuristic redaction: replace obvious secrets
        var redacted = body
        let patterns = [
            "\\\"password\\\"\\s*:\\s*\\\"[^\\\"]*\\\"",
            "\\\"token\\\"\\s*:\\s*\\\"[^\\\"]*\\\"",
            "\\\"secret\\\"\\s*:\\s*\\\"[^\\\"]*\\\"",
            "api[_-]?key\\s*[:=]\\s*\\\"[^\\\"]*\\\""
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                redacted = regex.stringByReplacingMatches(in: redacted, options: [], range: NSRange(location: 0, length: redacted.utf16.count), withTemplate: "\"[REDACTED]\"")
            }
        }
        return redacted
    }
}
