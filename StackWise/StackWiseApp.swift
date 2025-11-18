import SwiftUI

// MARK: - StackWiseApp
@main
struct StackWiseApp: App {
    @StateObject private var container = DIContainer(useMocks: false) // Using real services
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
                .environment(\.container, container)
        }
    }
}

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var container: DIContainer
    @State private var showOnboarding = false
    @State private var selectedTab = 0
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            if container.onboardingCompleted && container.currentStack != nil {
                // Main app with tabs
                MainTabView(selectedTab: $selectedTab)
                    .environmentObject(container)
                    .environment(\.container, container)
            } else {
                // Show onboarding
                OnboardingFlow(container: container)
                    .environmentObject(container)
                    .id(container.isRemixFlow ? "remix" : "onboarding")
            }
        }
        .onAppear {
            // Check if we need to show onboarding
            showOnboarding = !container.onboardingCompleted || container.currentStack == nil
        }
        .onChange(of: container.onboardingCompleted) { _, completed in
            if completed && container.currentStack != nil {
                // Transition from onboarding to main app
                withAnimation(Theme.Animation.standard) {
                    showOnboarding = false
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active && container.currentJobId != nil {
                // Resume polling for pending job when app returns from background
                Task {
                    do {
                        try await container.resumeJobPolling()
                    } catch {
                        print("Failed to resume job polling: \(error)")
                    }
                }
            }
        }
    }
}

// MARK: - MainTabView
struct MainTabView: View {
    @Binding var selectedTab: Int
    @Environment(\.container) private var container
    
    var body: some View {
        TabView(selection: $selectedTab) {
            StackView(container: container)
                .tabItem {
                    Label("Stack", systemImage: "pills.fill")
                }
                .tag(0)
            
            TodayView(container: container)
                .tabItem {
                    Label("Today", systemImage: "checklist")
                }
                .tag(1)
            
            TrackView(container: container)
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .tag(2)
            
            ChatView(container: container)
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
                .tag(3)
            
            ProfileView(container: container)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(Theme.Colors.primary)
    }
}