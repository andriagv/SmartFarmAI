import SwiftUI

struct SettingsView: View {
    @AppStorage("preferredUnit") private var preferredUnit: String = "metric"
    @EnvironmentObject private var settingsVM: AppSettingsViewModel
    @State private var notificationsEnabled: Bool = true

    var body: some View {
        Form {
            Section(header: Text("Profile")) {
                NavigationLink("Edit Profile") {
                    ProfileEditorView(profile: $settingsVM.profile)
                }
                HStack {
                    Image(systemName: "person.crop.circle.fill").font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text(settingsVM.profile.fullName).bold()
                        Text(settingsVM.profile.farmName).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            Section(header: Text("Preferences")) {
                Picker("Units", selection: $preferredUnit) {
                    Text("Metric").tag("metric")
                    Text("Imperial").tag("imperial")
                }
                Toggle("Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { newValue in
                        if newValue { NotificationService.shared.requestAuthorization() }
                    }
            }
            Section(header: Text("Help")) {
                NavigationLink("Tutorial", destination: TutorialView())
                Button("Share App") { shareApp() }
            }
        }
        .navigationTitle("Settings")
    }

    private func shareApp() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        let av = UIActivityViewController(activityItems: ["Check out Smart Farm AI!"], applicationActivities: nil)
        root.present(av, animated: true)
    }
}

struct TutorialView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Getting Started").font(.title2).bold()
                Text("1. Configure your farm in Yield & Planner.")
                Text("2. Scan plants to detect diseases.")
                Text("3. Optimize water and fertilizer schedules.")
            }
            .padding()
        }
        .navigationTitle("Tutorial")
    }
}


