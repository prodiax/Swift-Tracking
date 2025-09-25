import Foundation
import SwiftUI

/// Tracker for SwiftUI gestures and interactions
public class GestureTracker {
    private weak var tracker: Tracker?
    private var isEnabled: Bool = false
    
    public init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /// Enable or disable gesture tracking
    public func setEnabled(_ enabled: Bool) {
        self.isEnabled = enabled
    }
    
    /// Track a tap gesture
    public func trackTapGesture(
        location: CGPoint,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        guard isEnabled else { return }
        
        var eventData = data
        eventData[TrackingConstants.APP_ACTION_PROPERTY] = "tap"
        eventData[TrackingConstants.APP_GESTURE_RECOGNIZER_PROPERTY] = "TapGesture"
        eventData[TrackingConstants.COORDINATE_X_PROPERTY] = location.x
        eventData[TrackingConstants.COORDINATE_Y_PROPERTY] = location.y
        
        if let accessibilityLabel = accessibilityLabel {
            eventData[TrackingConstants.APP_TARGET_AXLABEL_PROPERTY] = accessibilityLabel
        }
        
        if let accessibilityIdentifier = accessibilityIdentifier {
            eventData[TrackingConstants.APP_TARGET_AXIDENTIFIER_PROPERTY] = accessibilityIdentifier
        }
        
        tracker?.track(eventType: TrackingConstants.ELEMENT_INTERACTED_EVENT, data: eventData)
    }
    
    /// Track a long press gesture
    public func trackLongPressGesture(
        location: CGPoint,
        duration: TimeInterval,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        guard isEnabled else { return }
        
        var eventData = data
        eventData[TrackingConstants.APP_ACTION_PROPERTY] = "long_press"
        eventData[TrackingConstants.APP_GESTURE_RECOGNIZER_PROPERTY] = "LongPressGesture"
        eventData[TrackingConstants.COORDINATE_X_PROPERTY] = location.x
        eventData[TrackingConstants.COORDINATE_Y_PROPERTY] = location.y
        eventData[TrackingConstants.DURATION_PROPERTY] = duration
        
        if let accessibilityLabel = accessibilityLabel {
            eventData[TrackingConstants.APP_TARGET_AXLABEL_PROPERTY] = accessibilityLabel
        }
        
        if let accessibilityIdentifier = accessibilityIdentifier {
            eventData[TrackingConstants.APP_TARGET_AXIDENTIFIER_PROPERTY] = accessibilityIdentifier
        }
        
        tracker?.track(eventType: TrackingConstants.ELEMENT_INTERACTED_EVENT, data: eventData)
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
        guard isEnabled else { return }
        
        var eventData = data
        eventData[TrackingConstants.APP_ACTION_PROPERTY] = "drag"
        eventData[TrackingConstants.APP_GESTURE_RECOGNIZER_PROPERTY] = "DragGesture"
        eventData["start_x"] = startLocation.x
        eventData["start_y"] = startLocation.y
        eventData["end_x"] = endLocation.x
        eventData["end_y"] = endLocation.y
        eventData["translation_x"] = translation.width
        eventData["translation_y"] = translation.height
        
        if let accessibilityLabel = accessibilityLabel {
            eventData[TrackingConstants.APP_TARGET_AXLABEL_PROPERTY] = accessibilityLabel
        }
        
        if let accessibilityIdentifier = accessibilityIdentifier {
            eventData[TrackingConstants.APP_TARGET_AXIDENTIFIER_PROPERTY] = accessibilityIdentifier
        }
        
        tracker?.track(eventType: TrackingConstants.ELEMENT_INTERACTED_EVENT, data: eventData)
    }
    
    /// Track a pinch gesture
    public func trackPinchGesture(
        location: CGPoint,
        scale: CGFloat,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        guard isEnabled else { return }
        
        var eventData = data
        eventData[TrackingConstants.APP_ACTION_PROPERTY] = "pinch"
        eventData[TrackingConstants.APP_GESTURE_RECOGNIZER_PROPERTY] = "MagnificationGesture"
        eventData[TrackingConstants.COORDINATE_X_PROPERTY] = location.x
        eventData[TrackingConstants.COORDINATE_Y_PROPERTY] = location.y
        eventData["scale"] = scale
        
        if let accessibilityLabel = accessibilityLabel {
            eventData[TrackingConstants.APP_TARGET_AXLABEL_PROPERTY] = accessibilityLabel
        }
        
        if let accessibilityIdentifier = accessibilityIdentifier {
            eventData[TrackingConstants.APP_TARGET_AXIDENTIFIER_PROPERTY] = accessibilityIdentifier
        }
        
        tracker?.track(eventType: TrackingConstants.ELEMENT_INTERACTED_EVENT, data: eventData)
    }
    
    /// Track a rotation gesture
    public func trackRotationGesture(
        location: CGPoint,
        angle: Angle,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        guard isEnabled else { return }
        
        var eventData = data
        eventData[TrackingConstants.APP_ACTION_PROPERTY] = "rotation"
        eventData[TrackingConstants.APP_GESTURE_RECOGNIZER_PROPERTY] = "RotationGesture"
        eventData[TrackingConstants.COORDINATE_X_PROPERTY] = location.x
        eventData[TrackingConstants.COORDINATE_Y_PROPERTY] = location.y
        eventData["angle_degrees"] = angle.degrees
        eventData["angle_radians"] = angle.radians
        
        if let accessibilityLabel = accessibilityLabel {
            eventData[TrackingConstants.APP_TARGET_AXLABEL_PROPERTY] = accessibilityLabel
        }
        
        if let accessibilityIdentifier = accessibilityIdentifier {
            eventData[TrackingConstants.APP_TARGET_AXIDENTIFIER_PROPERTY] = accessibilityIdentifier
        }
        
        tracker?.track(eventType: TrackingConstants.ELEMENT_INTERACTED_EVENT, data: eventData)
    }
}
