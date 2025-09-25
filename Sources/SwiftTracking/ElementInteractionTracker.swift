import Foundation
import SwiftUI

/// Utility class for tracking element interactions in SwiftUI
public class ElementInteractionTracker {
    private weak var tracker: Tracker?
    
    public init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /// Track an element interaction
    public func trackElementInteraction(
        action: String,
        targetViewClass: String? = nil,
        targetText: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        hierarchy: [String]? = nil,
        data: [String: Any] = [:]
    ) {
        var eventData = data
        eventData[TrackingConstants.APP_ACTION_PROPERTY] = action
        
        if let targetViewClass = targetViewClass {
            eventData[TrackingConstants.APP_TARGET_VIEW_CLASS_PROPERTY] = targetViewClass
        }
        
        if let targetText = targetText {
            eventData[TrackingConstants.APP_TARGET_TEXT_PROPERTY] = targetText
        }
        
        if let accessibilityLabel = accessibilityLabel {
            eventData[TrackingConstants.APP_TARGET_AXLABEL_PROPERTY] = accessibilityLabel
        }
        
        if let accessibilityIdentifier = accessibilityIdentifier {
            eventData[TrackingConstants.APP_TARGET_AXIDENTIFIER_PROPERTY] = accessibilityIdentifier
        }
        
        if let hierarchy = hierarchy {
            eventData[TrackingConstants.APP_HIERARCHY_PROPERTY] = hierarchy
        }
        
        let sanitized = DataSanitizer.sanitizeElementEventData(eventData)
        tracker?.track(eventType: TrackingConstants.ELEMENT_INTERACTED_EVENT, data: sanitized)
    }
    
    /// Track a button interaction
    public func trackButtonInteraction(
        buttonTitle: String,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        trackElementInteraction(
            action: "tap",
            targetViewClass: "Button",
            targetText: buttonTitle,
            accessibilityLabel: accessibilityLabel,
            accessibilityIdentifier: accessibilityIdentifier,
            data: data
        )
    }
    
    /// Track a text field interaction
    public func trackTextFieldInteraction(
        action: String,
        placeholder: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        trackElementInteraction(
            action: action,
            targetViewClass: "TextField",
            targetText: placeholder,
            accessibilityLabel: accessibilityLabel,
            accessibilityIdentifier: accessibilityIdentifier,
            data: data
        )
    }
    
    /// Track a list item interaction
    public func trackListItemInteraction(
        action: String,
        itemText: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        trackElementInteraction(
            action: action,
            targetViewClass: "ListItem",
            targetText: itemText,
            accessibilityLabel: accessibilityLabel,
            accessibilityIdentifier: accessibilityIdentifier,
            data: data
        )
    }
}
