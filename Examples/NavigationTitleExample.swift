import SwiftUI
import SwiftTracking

/// Example demonstrating proper navigation title tracking in SwiftUI
struct NavigationTitleExample: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Initialize the tracker
                    let config = TrackingConfig(
                        productId: "navigation-title-example",
                        trackingEndpoint: "https://your-tracking-endpoint.com/events",
                        enableAutoCapture: true
                    )
                    Tracker.shared.start(with: config)
                }
        }
    }
}

struct ContentView: View {
    @State private var showingProfile = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Navigation Title Tracking Demo")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                
                VStack(spacing: 15) {
                    Button("Go to Profile") {
                        showingProfile = true
                    }
                    .trackButtonTap("Go to Profile", data: ["section": "main"])
                    
                    Button("Go to Settings") {
                        showingSettings = true
                    }
                    .trackButtonTap("Go to Settings", data: ["section": "main"])
                }
                .padding()
            }
            .navigationTitle("Home")
            .trackNavigationTitle("Home", data: ["section": "main"])
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentTab = "Overview"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("User Profile")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Tab-like interface
                HStack(spacing: 20) {
                    Button("Overview") {
                        currentTab = "Overview"
                        Tracker.shared.updateNavigationTitle("Profile - Overview", data: ["tab": "overview"])
                    }
                    .trackButtonTap("Profile Tab - Overview", data: ["tab": "overview"])
                    
                    Button("Settings") {
                        currentTab = "Settings"
                        Tracker.shared.updateNavigationTitle("Profile - Settings", data: ["tab": "settings"])
                    }
                    .trackButtonTap("Profile Tab - Settings", data: ["tab": "settings"])
                }
                .padding()
                
                Text("Current Tab: \(currentTab)")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .trackButtonTap("Close Profile", data: ["action": "dismiss"])
            }
            .navigationTitle("Profile - \(currentTab)")
            .trackNavigationTitle("Profile - \(currentTab)", data: ["section": "profile", "tab": currentTab.lowercased()])
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 15) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            Tracker.shared.track(eventType: "Setting Changed", data: [
                                "setting": "notifications",
                                "value": newValue
                            ])
                        }
                    
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                        .onChange(of: darkModeEnabled) { newValue in
                            Tracker.shared.track(eventType: "Setting Changed", data: [
                                "setting": "dark_mode",
                                "value": newValue
                            ])
                        }
                }
                .padding()
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .trackButtonTap("Close Settings", data: ["action": "dismiss"])
            }
            .navigationTitle("Settings")
            .trackNavigationTitle("Settings", data: ["section": "settings"])
        }
    }
}

#Preview {
    ContentView()
}
