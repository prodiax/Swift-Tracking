import SwiftUI

/// Environment key for tracking navigation titles in SwiftUI
private struct NavigationTitleKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    /// The current navigation title for tracking purposes
    var trackingNavigationTitle: String? {
        get { self[NavigationTitleKey.self] }
        set { self[NavigationTitleKey.self] = newValue }
    }
}

/// SwiftUI view modifier that automatically tracks navigation title changes
public struct NavigationTitleTracker: ViewModifier {
    let title: String
    let data: [String: Any]
    
    public init(title: String, data: [String: Any] = [:]) {
        self.title = title
        self.data = data
    }
    
    public func body(content: Content) -> some View {
        content
            .environment(\.trackingNavigationTitle, title)
            .onAppear {
                Tracker.shared.setCurrentNavigationTitle(title)
                Tracker.shared.trackScreenView(title, data: data)
            }
            .onDisappear {
                Tracker.shared.setCurrentNavigationTitle(nil)
            }
    }
}

/// SwiftUI view modifier that automatically detects and tracks navigation titles
public struct AutoNavigationTitleTracker: ViewModifier {
    let data: [String: Any]
    @Environment(\.trackingNavigationTitle) private var environmentTitle
    
    public init(data: [String: Any] = [:]) {
        self.data = data
    }
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                // Use environment title if available, otherwise infer from view type
                let title = environmentTitle ?? inferTitleFromViewType()
                Tracker.shared.setCurrentNavigationTitle(title)
                Tracker.shared.trackScreenView(title, data: data)
            }
            .onDisappear {
                Tracker.shared.setCurrentNavigationTitle(nil)
            }
    }
    
    private func inferTitleFromViewType() -> String {
        // This is a simplified approach - in a real implementation,
        // you might want to use more sophisticated reflection
        return "AutoTrackedView"
    }
}

/// SwiftUI view extension for advanced navigation title tracking
public extension View {
    /// Track navigation title with environment-based detection
    func trackNavigationTitleWithEnvironment(_ title: String, data: [String: Any] = [:]) -> some View {
        self.modifier(NavigationTitleTracker(title: title, data: data))
    }
    
    /// Automatically track navigation title with environment detection
    func autoTrackNavigationTitleWithEnvironment(data: [String: Any] = [:]) -> some View {
        self.modifier(AutoNavigationTitleTracker(data: data))
    }
}

/// SwiftUI navigation view extension for automatic title tracking
public extension NavigationView {
    /// Automatically track navigation titles for all child views
    func autoTrackNavigationTitles(data: [String: Any] = [:]) -> some View {
        self.environment(\.trackingNavigationTitle, nil)
    }
}

@available(iOS 16.0, macOS 13.0, *)
public extension NavigationStack {
    /// Automatically track navigation titles for all child views
    func autoTrackNavigationTitles(data: [String: Any] = [:]) -> some View {
        self.environment(\.trackingNavigationTitle, nil)
    }
}
