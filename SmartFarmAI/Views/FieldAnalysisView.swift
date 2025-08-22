import SwiftUI

struct FieldAnalysisView: View {
    @ObservedObject var vm: FieldSelectionViewModel
    @State private var isLoading = true
    @State private var moisture: [Double] = []
    @State private var temps: [(Double, Double)] = []
    @State private var ndvi: [Double] = []
    @State private var forecast: [Double] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Field Analysis").font(.title2).bold()
                overview
                if isLoading { ProgressView("Analyzing satellite data...") } else { analytics }
                actionButtons
            }
            .padding()
        }
        .onAppear { simulateLoad() }
        .navigationTitle("Field Analysis")
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Area: \(String(format: "%.2f", vm.areaHectares)) ha").bold()
            Text("Coordinates: \(vm.polygon.prefix(4).map { String(format: "%.4f, %.4f", $0.latitude, $0.longitude) }.joined(separator: " • "))...")
        }.card()
    }

    private var analytics: some View {
        VStack(alignment: .leading, spacing: 16) {
            section(title: "Soil Moisture (30d)") {
                Text("Chart placeholder - Soil moisture data")
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
            }
            section(title: "Temperature Trends") {
                Text("Chart placeholder - Temperature data")
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
            }
            section(title: "Vegetation Health Index (NDVI)") {
                Text("Chart placeholder - NDVI data")
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
            }
            section(title: "7-day Weather Forecast (mm)") {
                Text("Chart placeholder - Weather forecast")
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .background(Color.cyan.opacity(0.1))
            }
            recommendations
        }
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            content()
        }.card()
    }

    private var recommendations: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommendations").font(.headline)
            Text("• Crop: \(["Corn","Soybeans","Wheat"].randomElement()!)")
            Text("• Irrigation: \(Int.random(in: 10...25)) mm in next 48h")
            Text("• Fertilizer: N \(Int.random(in: 15...30)) kg/ha")
        }.card()
    }

    private var actionButtons: some View {
        HStack {
            Button("Save Analysis") {}
            Button("Share Report") {}
            Button("Schedule Monitoring") {}
        }.buttonStyle(.bordered)
    }

    private func simulateLoad() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            moisture = (0..<30).map { _ in Double.random(in: 35...85) }
            temps = (0..<30).map { _ in (Double.random(in: 22...35), Double.random(in: 12...20)) }
            ndvi = (0..<30).map { _ in Double.random(in: 0.2...0.9) }
            forecast = (0..<7).map { _ in Double.random(in: 0...12) }
            isLoading = false
        }
    }
}


