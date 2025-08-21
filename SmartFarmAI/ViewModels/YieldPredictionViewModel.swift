import Foundation
import SwiftUI

final class YieldPredictionViewModel: ObservableObject {
    @Published var crops: [Crop] = Crop.allCases
    @Published var regions: [String] = ["Midwest", "Great Plains", "Southeast", "West"]
    @Published var selectedCrop: Crop = .corn
    @Published var selectedRegion: String = "Midwest"
    @Published var soilQuality: Int = 3
    @Published var farmSizeText: String = "50"

    @Published var predictionResult: YieldPredictionResult?
    @Published var plantingDates: [Date] = []
    @Published var recommendations: [Recommendation] = []
    @Published var formErrorMessage: String?
    @Published var currentPlan: FarmPlan?

    var isFormValid: Bool {
        Double(farmSizeText) != nil && soilQuality >= 1 && soilQuality <= 5
    }

    func loadMock() {
        // Placeholder for loading cached state or mock data
    }

    func predictYield() {
        guard isFormValid, let size = Double(farmSizeText) else {
            formErrorMessage = "Please enter a valid farm size."
            return
        }
        formErrorMessage = nil

        let baseYieldPerHa: Double
        switch selectedCrop {
        case .corn: baseYieldPerHa = 9.0
        case .wheat: baseYieldPerHa = 4.5
        case .soybeans: baseYieldPerHa = 3.0
        case .rice: baseYieldPerHa = 6.5
        case .cotton: baseYieldPerHa = 2.2
        }

        let soilMultiplier = 0.7 + Double(soilQuality) * 0.1
        let regionFactor: Double = ["Midwest": 1.1, "Great Plains": 1.0, "Southeast": 0.95, "West": 0.9][selectedRegion] ?? 1.0

        let weatherBoost = 0.9 + Double.random(in: 0.0...0.3)
        let total = baseYieldPerHa * size * soilMultiplier * regionFactor * weatherBoost

        var monthly: [YieldPoint] = []
        let calendar = Calendar.current
        let start = calendar.date(from: DateComponents(year: calendar.component(.year, from: Date()), month: 1, day: 1)) ?? Date()
        for m in 0..<12 {
            if let d = calendar.date(byAdding: .month, value: m, to: start) {
                let seasonal = sin(Double(m) / 12.0 * 2 * Double.pi) * 0.3 + 0.7
                monthly.append(YieldPoint(month: d, tonnes: max(0, total / 12.0 * seasonal)))
            }
        }
        predictionResult = YieldPredictionResult(totalYieldTonnes: total, monthlyYields: monthly)

        // Recommendations
        recommendations = [
            Recommendation(text: "Apply nitrogen at early growth stage.", level: "medium"),
            Recommendation(text: "Consider irrigation during flowering weeks.", level: "high"),
            Recommendation(text: "Schedule pest scouting bi-weekly.", level: "low")
        ]
    }

    func generatePlan() {
        let calendar = Calendar.current
        let today = Date()
        plantingDates = (0..<4).compactMap { offset in
            calendar.date(byAdding: .weekOfYear, value: offset * 3, to: today)
        }
        // Build a plan object and persist
        guard let size = Double(farmSizeText) else { return }
        let plan = FarmPlan(
            id: UUID(),
            crop: selectedCrop,
            region: selectedRegion,
            soilQuality: soilQuality,
            farmSizeHa: size,
            plantingDates: plantingDates,
            recommendations: recommendations,
            createdAt: Date()
        )
        currentPlan = plan
        CoreDataStack.shared.savePlan(plan)
    }

    func exportCSV() -> URL? {
        guard let plan = currentPlan else { return nil }
        let data = ExportService.shared.csvFor(plan: plan, prediction: predictionResult)
        return writeTempFile(data: data, filename: "SmartFarmAI-Plan.csv")
    }

    func exportPDF() -> URL? {
        guard let plan = currentPlan else { return nil }
        let data = ExportService.shared.pdfFor(plan: plan, prediction: predictionResult)
        return writeTempFile(data: data, filename: "SmartFarmAI-Plan.pdf")
    }

    private func writeTempFile(data: Data?, filename: String) -> URL? {
        guard let data = data else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(to: url)
        return url
    }
}


