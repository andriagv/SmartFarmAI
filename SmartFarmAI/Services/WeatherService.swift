import Foundation

struct MockContainer: Codable {
    let weather: [WeatherData]
    let treatments: [Treatment]
}

struct Treatment: Codable {
    let name: String
    let treatment: String
}

final class WeatherService {
    static let shared = WeatherService()
    private init() {}

    func loadWeather() -> [WeatherData] {
        guard let container: MockContainer = DataManager.shared.loadMockJSON(MockContainer.self, from: "MockData") else { return [] }
        return container.weather
    }

    func treatment(for disease: String) -> String? {
        guard let container: MockContainer = DataManager.shared.loadMockJSON(MockContainer.self, from: "MockData") else { return nil }
        return container.treatments.first(where: { $0.name == disease })?.treatment
    }
}


