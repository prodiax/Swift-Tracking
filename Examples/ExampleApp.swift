import SwiftUI
import SwiftTracking

@main
struct ExampleApp: App {
    init() {
        // Initialize tracking
        let config = TrackingConfig(
            productId: "example-app",
            trackingEndpoint: "https://httpbin.org/post", // Using httpbin for testing
            enableAutoCapture: true,
            sessionTimeoutSeconds: 1800, // 30 minutes
            batchSize: 5,
            flushIntervalSeconds: 10
        )
        
        Tracker.shared.start(with: config)
        
        // Set user ID separately if needed
        Tracker.shared.setUserId("demo-user-123")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var counter = 0
    @State private var showingDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Swift-Tracking Example")
                    .font(.title)
                    .trackScreenView("Home Screen")
                
                Text("Counter: \(counter)")
                    .font(.headline)
                
                VStack(spacing: 15) {
                    Button("Increment Counter") {
                        counter += 1
                        Tracker.shared.track(
                            eventType: "counter_incremented",
                            data: ["count": counter]
                        )
                    }
                    .trackButtonTap("Increment Counter", data: ["count": counter]) {
                        counter += 1
                    }
                    
                    Button("Reset Counter") {
                        counter = 0
                        Tracker.shared.track(
                            eventType: "counter_reset",
                            data: ["previous_count": counter]
                        )
                    }
                    .trackButtonTap("Reset Counter")
                    
                    Button("Show Detail") {
                        showingDetail = true
                    }
                    .trackButtonTap("Show Detail")
                    
                    Button("Track Custom Event") {
                        Tracker.shared.track(
                            eventType: "custom_event",
                            data: [
                                "message": "Hello from Swift-Tracking!",
                                "timestamp": Date().timeIntervalSince1970,
                                "user_action": "button_press"
                            ]
                        )
                    }
                    .trackButtonTap("Track Custom Event")
                    
                    Button("Force Flush Events") {
                        Tracker.shared.flush()
                    }
                    .trackButtonTap("Force Flush Events")
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Swift-Tracking Demo")
            .trackNavigationTitle("Swift-Tracking Demo", data: ["section": "home"])
            .sheet(isPresented: $showingDetail) {
                DetailView()
            }
        }
    }
}

struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Detail Screen")
                    .font(.title)
                    .trackScreenView("Detail Screen", data: ["source": "home_screen"])
                
                Text("This is a detail screen that demonstrates screen tracking.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                VStack(spacing: 15) {
                    Button("Track Detail Action") {
                        Tracker.shared.track(
                            eventType: "detail_action",
                            data: [
                                "action_type": "detail_viewed",
                                "screen": "detail"
                            ]
                        )
                    }
                    .trackButtonTap("Track Detail Action")
                    
                    Button("Go Back") {
                        dismiss()
                    }
                    .trackButtonTap("Go Back")
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Detail")
            .navigationBarTitleDisplayMode(.inline)
            .trackNavigationTitle("Detail", data: ["source": "navigation", "parent": "home"])
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .trackButtonTap("Close Detail")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
