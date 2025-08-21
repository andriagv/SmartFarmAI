import Foundation
import SwiftUI

enum PestSeverity: String, CaseIterable, Codable {
    case mild
    case moderate
    case severe

    var color: Color {
        switch self {
        case .mild: return .green
        case .moderate: return .orange
        case .severe: return .red
        }
    }

    var iconName: String {
        switch self {
        case .mild: return "exclamationmark.circle"
        case .moderate: return "exclamationmark.triangle"
        case .severe: return "xmark.octagon"
        }
    }
}

struct PestAnalysisResult: Identifiable, Codable {
    let id: UUID
    let diseaseName: String
    let confidence: Double
    let severity: PestSeverity
    let recommendation: String
    let date: Date
}


