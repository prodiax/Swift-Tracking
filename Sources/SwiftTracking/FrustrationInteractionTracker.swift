import Foundation

/// Tracker for frustration interactions (rage clicks and dead clicks)
public class FrustrationInteractionTracker {
    private weak var tracker: Tracker?
    private var isEnabled: Bool = false
    
    // Rage click detection
    private var clickHistory: [(time: Date, x: Double, y: Double)] = []
    private let rageClickThreshold = 3 // Number of clicks
    private let rageClickTimeWindow: TimeInterval = 1.0 // 1 second
    private let rageClickDistanceThreshold: Double = 50.0 // 50 points
    
    // Dead click detection
    private var deadClickStartTime: Date?
    private var deadClickTimeout: TimeInterval = 2.0 // 2 seconds
    private var deadClickHistory: [Date] = []
    
    public init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /// Enable or disable frustration interaction tracking
    public func setEnabled(_ enabled: Bool) {
        self.isEnabled = enabled
    }
    
    /// Update dead click timeout from config
    public func updateDeadClickTimeout(_ timeout: TimeInterval) {
        self.deadClickTimeout = timeout
    }
    
    /// Track a click for rage click detection
    public func trackClick(x: Double, y: Double) {
        guard isEnabled else { return }
        
        // Validate coordinates to prevent NaN values
        let validX = x.isFinite ? x : 0.0
        let validY = y.isFinite ? y : 0.0
        
        let now = Date()
        
        // Add to click history
        clickHistory.append((time: now, x: validX, y: validY))
        
        // Clean old clicks
        clickHistory = clickHistory.filter { now.timeIntervalSince($0.time) <= rageClickTimeWindow }
        
        // Check for rage click
        if clickHistory.count >= rageClickThreshold {
            if isRageClick() {
                trackRageClick()
                clickHistory.removeAll() // Clear history after detecting rage click
            }
        }
        
        // Start dead click detection
        startDeadClickDetection()
    }
    
    /// Mark that a click resulted in a response (for dead click detection)
    public func markClickResponse() {
        deadClickStartTime = nil
    }
    
    private func isRageClick() -> Bool {
        guard clickHistory.count >= rageClickThreshold else { return false }
        
        // Check if all clicks are within the distance threshold
        let firstClick = clickHistory[0]
        for click in clickHistory {
            let distance = sqrt(pow(click.x - firstClick.x, 2) + pow(click.y - firstClick.y, 2))
            if distance > rageClickDistanceThreshold {
                return false
            }
        }
        
        return true
    }
    
    private func trackRageClick() {
        guard let firstClick = clickHistory.first,
              let lastClick = clickHistory.last else { return }
        
        let beginTime = firstClick.time
        let endTime = lastClick.time
        let duration = endTime.timeIntervalSince(beginTime)
        
        var eventData: [String: Any] = [:]
        eventData[TrackingConstants.BEGIN_TIME_PROPERTY] = beginTime.timeIntervalSince1970
        eventData[TrackingConstants.END_TIME_PROPERTY] = endTime.timeIntervalSince1970
        eventData[TrackingConstants.DURATION_PROPERTY] = duration
        eventData[TrackingConstants.CLICK_COUNT_PROPERTY] = clickHistory.count
        eventData[TrackingConstants.CLICKS_PROPERTY] = clickHistory.map { click in
            [
                TrackingConstants.COORDINATE_X_PROPERTY: click.x,
                TrackingConstants.COORDINATE_Y_PROPERTY: click.y
            ]
        }
        
        tracker?.track(eventType: TrackingConstants.RAGE_CLICK_EVENT, data: eventData)
    }
    
    private func startDeadClickDetection() {
        deadClickStartTime = Date()
        
        // Schedule dead click check
        DispatchQueue.main.asyncAfter(deadline: .now() + deadClickTimeout) { [weak self] in
            self?.checkForDeadClick()
        }
    }
    
    private func checkForDeadClick() {
        guard let startTime = deadClickStartTime else { return }
        
        // Check if we should track this dead click (rate limiting)
        guard shouldTrackDeadClick() else {
            deadClickStartTime = nil
            return
        }
        
        // If we still have a start time, it means no response was detected
        let duration = Date().timeIntervalSince(startTime)
        
        var eventData: [String: Any] = [:]
        eventData[TrackingConstants.BEGIN_TIME_PROPERTY] = startTime.timeIntervalSince1970
        eventData[TrackingConstants.END_TIME_PROPERTY] = Date().timeIntervalSince1970
        eventData[TrackingConstants.DURATION_PROPERTY] = duration
        
        tracker?.track(eventType: TrackingConstants.DEAD_CLICK_EVENT, data: eventData)
        
        // Add to dead click history for rate limiting
        deadClickHistory.append(Date())
        cleanDeadClickHistory()
        
        deadClickStartTime = nil
    }
    
    private func shouldTrackDeadClick() -> Bool {
        guard let config = tracker?.configForPlugins() else { return true }
        
        // Check rate limiting
        let now = Date()
        let recentDeadClicks = deadClickHistory.filter { 
            now.timeIntervalSince($0) < 60 // Last minute
        }
        
        return recentDeadClicks.count < config.maxDeadClicksPerMinute
    }
    
    private func cleanDeadClickHistory() {
        let now = Date()
        deadClickHistory = deadClickHistory.filter { 
            now.timeIntervalSince($0) < 300 // Keep last 5 minutes
        }
    }
}
