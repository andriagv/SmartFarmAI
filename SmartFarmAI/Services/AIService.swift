import Foundation
import UIKit

final class AIService {
    static let shared = AIService()
    private init() {}

    func analyzePlant(image: UIImage, completion: @escaping (PestAnalysisResult) -> Void) {
        // Mock analysis; in real app integrate Core ML/Vision
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
            let result = PestAnalysisResult(id: UUID(), diseaseName: "Leaf Spot", confidence: 0.76, severity: .moderate, recommendation: "Use copper-based fungicide and remove debris.", date: Date())
            DispatchQueue.main.async { completion(result) }
        }
    }
}


