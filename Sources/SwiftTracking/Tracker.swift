import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Main tracking singleton for Swift Tracking SDK
public class Tracker: ObservableObject {
    /// Shared singleton instance
    public static let shared = Tracker()
    
    // MARK: - Private Properties
    
    private var config: TrackingConfig?
    private var deviceInfo: DeviceInfo
    private var sessionId: String
    private var anonymousId: String
    private var lastEventTime: Date
    private var eventQueue: [TrackingEvent] = []
    private var flushTimer: Timer?
    private let queue = DispatchQueue(label: "com.swifttracking.queue", qos: .background)
    private let sessionQueue = DispatchQueue(label: "com.swifttracking.session", qos: .background)
    
    // Storage and version tracking
    private let storage: TrackingStorage
    private var appVersionTracker: AppVersionTracker?
    private var deepLinkTracker: DeepLinkTracker?
    private var elementInteractionTracker: ElementInteractionTracker?
    private var networkTrackingPlugin: NetworkTrackingPlugin?
    private var frustrationInteractionTracker: FrustrationInteractionTracker?
    private var gestureTracker: GestureTracker?
    
    // MARK: - Initialization
    
    private init() {
        self.deviceInfo = DeviceInfo()
        self.storage = TrackingStorage()
        self.sessionId = storage.getPreviousSessionId() ?? UUID().uuidString
        self.anonymousId = deviceInfo.deviceId
        self.lastEventTime = storage.getLastEventTime() ?? Date()
        
        setupLifecycleObservers()
    }
    
    // MARK: - Public Methods
    
    /// Start tracking with the provided configuration
    public func start(with config: TrackingConfig) {
        self.config = config
        self.anonymousId = config.anonymousId ?? deviceInfo.deviceId
        
        // Initialize app version tracker
        self.appVersionTracker = AppVersionTracker(storage: storage, tracker: self)
        
        // Initialize deep link tracker
        self.deepLinkTracker = DeepLinkTracker(tracker: self)
        
        // Initialize element interaction tracker
        self.elementInteractionTracker = ElementInteractionTracker(tracker: self)
        
        // Initialize network tracking plugin
        self.networkTrackingPlugin = NetworkTrackingPlugin(tracker: self)
        
        // Initialize frustration interaction tracker
        self.frustrationInteractionTracker = FrustrationInteractionTracker(tracker: self)
        
        // Initialize gesture tracker
        self.gestureTracker = GestureTracker(tracker: self)
        
        // Check for app install/update events
        if config.enableAutoCapture {
            appVersionTracker?.checkAndTrackAppVersion()
        }
        
        // Start session
        startNewSession()
        
        // Start flush timer
        startFlushTimer()
        
        // Track app launch
        if config.enableAutoCapture {
            trackAppLaunch()
        }
    }
    
