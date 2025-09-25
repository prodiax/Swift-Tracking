import Foundation

#if canImport(UIKit)
import UIKit
import ObjectiveC.runtime

#if canImport(SwiftUI)
import SwiftUI
#endif

/// Manager responsible for enabling UIKit-level auto capture via method swizzling
final class AutoCaptureManager {
    static let shared = AutoCaptureManager()
    private var isEnabled: Bool = false

    private init() {}

    func enable() {
        guard !isEnabled else { return }
        isEnabled = true

        UIViewController.enableTrackingSwizzle()
        UIApplication.enableSendActionSwizzle()
        UIWindow.enableSendEventSwizzle()
    }

    // MARK: - Event Builders

    func handleViewDidAppear(viewController: UIViewController) {
        let rawName = String(describing: type(of: viewController))
        
        // Filter out system UI controllers
        guard !Self.isSystemUIController(rawName) else {
            return // Don't track system UI screens
        }
        
        // Try to extract navigation title from the navigation context
        let navigationTitle = Self.extractNavigationTitle(from: viewController)
        
        // Try to get a meaningful screen name
        let screenName = navigationTitle
            ?? Self.extractSwiftUIViewNameIfHostingController(from: rawName)
            ?? viewController.title
            ?? Self.generateFallbackScreenName(from: rawName)

        // Only track if we have a meaningful screen name
        guard Self.isMeaningfulScreenName(screenName) else {
            return // Skip generic or system names
        }

        // Set both screen name and navigation title
        Tracker.shared.setCurrentScreenName(screenName)
        if let navTitle = navigationTitle {
            Tracker.shared.setCurrentNavigationTitle(navTitle)
        }
        Tracker.shared.trackScreenView(screenName)
    }

    func handleControlAction(control: UIControl, action: Selector, target: Any?) {
        var eventData: [String: Any] = [:]
        eventData[TrackingConstants.APP_ACTION_PROPERTY] = "tap"
        eventData[TrackingConstants.APP_ACTION_METHOD_PROPERTY] = NSStringFromSelector(action)
        eventData[TrackingConstants.APP_TARGET_VIEW_CLASS_PROPERTY] = String(describing: type(of: control))

        if let button = control as? UIButton {
            let title = button.currentTitle ?? button.titleLabel?.text
            if let title = title, !title.isEmpty {
                eventData[TrackingConstants.APP_TARGET_TEXT_PROPERTY] = title
            }
        }

        // Avoid capturing free-form text content
        if control is UITextField || control is UITextView {
            eventData.removeValue(forKey: TrackingConstants.APP_TARGET_TEXT_PROPERTY)
        }

        if let label = control.accessibilityLabel, !label.isEmpty {
            eventData[TrackingConstants.APP_TARGET_AXLABEL_PROPERTY] = label
        }
        if let identifier = control.accessibilityIdentifier, !identifier.isEmpty {
            eventData[TrackingConstants.APP_TARGET_AXIDENTIFIER_PROPERTY] = identifier
        }

        if let hierarchy = Self.buildHierarchy(from: control) {
            eventData[TrackingConstants.APP_HIERARCHY_PROPERTY] = hierarchy
        }

        let sanitized = DataSanitizer.sanitizeElementEventData(eventData)
        Tracker.shared.track(eventType: TrackingConstants.ELEMENT_INTERACTED_EVENT, data: sanitized)
        // A control produced a response, mark dead click as resolved
        Tracker.shared.markClickResponse()
    }

    // MARK: - Helpers

    private static func buildHierarchy(from view: UIView) -> [String]? {
        var names: [String] = []
        var current: UIResponder? = view
        var safety = 0
        while let responder = current, safety < 64 {
            safety += 1
            if let view = responder as? UIView {
                names.append(String(describing: type(of: view)))
                current = view.next
            } else if let viewController = responder as? UIViewController {
                names.append(String(describing: type(of: viewController)))
                current = viewController.parent
            } else {
                current = responder.next
            }
        }
        return names.isEmpty ? nil : names
    }

