import Foundation
import SwiftUI

final class PestDetectionViewModel: ObservableObject {
    @Published var isAnalyzing: Bool = false
    @Published var lastResult: PestAnalysisResult?
    @Published var history: [PestAnalysisResult] = []
    @Published var filterSeverity: PestSeverity? = nil

    var filteredHistory: [PestAnalysisResult] {
        if let f = filterSeverity { return history.filter { $0.severity == f } }
        return history
    }

    func loadHistory() {
        let stored = CoreDataStack.shared.fetchScans()
        if !stored.isEmpty { history = stored; return }
        history = [
            PestAnalysisResult(id: UUID(), diseaseName: "Powdery Mildew", confidence: 0.82, severity: .moderate, recommendation: "Use sulfur-based fungicide.", date: Date().addingTimeInterval(-3600 * 24)),
            PestAnalysisResult(id: UUID(), diseaseName: "Leaf Rust", confidence: 0.65, severity: .mild, recommendation: "Monitor and apply fungicide if spreading.", date: Date().addingTimeInterval(-3600 * 48))
        ]
    }

    func analyze(image: UIImage) {
        isAnalyzing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let name = ["Early Blight", "Leaf Spot", "Powdery Mildew"].randomElement() ?? "Leaf Spot"
            let recommendation = WeatherService.shared.treatment(for: name) ?? "Consult agronomist."
            let result = PestAnalysisResult(id: UUID(), diseaseName: name, confidence: 0.91, severity: .severe, recommendation: recommendation, date: Date())
            self.lastResult = result
            self.history.insert(result, at: 0)
            CoreDataStack.shared.saveScan(result)
            self.isAnalyzing = false
        }
    }
}


