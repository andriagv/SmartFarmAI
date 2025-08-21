import Foundation

final class AppSettingsViewModel: ObservableObject {
    @Published var isFirstLaunch: Bool = true
    @Published var profile: UserProfile = UserProfile.default {
        didSet { saveProfile() }
    }

    func handleFirstLaunch() {
        let key = "hasLaunchedBefore"
        let launched = UserDefaults.standard.bool(forKey: key)
        if launched {
            isFirstLaunch = false
        } else {
            UserDefaults.standard.set(true, forKey: key)
            isFirstLaunch = true
        }
        loadProfile()
    }

    private func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: "profile"),
           let p = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = p
        }
    }

    private func saveProfile() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: "profile")
        }
    }
}