    /// Extract navigation title from the view controller's navigation context
    private static func extractNavigationTitle(from viewController: UIViewController) -> String? {
        // First, try to get the title from the view controller itself
        if let title = viewController.title, !title.isEmpty && isMeaningfulScreenName(title) {
            return title
        }
        
        // Try to get title from navigation item
        let navItem = viewController.navigationItem
        if let title = navItem.title, !title.isEmpty && isMeaningfulScreenName(title) {
            return title
        }
        
        // For SwiftUI hosting controllers, try to extract from the navigation context
        #if canImport(SwiftUI)
        if let hostingController = viewController as? UIHostingController<AnyView> {
            return extractSwiftUINavigationTitle(from: hostingController)
        }
        #endif
        
        // Try to get title from parent navigation controller's top view controller
        if let navController = viewController.navigationController,
           let topVC = navController.topViewController,
           topVC == viewController,
           let title = topVC.title, !title.isEmpty && isMeaningfulScreenName(title) {
            return title
        }
        
        return nil
    }
    
    /// Extract navigation title from SwiftUI hosting controller
    #if canImport(SwiftUI)
    private static func extractSwiftUINavigationTitle(from hostingController: UIHostingController<AnyView>) -> String? {
        // This is a more advanced approach that would require runtime inspection
        // For now, we'll rely on the view controller's title property
        // which should be set by SwiftUI's navigationTitle modifier
        return hostingController.title
    }
    #endif
    
    /// If the view controller is a UIHostingController<Content>, extract "Content"
    private static func extractSwiftUIViewNameIfHostingController(from vcTypeName: String) -> String? {
        // Matches patterns like "UIHostingController<ContentView>" or "UIHostingController<NavigationStack<ContentView>>"
        guard let startRange = vcTypeName.firstIndex(of: "<"), let endRange = vcTypeName.lastIndex(of: ">"), startRange < endRange else {
            return nil
        }
        
        let generic = String(vcTypeName[vcTypeName.index(after: startRange)..<endRange])
        
        // Handle complex nested generics like "ModifiedContent<AnyView, RootModifier>"
        let cleaned = cleanSwiftUIGenericType(generic)
        
        // Take the last component if nested generics (e.g., NavigationStack<ContentView>)
        let components = cleaned.split(separator: ",").first?.split(separator: ">").last?.split(separator: "<")
        let flattened = components?.last ?? Substring(cleaned)
        
        // If it still contains nested generics, keep the last type token
        let tokens = flattened.split(separator: ".")
        let result = String(tokens.last ?? flattened)
        
        // Only return if it's a meaningful name
        return isMeaningfulScreenName(result) ? result : nil
    }
    
    /// Clean SwiftUI generic type names to extract meaningful view names
    private static func cleanSwiftUIGenericType(_ typeName: String) -> String {
        var cleaned = typeName
        
        // Remove common SwiftUI wrapper types
        let wrappersToRemove = [
            "ModifiedContent<", "TupleView<", "Group<", "VStack<", "HStack<", "ZStack<",
            "NavigationStack<", "NavigationView<", "TabView<", "Optional<", "AnyView"
        ]
        
        for wrapper in wrappersToRemove {
            cleaned = cleaned.replacingOccurrences(of: wrapper, with: "")
        }
        
        // Remove trailing angle brackets and commas
        cleaned = cleaned.replacingOccurrences(of: ">", with: "")
        cleaned = cleaned.replacingOccurrences(of: ",", with: "")
        
        return cleaned.trimmingCharacters(in: .whitespaces)
    }
    
    /// Generate a fallback screen name when we can't extract a meaningful one
    private static func generateFallbackScreenName(from vcTypeName: String) -> String {
        // For SwiftUI hosting controllers, try to extract the view name
        if vcTypeName.contains("UIHostingController") {
            if let extracted = extractSwiftUIViewNameIfHostingController(from: vcTypeName) {
                return extracted
            }
            return "SwiftUIView"
        }
        
        // For other view controllers, try to clean the name
        let cleaned = vcTypeName
            .replacingOccurrences(of: "ViewController", with: "")
            .replacingOccurrences(of: "Controller", with: "")
            .replacingOccurrences(of: "UI", with: "")
        
        return cleaned.isEmpty ? "UnknownScreen" : cleaned
    }
    
