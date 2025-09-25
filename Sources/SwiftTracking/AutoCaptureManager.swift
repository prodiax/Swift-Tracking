import Foundation

#if canImport(UIKit)
import UIKit
import ObjectiveC.runtime

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
    }

    // MARK: - Event Builders

    func handleViewDidAppear(viewController: UIViewController) {
        let rawName = String(describing: type(of: viewController))
        let screenName = Self.extractSwiftUIViewNameIfHostingController(from: rawName)
            ?? viewController.title
            ?? rawName

        Tracker.shared.setCurrentScreenName(screenName)
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

        if let label = control.accessibilityLabel, !label.isEmpty {
            eventData[TrackingConstants.APP_TARGET_AXLABEL_PROPERTY] = label
        }
        if let identifier = control.accessibilityIdentifier, !identifier.isEmpty {
            eventData[TrackingConstants.APP_TARGET_AXIDENTIFIER_PROPERTY] = identifier
        }

        if let hierarchy = Self.buildHierarchy(from: control) {
            eventData[TrackingConstants.APP_HIERARCHY_PROPERTY] = hierarchy
        }

        Tracker.shared.track(eventType: TrackingConstants.ELEMENT_INTERACTED_EVENT, data: eventData)
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

    /// If the view controller is a UIHostingController<Content>, extract "Content"
    private static func extractSwiftUIViewNameIfHostingController(from vcTypeName: String) -> String? {
        // Matches patterns like "UIHostingController<ContentView>" or "UIHostingController<NavigationStack<ContentView>>"
        guard let startRange = vcTypeName.firstIndex(of: "<"), let endRange = vcTypeName.lastIndex(of: ">"), startRange < endRange else {
            return nil
        }
        let generic = String(vcTypeName[vcTypeName.index(after: startRange)..<endRange])
        // Take the last component if nested generics (e.g., NavigationStack<ContentView>)
        let components = generic.split(separator: ",").first?.split(separator: ">").last?.split(separator: "<")
        let flattened = components?.last ?? Substring(generic)
        // If it still contains nested generics, keep the last type token
        let tokens = flattened.split(separator: ".")
        return String(tokens.last ?? flattened)
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

#endif


