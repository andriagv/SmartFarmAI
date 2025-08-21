import Foundation
import UIKit

final class ExportService {
    static let shared = ExportService()
    private init() {}

    func csvFor(plan: FarmPlan, prediction: YieldPredictionResult?) -> Data? {
        var rows: [String] = []
        rows.append("Smart Farm AI Plan")
        rows.append("Crop,Region,Soil,Farm Size (ha),Created")
        rows.append("\(plan.crop.displayName),\(plan.region),\(plan.soilQuality),\(plan.farmSizeHa),\(ISO8601DateFormatter().string(from: plan.createdAt))")
        rows.append("")
        rows.append("Planting Dates")
        for d in plan.plantingDates { rows.append(ISO8601DateFormatter().string(from: d)) }
        if let pred = prediction {
            rows.append("")
            rows.append("Monthly Yields")
            let df = DateFormatter(); df.dateFormat = "yyyy-MM"
            for p in pred.monthlyYields { rows.append("\(df.string(from: p.month)),\(String(format: "%.2f", p.tonnes))") }
        }
        return rows.joined(separator: "\n").data(using: .utf8)
    }

    func pdfFor(plan: FarmPlan, prediction: YieldPredictionResult?) -> Data? {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let title = "Smart Farm AI Plan"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold)
            ]
            title.draw(at: CGPoint(x: 36, y: 36), withAttributes: attrs)

            var y: CGFloat = 80
            func drawLine(_ text: String, bold: Bool = false) {
                let font = UIFont.systemFont(ofSize: 14, weight: bold ? .semibold : .regular)
                text.draw(at: CGPoint(x: 36, y: y), withAttributes: [.font: font])
                y += 22
            }
            drawLine("Crop: \(plan.crop.displayName)")
            drawLine("Region: \(plan.region)")
            drawLine("Soil: \(plan.soilQuality)")
            drawLine("Size: \(plan.farmSizeHa) ha")
            y += 8
            drawLine("Planting Dates", bold: true)
            let df = DateFormatter(); df.dateStyle = .medium
            for d in plan.plantingDates { drawLine(df.string(from: d)) }
            y += 8
            drawLine("Recommendations", bold: true)
            for r in plan.recommendations { drawLine("• \(r.text)") }
            if let pred = prediction {
                y += 8
                drawLine("Predicted Total Yield: \(String(format: "%.2f", pred.totalYieldTonnes)) t", bold: true)
            }
        }
        return data
    }
}


