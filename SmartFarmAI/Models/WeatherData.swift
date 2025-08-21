import Foundation

struct WeatherData: Codable, Hashable {
    let date: Date
    let temperatureC: Double
    let precipitationMm: Double
    let humidity: Double
}

struct YieldPoint: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let month: Date
    let tonnes: Double
}


