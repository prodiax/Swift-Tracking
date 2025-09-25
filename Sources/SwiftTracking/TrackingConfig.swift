import Foundation

/// Configuration for the Swift Tracking SDK
public struct TrackingConfig {
    /// Required: Product identifier for tracking
    public let productId: String
    
    /// Required: Endpoint URL for sending tracking data
    public let trackingEndpoint: String
    
    /// Optional: Enable auto-capture features
    public let enableAutoCapture: Bool
    
    /// Optional: Session timeout in seconds (default: 1 hour)
    public let sessionTimeoutSeconds: TimeInterval
    
    /// Optional: Batch size for sending events (default: 10)
    public let batchSize: Int
    
    /// Optional: Flush interval in seconds (default: 30)
    public let flushIntervalSeconds: TimeInterval
    
    /// Privacy: include URL query params in network events (default: false)
    public let captureNetworkQueryParams: Bool
    
    /// Privacy: include request/response headers in network events (default: false)
    public let captureNetworkHeaders: Bool
    
    /// Privacy: include request/response bodies in network events (default: false)
    public let captureNetworkBodies: Bool
    
    /// Debug: enable debug logging (default: false)
    public let enableDebugLogging: Bool
    
    public init(
        productId: String,
        trackingEndpoint: String,
        enableAutoCapture: Bool = true,
        sessionTimeoutSeconds: TimeInterval = 3600, // 1 hour
        batchSize: Int = 10,
        flushIntervalSeconds: TimeInterval = 30,
        captureNetworkQueryParams: Bool = false,
        captureNetworkHeaders: Bool = false,
        captureNetworkBodies: Bool = false,
        enableDebugLogging: Bool = false
    ) {
        self.productId = productId
        self.trackingEndpoint = trackingEndpoint
        self.enableAutoCapture = enableAutoCapture
        self.sessionTimeoutSeconds = sessionTimeoutSeconds
        self.batchSize = batchSize
        self.flushIntervalSeconds = flushIntervalSeconds
        self.captureNetworkQueryParams = captureNetworkQueryParams
        self.captureNetworkHeaders = captureNetworkHeaders
        self.captureNetworkBodies = captureNetworkBodies
        self.enableDebugLogging = enableDebugLogging
    }
}