    /// Track a custom event
    public func track(eventType: String, data: [String: Any] = [:]) {
        guard let config = config else {
            print("SwiftTracking: Tracker not initialized. Call start(with:) first.")
            return
        }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // Check if we need a new session
            if self.shouldStartNewSession() {
                self.startNewSession()
            }
            
            let event = TrackingEvent(
                eventType: eventType,
                pageUrl: self.getCurrentPageUrl(),
                pageTitle: self.getCurrentPageTitle(),
                data: data
            )
            
            self.eventQueue.append(event)
            self.lastEventTime = Date()
            self.storage.setLastEventTime(self.lastEventTime)
            
            // Check if we should flush
            if self.eventQueue.count >= config.batchSize {
                self.flush()
            }
        }
    }
    
    /// Track screen view
    public func trackScreenView(_ screenName: String, data: [String: Any] = [:]) {
        // Update current screen name
        setCurrentScreenName(screenName)
        
        var screenData = data
        screenData[TrackingConstants.APP_SCREEN_NAME_PROPERTY] = screenName
        track(eventType: TrackingConstants.SCREEN_VIEWED_EVENT, data: screenData)
    }
    
    /// Track button tap
    public func trackButtonTap(_ buttonTitle: String, data: [String: Any] = [:]) {
        elementInteractionTracker?.trackButtonInteraction(
            buttonTitle: buttonTitle,
            data: data
        )
    }
    
    /// Track deep link opened
    public func trackDeepLinkOpened(url: String, referrer: String? = nil) {
        deepLinkTracker?.trackDeepLinkOpened(url: url, referrer: referrer)
    }
    
    /// Track deep link opened with URL object
    public func trackDeepLinkOpened(url: URL, referrer: URL? = nil) {
        deepLinkTracker?.trackDeepLinkOpened(url: url, referrer: referrer)
    }
    
    /// Track element interaction
    public func trackElementInteraction(
        action: String,
        targetViewClass: String? = nil,
        targetText: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        hierarchy: [String]? = nil,
        data: [String: Any] = [:]
    ) {
        elementInteractionTracker?.trackElementInteraction(
            action: action,
            targetViewClass: targetViewClass,
            targetText: targetText,
            accessibilityLabel: accessibilityLabel,
            accessibilityIdentifier: accessibilityIdentifier,
            hierarchy: hierarchy,
            data: data
        )
    }
    
    /// Track text field interaction
    public func trackTextFieldInteraction(
        action: String,
        placeholder: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        elementInteractionTracker?.trackTextFieldInteraction(
            action: action,
            placeholder: placeholder,
            accessibilityLabel: accessibilityLabel,
            accessibilityIdentifier: accessibilityIdentifier,
            data: data
        )
    }
    
    /// Track list item interaction
    public func trackListItemInteraction(
        action: String,
        itemText: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        elementInteractionTracker?.trackListItemInteraction(
            action: action,
            itemText: itemText,
            accessibilityLabel: accessibilityLabel,
            accessibilityIdentifier: accessibilityIdentifier,
            data: data
        )
    }
    
    // MARK: - Network Tracking
    
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
        networkTrackingPlugin?.trackNetworkRequest(
            url: url,
            method: method,
            statusCode: statusCode,
            errorCode: errorCode,
            errorMessage: errorMessage,
            startTime: startTime,
            completionTime: completionTime,
            requestBodySize: requestBodySize,
            responseBodySize: responseBodySize,
            requestHeaders: requestHeaders,
            responseHeaders: responseHeaders,
            requestBody: requestBody,
            responseBody: responseBody
        )
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
        networkTrackingPlugin?.trackSuccessfulRequest(
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
        networkTrackingPlugin?.trackFailedRequest(
            url: url,
            method: method,
            errorCode: errorCode,
            errorMessage: errorMessage,
            startTime: startTime,
            completionTime: completionTime,
            requestBodySize: requestBodySize
        )
    }
    
    // MARK: - Frustration Interaction Tracking
    
    /// Track a click for rage click detection
    public func trackClick(x: Double, y: Double) {
        frustrationInteractionTracker?.trackClick(x: x, y: y)
    }
    
    /// Mark that a click resulted in a response (for dead click detection)
    public func markClickResponse() {
        frustrationInteractionTracker?.markClickResponse()
    }
    
    // MARK: - Gesture Tracking
    
    /// Track a tap gesture
    public func trackTapGesture(
        location: CGPoint,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        gestureTracker?.trackTapGesture(
            location: location,
            accessibilityLabel: accessibilityLabel,
            accessibilityIdentifier: accessibilityIdentifier,
            data: data
        )
    }
    
    /// Track a long press gesture
    public func trackLongPressGesture(
        location: CGPoint,
        duration: TimeInterval,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        gestureTracker?.trackLongPressGesture(
            location: location,
            duration: duration,
            accessibilityLabel: accessibilityLabel,
            accessibilityIdentifier: accessibilityIdentifier,
            data: data
        )
    }
    
    /// Track a drag gesture
    public func trackDragGesture(
        startLocation: CGPoint,
        endLocation: CGPoint,
        translation: CGSize,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        gestureTracker?.trackDragGesture(
            startLocation: startLocation,
            endLocation: endLocation,
            translation: translation,
            accessibilityLabel: accessibilityLabel,
            accessibilityIdentifier: accessibilityIdentifier,
            data: data
        )
    }
    
    /// Track a pinch gesture
    public func trackPinchGesture(
        location: CGPoint,
        scale: CGFloat,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        gestureTracker?.trackPinchGesture(
            location: location,
            scale: scale,
            accessibilityLabel: accessibilityLabel,
            accessibilityIdentifier: accessibilityIdentifier,
            data: data
        )
    }
    
    /// Track a rotation gesture
    public func trackRotationGesture(
        location: CGPoint,
        angle: Angle,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        gestureTracker?.trackRotationGesture(
            location: location,
            angle: angle,
            accessibilityLabel: accessibilityLabel,
            accessibilityIdentifier: accessibilityIdentifier,
            data: data
        )
    }
    
    /// Force flush events to server
    public func flush() {
        guard let config = config, !eventQueue.isEmpty else { return }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let eventsToSend = self.eventQueue
            self.eventQueue.removeAll()
            
            self.sendEvents(eventsToSend, config: config)
        }
    }
    
    // MARK: - Private Methods
    
    private func startNewSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, let config = self.config else { return }
            
            // End previous session if it exists
            if !self.sessionId.isEmpty && self.sessionId != "Unknown" {
                self.trackSessionEndEvent()
            }
            
            // Start new session
            self.sessionId = UUID().uuidString
            self.storage.setPreviousSessionId(self.sessionId)
            
            // Track session start event
            if config.enableAutoCapture {
                self.trackSessionStartEvent()
            }
        }
    }
    
    private func trackSessionStartEvent() {
        track(eventType: TrackingConstants.SESSION_START_EVENT, data: [:])
    }
    
    private func trackSessionEndEvent() {
        track(eventType: TrackingConstants.SESSION_END_EVENT, data: [:])
    }
    
    private func startFlushTimer() {
        guard let config = config else { return }
        
        flushTimer?.invalidate()
        flushTimer = Timer.scheduledTimer(withTimeInterval: config.flushIntervalSeconds, repeats: true) { [weak self] _ in
            self?.flush()
        }
    }
    
    private func setupLifecycleObservers() {
        #if canImport(UIKit)
        // App lifecycle notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        #endif
    }
    
    @objc private func appDidBecomeActive() {
        guard let config = config, config.enableAutoCapture else { return }
        
        // Check if we need a new session
        if shouldStartNewSession() {
            startNewSession()
        }
        
        trackApplicationOpenedEvent(fromBackground: true)
    }
    
    @objc private func appWillResignActive() {
        guard let config = config, config.enableAutoCapture else { return }
        flush() // Flush before going to background
    }
    
    @objc private func appDidEnterBackground() {
        guard let config = config, config.enableAutoCapture else { return }
        trackApplicationBackgroundedEvent()
    }
    
    @objc private func appWillEnterForeground() {
        guard let config = config, config.enableAutoCapture else { return }
        // This will be handled by appDidBecomeActive
    }
    
    private func trackAppLaunch() {
        trackApplicationOpenedEvent(fromBackground: false)
    }
    
    private func trackApplicationOpenedEvent(fromBackground: Bool) {
        let info = Bundle.main.infoDictionary
        let currentBuild = info?["CFBundleVersion"] as? String
        let currentVersion = info?["CFBundleShortVersionString"] as? String
        
        var eventData: [String: Any] = [:]
        eventData[TrackingConstants.APP_VERSION_PROPERTY] = currentVersion ?? ""
        eventData[TrackingConstants.APP_BUILD_PROPERTY] = currentBuild ?? ""
        eventData[TrackingConstants.APP_FROM_BACKGROUND_PROPERTY] = fromBackground
        
        track(eventType: TrackingConstants.APPLICATION_OPENED_EVENT, data: eventData)
    }
    
    private func trackApplicationBackgroundedEvent() {
        track(eventType: TrackingConstants.APPLICATION_BACKGROUNDED_EVENT, data: [:])
    }
    
    private func shouldStartNewSession() -> Bool {
        guard let config = config else { return false }
        let timeSinceLastEvent = Date().timeIntervalSince(lastEventTime)
        return timeSinceLastEvent > config.sessionTimeoutSeconds
    }
    
    private var currentScreenName: String = "Unknown"
    
    private func getCurrentPageUrl() -> String {
        // Return empty string as requested - no URL for SwiftUI apps
        return ""
    }
    
    private func getCurrentPageTitle() -> String {
        // Return the current screen name as the page title
        return currentScreenName
    }
    
    /// Update the current screen name for tracking
    public func setCurrentScreenName(_ screenName: String) {
        currentScreenName = screenName
    }
    
    private func sendEvents(_ events: [TrackingEvent], config: TrackingConfig) {
        let payload = TrackingPayload(
            productId: config.productId,
            sessionId: sessionId,
            anonymousId: anonymousId,
            userId: config.userId,
            pageUrl: getCurrentPageUrl(),
            events: events,
            deviceInfo: deviceInfo.toDictionary()
        )
        
        guard let url = URL(string: config.trackingEndpoint) else {
            print("SwiftTracking: Invalid tracking endpoint URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(payload)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    print("SwiftTracking: Failed to send events: \(error.localizedDescription)")
                    // Re-queue events on failure
                    self?.queue.async { [weak self] in
                        self?.eventQueue.insert(contentsOf: events, at: 0)
                    }
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                        print("SwiftTracking: Successfully sent \(events.count) events")
                    } else {
                        print("SwiftTracking: Server error: \(httpResponse.statusCode)")
                        // Re-queue events on server error
                        self?.queue.async { [weak self] in
                            self?.eventQueue.insert(contentsOf: events, at: 0)
                        }
                    }
                }
            }.resume()
            
        } catch {
            print("SwiftTracking: Failed to encode payload: \(error.localizedDescription)")
            // Re-queue events on encoding error
            queue.async { [weak self] in
                self?.eventQueue.insert(contentsOf: events, at: 0)
            }
        }
    }
    
    deinit {
        flushTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - SwiftUI Integration