    /// Check if a view controller is a system UI component that should be filtered out
    private static func isSystemUIController(_ controllerName: String) -> Bool {
        let systemControllers = [
            "UISystemKeyboardDockController",
            "UIKeyboardLayoutStar",
            "UIInputWindowController",
            "UINavigationController",
            "UITabBarController",
            "UISplitViewController",
            "UIPageViewController",
            "UIAlertController",
            "UIActivityViewController",
            "UISearchController",
            "UIReferenceLibraryViewController",
            "UIWebViewController",
            "SFSafariViewController",
            "MFMailComposeViewController",
            "MFMessageComposeViewController",
            "UIImagePickerController",
            "UIVideoEditorController",
            "UIPrintInteractionController",
            "UIPopoverController",
            "UIPopoverPresentationController"
        ]
        
        return systemControllers.contains(controllerName)
    }
    
    /// Check if a screen name is meaningful and should be tracked
    private static func isMeaningfulScreenName(_ screenName: String) -> Bool {
        // Skip very short names
        guard screenName.count >= 3 else { return false }
        
        // Skip names that are too generic or system-related
        let genericNames = [
            "Element", "View", "Controller", "VC", "ViewController",
            "UI", "System", "Keyboard", "Dock", "Layout", "Window",
            "Container", "Wrapper", "Host", "Root", "Main", "Base",
            "StyleContext", "NoStyleContext", "SidebarStyleContext",
            "NotifyingMulticolumnSplitViewController", "SplitViewController",
            "NavigationController", "TabBarController", "PageViewController",
            "AlertController", "ActivityViewController", "SearchController"
        ]
        
        // Check if the name contains generic terms
        for genericName in genericNames {
            if screenName.contains(genericName) {
                return false
            }
        }
        
        // Skip names that start with UI (system components)
        if screenName.hasPrefix("UI") && !screenName.contains("User") {
            return false
        }
        
        // Skip names that start with underscore (private/internal classes)
        if screenName.hasPrefix("_") {
            return false
        }
        
        // Skip names that are just numbers or special characters
        let alphanumericCount = screenName.filter { $0.isLetter || $0.isNumber }.count
        if alphanumericCount < 3 {
            return false
        }
        
        // Skip names that look like SwiftUI internal types
        if screenName.contains("ModifiedContent") || 
           screenName.contains("TupleView") ||
           screenName.contains("Group") ||
           screenName.contains("NavigationStack") ||
           screenName.contains("NavigationView") {
            return false
        }
        
        return true
    }
}

// MARK: - UIViewController Swizzle

private extension UIViewController {
    static func enableTrackingSwizzle() {
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController.st_viewDidAppear(_:))

        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    @objc func st_viewDidAppear(_ animated: Bool) {
        // Call original implementation (which is now st_viewDidAppear after swizzle)
        st_viewDidAppear(animated)
        AutoCaptureManager.shared.handleViewDidAppear(viewController: self)
    }
}

// MARK: - UIApplication sendAction Swizzle

private extension UIApplication {
    static func enableSendActionSwizzle() {
        let originalSelector = #selector(UIApplication.sendAction(_:to:from:for:))
        let swizzledSelector = #selector(UIApplication.st_sendAction(_:to:from:for:))

        guard let originalMethod = class_getInstanceMethod(UIApplication.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIApplication.self, swizzledSelector) else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    @objc func st_sendAction(_ action: Selector, to target: Any?, from sender: Any?, for event: UIEvent?) -> Bool {
        if let control = sender as? UIControl {
            AutoCaptureManager.shared.handleControlAction(control: control, action: action, target: target)
        }
        return st_sendAction(action, to: target, from: sender, for: event)
    }
}

// MARK: - UIWindow sendEvent Swizzle (tap interception for rage click detection)

private extension UIWindow {
    static func enableSendEventSwizzle() {
        let originalSelector = #selector(UIWindow.sendEvent(_:))
        let swizzledSelector = #selector(UIWindow.st_sendEvent(_:))

        guard let originalMethod = class_getInstanceMethod(UIWindow.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIWindow.self, swizzledSelector) else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    @objc func st_sendEvent(_ event: UIEvent) {
        // Intercept touch end events to feed frustration tracker
        if event.type == .touches, let touches = event.allTouches {
            for touch in touches where touch.phase == .ended {
                let point = touch.location(in: self)
                Tracker.shared.trackClick(x: Double(point.x), y: Double(point.y))
            }
        }
        st_sendEvent(event)
    }
}

#endif


