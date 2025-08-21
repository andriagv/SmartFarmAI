import SwiftUI

@main
struct SmartFarmAIApp: App {
    @StateObject private var yieldVM = YieldPredictionViewModel()
    @StateObject private var pestVM = PestDetectionViewModel()
    @StateObject private var optVM = OptimizationViewModel()
    @StateObject private var settingsVM = AppSettingsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(yieldVM)
                .environmentObject(pestVM)
                .environmentObject(optVM)
                .environmentObject(settingsVM)
        }
    }
}


