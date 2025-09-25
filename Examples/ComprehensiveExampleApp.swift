import SwiftUI
import SwiftTracking

/// Comprehensive example app demonstrating all SwiftTracking auto-capture features
@main
struct ComprehensiveExampleApp: App {
    @StateObject private var tracker = Tracker.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    setupTracking()
                }
        }
    }
    
    private func setupTracking() {
        let config = TrackingConfig(
            productId: "com.example.comprehensive",
            trackingEndpoint: "https://api.example.com/track",
            flushIntervalSeconds: 30,
            flushBatchSize: 10,
            sessionTimeoutSeconds: 300,
            enableAutoCapture: true
        )
        
        tracker.start(with: config)
        
        // Track app launch
        tracker.track(eventType: "app_launched", data: [
            "source": "comprehensive_example",
            "version": "1.0.0"
        ])
    }
}

struct ContentView: View {
    @State private var text = ""
    @State private var showingDetail = false
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack {
                        Text("SwiftTracking Demo")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .trackScreenView("Main Screen", data: ["section": "header"])
                        
                        Text("Comprehensive Auto-Capture Features")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Screen View Tracking Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Screen View Tracking")
                            .font(.headline)
                        
                        Button("Navigate to Detail") {
                            showingDetail = true
                        }
                        .trackButtonTap("Navigate to Detail", data: ["section": "screen_views"])
                        
                        Button("Track Custom Screen View") {
                            Tracker.shared.trackScreenView("Custom Screen", data: [
                                "custom_property": "custom_value",
                                "timestamp": Date().timeIntervalSince1970
                            ])
                        }
                        .trackButtonTap("Track Custom Screen View", data: ["section": "screen_views"])
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Element Interaction Tracking Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Element Interaction Tracking")
                            .font(.headline)
                        
                        HStack {
                            Button("Button 1") {
                                Tracker.shared.trackButtonTap("Button 1", data: ["section": "element_interactions"])
                            }
                            .trackButtonTap("Button 1", data: ["section": "element_interactions"])
                            
                            Button("Button 2") {
                                Tracker.shared.trackButtonTap("Button 2", data: ["section": "element_interactions"])
                            }
                            .trackButtonTap("Button 2", data: ["section": "element_interactions"])
                        }
                        
                        // Text Field with tracking
                        TrackingTextField(
                            "Enter text here",
                            text: $text,
                            accessibilityLabel: "Demo text field",
                            accessibilityIdentifier: "demo_text_field",
                            data: ["section": "element_interactions"]
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        // List item tracking
                        VStack(alignment: .leading) {
                            Text("List Items:")
                            ForEach(0..<3) { index in
                                HStack {
                                    Text("Item \(index + 1)")
                                    Spacer()
                                    Button("Select") {
                                        Tracker.shared.trackListItemInteraction(
                                            action: "select",
                                            itemText: "Item \(index + 1)",
                                            accessibilityLabel: "List item \(index + 1)",
                                            accessibilityIdentifier: "list_item_\(index + 1)",
                                            data: ["section": "element_interactions", "index": index]
                                        )
                                    }
                                    .trackButtonTap("Select Item \(index + 1)", data: ["section": "element_interactions", "index": index])
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Gesture Tracking Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Gesture Tracking")
                            .font(.headline)
                        
                        // Tap gesture tracking
                        Text("Tap me!")
                            .padding()
                            .background(Color.orange.opacity(0.3))
                            .cornerRadius(8)
                            .trackTapGesture(
                                accessibilityLabel: "Tap gesture demo",
                                accessibilityIdentifier: "tap_gesture_demo",
                                data: ["section": "gestures", "type": "tap"]
                            )
                        
                        // Long press gesture tracking
                        Text("Long press me!")
                            .padding()
                            .background(Color.purple.opacity(0.3))
                            .cornerRadius(8)
                            .trackLongPressGesture(
                                minimumDuration: 1.0,
                                accessibilityLabel: "Long press gesture demo",
                                accessibilityIdentifier: "long_press_gesture_demo",
                                data: ["section": "gestures", "type": "long_press"]
                            )
                        
                        // Drag gesture tracking
                        Text("Drag me!")
                            .padding()
                            .background(Color.red.opacity(0.3))
                            .cornerRadius(8)
                            .trackDragGesture(
                                accessibilityLabel: "Drag gesture demo",
                                accessibilityIdentifier: "drag_gesture_demo",
                                data: ["section": "gestures", "type": "drag"]
                            )
                        
                        // Magnification gesture tracking
                        Text("Pinch me!")
                            .padding()
                            .background(Color.yellow.opacity(0.3))
                            .cornerRadius(8)
                            .scaleEffect(scale)
                            .trackMagnificationGesture(
                                accessibilityLabel: "Magnification gesture demo",
                                accessibilityIdentifier: "magnification_gesture_demo",
                                data: ["section": "gestures", "type": "magnification"]
                            )
                            .onMagnificationChanged { value in
                                scale = value
                            }
                        
                        // Rotation gesture tracking
                        Text("Rotate me!")
                            .padding()
                            .background(Color.cyan.opacity(0.3))
                            .cornerRadius(8)
                            .rotationEffect(.degrees(rotation))
                            .trackRotationGesture(
                                accessibilityLabel: "Rotation gesture demo",
                                accessibilityIdentifier: "rotation_gesture_demo",
                                data: ["section": "gestures", "type": "rotation"]
                            )
                            .onRotationChanged { value in
                                rotation = value.degrees
                            }
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Frustration Interaction Tracking Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Frustration Interaction Tracking")
                            .font(.headline)
                        
                        Text("Click rapidly to trigger rage click detection:")
                            .font(.caption)
                        
                        Button("Click me rapidly!") {
                            // This will be tracked for rage click detection
                            Tracker.shared.trackClick(x: 100, y: 100)
                        }
                        .trackClicks()
                        
                        Text("Click and wait for dead click detection:")
                            .font(.caption)
                        
                        Button("Click and wait") {
                            Tracker.shared.trackClick(x: 200, y: 200)
                            // Don't call markClickResponse() to trigger dead click
                        }
                        .trackClicks()
                        
                        Button("Click with response") {
                            Tracker.shared.trackClick(x: 300, y: 300)
                            Tracker.shared.markClickResponse()
                        }
                        .trackClicks()
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Network Tracking Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Network Tracking")
                            .font(.headline)
                        
                        Button("Simulate Successful Request") {
                            let startTime = Date()
                            let completionTime = Date().addingTimeInterval(0.5)
                            
                            Tracker.shared.trackSuccessfulRequest(
                                url: "https://api.example.com/data",
                                method: "GET",
                                statusCode: 200,
                                startTime: startTime,
                                completionTime: completionTime,
                                requestBodySize: 0,
                                responseBodySize: 1024,
                                requestHeaders: ["Content-Type": "application/json"],
                                responseHeaders: ["Content-Type": "application/json", "Content-Length": "1024"]
                            )
                        }
                        .trackButtonTap("Simulate Successful Request", data: ["section": "network"])
                        
                        Button("Simulate Failed Request") {
                            let startTime = Date()
                            let completionTime = Date().addingTimeInterval(0.3)
                            
                            Tracker.shared.trackFailedRequest(
                                url: "https://api.example.com/error",
                                method: "POST",
                                errorCode: 404,
                                errorMessage: "Not Found",
                                startTime: startTime,
                                completionTime: completionTime,
                                requestBodySize: 256
                            )
                        }
                        .trackButtonTap("Simulate Failed Request", data: ["section": "network"])
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Deep Link Tracking Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Deep Link Tracking")
                            .font(.headline)
                        
                        Button("Simulate Deep Link") {
                            Tracker.shared.trackDeepLinkOpened(
                                url: "https://example.com/deep-link",
                                referrer: "https://google.com"
                            )
                        }
                        .trackButtonTap("Simulate Deep Link", data: ["section": "deep_links"])
                        
                        Button("Simulate Deep Link with URL Object") {
                            if let url = URL(string: "https://example.com/deep-link-2"),
                               let referrer = URL(string: "https://apple.com") {
                                Tracker.shared.trackDeepLinkOpened(url: url, referrer: referrer)
                            }
                        }
                        .trackButtonTap("Simulate Deep Link with URL Object", data: ["section": "deep_links"])
                    }
                    .padding()
                    .background(Color.indigo.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Custom Event Tracking Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Custom Event Tracking")
                            .font(.headline)
                        
                        Button("Track Custom Event") {
                            Tracker.shared.track(eventType: "custom_event", data: [
                                "custom_property": "custom_value",
                                "timestamp": Date().timeIntervalSince1970,
                                "user_action": "button_press"
                            ])
                        }
                        .trackButtonTap("Track Custom Event", data: ["section": "custom_events"])
                        
                        Button("Track Event with Complex Data") {
                            Tracker.shared.track(eventType: "complex_event", data: [
                                "user_id": "12345",
                                "session_id": "session_67890",
                                "properties": [
                                    "color": "blue",
                                    "size": "large",
                                    "category": "demo"
                                ],
                                "metadata": [
                                    "source": "comprehensive_example",
                                    "version": "1.0.0"
                                ]
                            ])
                        }
                        .trackButtonTap("Track Event with Complex Data", data: ["section": "custom_events"])
                    }
                    .padding()
                    .background(Color.teal.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Flush Events Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Event Management")
                            .font(.headline)
                        
                        Button("Force Flush Events") {
                            Tracker.shared.flush()
                        }
                        .trackButtonTap("Force Flush Events", data: ["section": "event_management"])
                        
                        Button("Track Multiple Events") {
                            for i in 1...5 {
                                Tracker.shared.track(eventType: "batch_event", data: [
                                    "batch_number": i,
                                    "timestamp": Date().timeIntervalSince1970
                                ])
                            }
                        }
                        .trackButtonTap("Track Multiple Events", data: ["section": "event_management"])
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("SwiftTracking Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingDetail) {
            DetailView()
        }
    }
}

struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Detail Screen")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .trackScreenView("Detail Screen", data: ["source": "navigation"])
                
                Text("This screen demonstrates automatic screen view tracking when navigating.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Go Back") {
                    dismiss()
                }
                .trackButtonTap("Go Back", data: ["source": "detail_screen"])
                
                Spacer()
            }
            .padding()
            .navigationTitle("Detail")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .trackButtonTap("Back Button", data: ["source": "toolbar"])
                }
            }
        }
    }
}

// Extension for gesture tracking
extension View {
    func onMagnificationChanged(_ action: @escaping (CGFloat) -> Void) -> some View {
        self.gesture(
            MagnificationGesture()
                .onChanged { value in
                    action(value)
                }
        )
    }
    
    func onRotationChanged(_ action: @escaping (Angle) -> Void) -> some View {
        self.gesture(
            RotationGesture()
                .onChanged { value in
                    action(value)
                }
        )
    }
}
