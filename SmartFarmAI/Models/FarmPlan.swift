import Foundation
import SwiftUI

struct Recommendation: Hashable, Codable {
    let text: String
    let level: String

    var color: Color {
        switch level {
        case "high": return .red
        case "medium": return .orange
        default: return .green
        }
    }
}

struct FarmPlan: Identifiable, Codable {
    let id: UUID
    let crop: Crop
    let region: String
    let soilQuality: Int
    let farmSizeHa: Double
    let plantingDates: [Date]
    let recommendations: [Recommendation]
    let createdAt: Date
}

struct YieldPredictionResult: Codable {
    let totalYieldTonnes: Double
    let monthlyYields: [YieldPoint]
}


