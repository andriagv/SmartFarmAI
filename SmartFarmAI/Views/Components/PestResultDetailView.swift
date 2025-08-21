import SwiftUI

struct PestResultDetailView: View {
    let result: PestAnalysisResult

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: result.severity.iconName)
                        .foregroundColor(result.severity.color)
                    VStack(alignment: .leading) {
                        Text(result.diseaseName).font(.title3).bold()
                        Text("Confidence: \(Int(result.confidence*100))% • \(result.severity.rawValue.capitalized)")
                            .foregroundColor(.secondary)
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Treatment Recommendation").font(.headline)
                    Text(result.recommendation)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Scan Result")
            .toolbar { ToolbarItem(placement: .primaryAction) { Button("Done") { dismiss() } } }
        }
    }

    private func dismiss() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


