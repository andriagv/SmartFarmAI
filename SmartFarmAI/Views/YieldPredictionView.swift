import SwiftUI

struct YieldPredictionView: View {
    @EnvironmentObject private var viewModel: YieldPredictionViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                yieldForm
                if let prediction = viewModel.predictionResult {
                    yieldChart(prediction)
                    planSection
                    recommendationsSection
                    exportButtons
                }
            }
            .padding()
        }
        .onAppear { viewModel.loadMock() }
    }

    private var yieldForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Farm Inputs").font(.headline)
            Picker("Crop", selection: $viewModel.selectedCrop) {
                ForEach(viewModel.crops, id: \.self) { crop in
                    Text(crop.displayName).tag(crop)
                }
            }
            Picker("Region", selection: $viewModel.selectedRegion) {
                ForEach(viewModel.regions, id: \.self) { region in
                    Text(region).tag(region)
                }
            }
            Stepper(value: $viewModel.soilQuality, in: 1...5) {
                Text("Soil Quality: \(viewModel.soilQuality)")
            }
            HStack {
                Text("Farm Size (ha)")
                TextField("e.g. 50", text: $viewModel.farmSizeText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            Button(action: { viewModel.predictYield() }) {
                Label("Predict Yield", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.isFormValid)
            if let error = viewModel.formErrorMessage {
                Text(error).foregroundColor(.red).font(.footnote)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func yieldChart(_ result: YieldPredictionResult) -> some View {
        VStack(alignment: .leading) {
            Text("Predicted Yield")
                .font(.headline)
            Text("Chart placeholder - Yield prediction data")
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.1))
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var planSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Planting Calendar").font(.headline)
            if viewModel.plantingDates.isEmpty {
                Text("No plan generated yet.").foregroundColor(.secondary)
            } else {
                CalendarView(dates: viewModel.plantingDates)
            }
            Button("Generate Plan") { viewModel.generatePlan() }
                .buttonStyle(.bordered)
        }
        .card()
    }

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommendations").font(.headline)
            ForEach(viewModel.recommendations, id: \.self) { rec in
                HStack(alignment: .top) {
                    Circle().fill(rec.color).frame(width: 10, height: 10)
                    Text(rec.text)
                }
            }
        }
        .card()
    }

    private var exportButtons: some View {
        HStack {
            Button {
                if let url = viewModel.exportCSV() { share(url: url) }
            } label: { Label("Export CSV", systemImage: "square.and.arrow.up") }
            Button {
                if let url = viewModel.exportPDF() { share(url: url) }
            } label: { Label("Export PDF", systemImage: "doc.richtext") }
        }
        .buttonStyle(.borderedProminent)
    }

    private func share(url: URL) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        root.present(av, animated: true)
    }
}

struct YieldPredictionView_Previews: PreviewProvider {
    static var previews: some View {
        YieldPredictionView()
            .environmentObject(YieldPredictionViewModel())
    }
}


