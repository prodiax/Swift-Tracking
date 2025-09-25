import SwiftUI

/// SwiftUI view modifiers for easy tracking integration
public extension View {
    
    /// Track screen views automatically
    func trackScreenView(_ screenName: String, data: [String: Any] = [:]) -> some View {
        self.onAppear {
            Tracker.shared.trackScreenView(screenName, data: data)
        }
    }
    
    /// Automatically infer a screen name from the view type and track on appear
    func autoTrackScreen(data: [String: Any] = [:]) -> some View {
        let inferred = String(describing: type(of: self))
        return self.onAppear {
            Tracker.shared.trackScreenView(inferred, data: data)
        }
    }
    
    /// Track button taps
    func trackButtonTap(_ buttonTitle: String, data: [String: Any] = [:]) -> some View {
        self.onTapGesture {
            Tracker.shared.trackButtonTap(buttonTitle, data: data)
        }
    }
    
    /// Track element interactions with custom action
    func trackElementInteraction(
        action: String,
        targetViewClass: String? = nil,
        targetText: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        hierarchy: [String]? = nil,
        data: [String: Any] = [:]
    ) -> some View {
        self.onTapGesture {
            Tracker.shared.trackElementInteraction(
                action: action,
                targetViewClass: targetViewClass,
                targetText: targetText,
                accessibilityLabel: accessibilityLabel,
                accessibilityIdentifier: accessibilityIdentifier,
                hierarchy: hierarchy,
                data: data
            )
        }
    }
    
    /// Track tap gestures with location
    func trackTapGesture(
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) -> some View {
        self.gesture(
            TapGesture()
                .onEnded { value in
                    Tracker.shared.trackTapGesture(
                        location: CGPoint(x: 0, y: 0), // SwiftUI doesn't provide tap location easily
                        accessibilityLabel: accessibilityLabel,
                        accessibilityIdentifier: accessibilityIdentifier,
                        data: data
                    )
                }
        )
    }
    
    /// Track long press gestures
    func trackLongPressGesture(
        minimumDuration: Double = 0.5,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) -> some View {
        self.gesture(
            LongPressGesture(minimumDuration: minimumDuration)
                .onEnded { value in
                    Tracker.shared.trackLongPressGesture(
                        location: CGPoint(x: 0, y: 0),
                        duration: minimumDuration,
                        accessibilityLabel: accessibilityLabel,
                        accessibilityIdentifier: accessibilityIdentifier,
                        data: data
                    )
                }
        )
    }
    
    /// Track drag gestures
    func trackDragGesture(
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) -> some View {
        self.gesture(
            DragGesture()
                .onEnded { value in
                    Tracker.shared.trackDragGesture(
                        startLocation: value.startLocation,
                        endLocation: value.location,
                        translation: value.translation,
                        accessibilityLabel: accessibilityLabel,
                        accessibilityIdentifier: accessibilityIdentifier,
                        data: data
                    )
                }
        )
    }
    
    /// Track magnification (pinch) gestures
    func trackMagnificationGesture(
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) -> some View {
        self.gesture(
            MagnificationGesture()
                .onEnded { value in
                    Tracker.shared.trackPinchGesture(
                        location: CGPoint(x: 0, y: 0),
                        scale: value,
                        accessibilityLabel: accessibilityLabel,
                        accessibilityIdentifier: accessibilityIdentifier,
                        data: data
                    )
                }
        )
    }
    
    /// Track rotation gestures
    func trackRotationGesture(
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) -> some View {
        self.gesture(
            RotationGesture()
                .onEnded { value in
                    Tracker.shared.trackRotationGesture(
                        location: CGPoint(x: 0, y: 0),
                        angle: value,
                        accessibilityLabel: accessibilityLabel,
                        accessibilityIdentifier: accessibilityIdentifier,
                        data: data
                    )
                }
        )
    }
    
    /// Track clicks for frustration interaction detection
    func trackClicks() -> some View {
        self.onTapGesture {
            // SwiftUI doesn't provide tap coordinates easily, so we use a default location
            Tracker.shared.trackClick(x: 0, y: 0)
        }
    }
    
    /// Mark click responses for dead click detection
    func markClickResponse() -> some View {
        self.onTapGesture {
            Tracker.shared.markClickResponse()
        }
    }
}

/// Custom button that automatically tracks taps
public struct TrackingButton<Label: View>: View {
    private let action: () -> Void
    private let label: () -> Label
    private let buttonTitle: String
    private let data: [String: Any]
    
    public init(
        _ buttonTitle: String,
        data: [String: Any] = [:],
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.buttonTitle = buttonTitle
        self.data = data
        self.action = action
        self.label = label
    }
    
    public var body: some View {
        Button(action: {
            Tracker.shared.trackButtonTap(buttonTitle, data: data)
            action()
        }) {
            label()
        }
    }
}

/// Custom text field that tracks interactions
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public struct TrackingTextField: View {
    @Binding private var text: String
    private let placeholder: String
    private let accessibilityLabel: String?
    private let accessibilityIdentifier: String?
    private let data: [String: Any]
    
    public init(
        _ placeholder: String,
        text: Binding<String>,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        data: [String: Any] = [:]
    ) {
        self.placeholder = placeholder
        self._text = text
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityIdentifier = accessibilityIdentifier
        self.data = data
    }
    
    public var body: some View {
        TextField(placeholder, text: $text)
            .onTapGesture {
                Tracker.shared.trackTextFieldInteraction(
                    action: "tap",
                    placeholder: placeholder,
                    accessibilityLabel: accessibilityLabel,
                    accessibilityIdentifier: accessibilityIdentifier,
                    data: data
                )
            }
            .onChange(of: text) { _ in
                Tracker.shared.trackTextFieldInteraction(
                    action: "text_changed",
                    placeholder: placeholder,
                    accessibilityLabel: accessibilityLabel,
                    accessibilityIdentifier: accessibilityIdentifier,
                    data: data
                )
            }
    }
}
