import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var settingsVM: AppSettingsViewModel

    var body: some View {
        Group {
            if settingsVM.isFirstLaunch {
                OnboardingView()
            } else {
                mainTabs
            }
        }
        .onAppear {
            settingsVM.handleFirstLaunch()
        }
    }

    private var mainTabs: some View {
        TabView {
            NavigationStack {
                YieldPredictionView()
                    .navigationTitle("Yield & Planner")
            }
            .tabItem {
                Label("Yield", systemImage: "chart.line.uptrend.xyaxis")
            }

            NavigationStack {
                PestDetectionView()
                    .navigationTitle("Pest & Disease")
            }
            .tabItem {
                Label("Pests", systemImage: "leaf.fill")
            }

            NavigationStack {
                MapView()
                    .navigationTitle("Map")
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }

            NavigationStack {
                OptimizationView()
                    .navigationTitle("Farm Optimization")
            }
            .tabItem {
                Label("Optimize", systemImage: "brain.head.profile")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .tint(.green)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppSettingsViewModel())
            .environmentObject(YieldPredictionViewModel())
            .environmentObject(PestDetectionViewModel())
    }
}


