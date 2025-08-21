import Foundation
import SwiftUI

enum GrowthStage: String, CaseIterable, Codable {
    case seedling
    case vegetative
    case flowering
    case grainFill
    case maturity
}

struct UsagePoint: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let week: String
    let liters: Double
}

struct OptimizationRecommendation: Hashable, Codable {
    let icon: String
    let text: String
}

final class OptimizationViewModel: ObservableObject {
    @Published var soilMoisture: Int = 40
    @Published var recentRainfallMm: Int = 10
    @Published var fertilizerHistory: String = ""
    @Published var growthStage: GrowthStage = .vegetative

    @Published var recommendations: [OptimizationRecommendation] = []
    @Published var usageTrend: [UsagePoint] = []
    @Published var schedule: [Date] = []
    @Published var newScheduleDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()

    func loadMock() {
        usageTrend = [
            UsagePoint(week: "W1", liters: 120),
            UsagePoint(week: "W2", liters: 98),
            UsagePoint(week: "W3", liters: 110),
            UsagePoint(week: "W4", liters: 90)
        ]
        schedule = [Date().addingTimeInterval(3600*24), Date().addingTimeInterval(3600*72)]
    }

    func calculate() {
        let moistureNeedHigh = soilMoisture < 35 && recentRainfallMm < 15
        recommendations = [
            OptimizationRecommendation(icon: "drop", text: moistureNeedHigh ? "Irrigate 15 mm within 24 hours." : "No irrigation needed today."),
            OptimizationRecommendation(icon: "leaf", text: growthStage == .vegetative ? "Apply nitrogen side-dress (30 kg/ha)." : "Maintain current fertilization schedule."),
            OptimizationRecommendation(icon: "clock", text: "Re-evaluate after next rainfall.")
        ]
        // Auto propose next schedule
        if moistureNeedHigh {
            newScheduleDate = Date().addingTimeInterval(3600 * 20)
        }
    }

    func scheduleNotification(for date: Date) {
        NotificationService.shared.schedule(title: "Farm Task", body: "Water/Fertilize as planned.", date: date)
    }

    func addSchedule() {
        schedule.append(newScheduleDate)
        schedule.sort()
        scheduleNotification(for: newScheduleDate)
    }
}


