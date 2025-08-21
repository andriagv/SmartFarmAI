import SwiftUI
import Charts

struct OptimizationView: View {
    @EnvironmentObject private var viewModel: OptimizationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                inputsForm
                if !viewModel.recommendations.isEmpty {
                    recommendations
                    usageCharts
                    scheduling
                }
            }
            .padding()
        }
        .onAppear { viewModel.loadMock() }
    }

    private var inputsForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Optimization Inputs").font(.headline)
            Stepper(value: $viewModel.soilMoisture, in: 0...100) {
                Text("Soil Moisture: \(viewModel.soilMoisture)%")
            }
            Stepper(value: $viewModel.recentRainfallMm, in: 0...200) {
                Text("Rainfall (7d): \(viewModel.recentRainfallMm) mm")
            }
            Picker("Growth Stage", selection: $viewModel.growthStage) {
                ForEach(GrowthStage.allCases, id: \.self) { stage in
                    Text(stage.rawValue.capitalized).tag(stage)
                }
            }
            TextField("Fertilizer History (e.g. NPK 10-10-10 last week)", text: $viewModel.fertilizerHistory)
            Button("Calculate Recommendations") { viewModel.calculate() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var recommendations: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Recommendations").font(.headline)
            ForEach(viewModel.recommendations, id: \.self) { rec in
                HStack(alignment: .top) {
                    Image(systemName: rec.icon).foregroundColor(.green)
                    Text(rec.text)
                }
            }
            Divider().padding(.vertical, 4)
            impactMetrics
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var usageCharts: some View {
        VStack(alignment: .leading) {
            Text("Usage Trends").font(.headline)
            Chart(viewModel.usageTrend) { point in
                BarMark(
                    x: .value("Week", point.week),
                    y: .value("Liters", point.liters)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 180)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var scheduling: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Schedule").font(.headline)
            HStack {
                DatePicker("", selection: $viewModel.newScheduleDate, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                Button("Add") { viewModel.addSchedule() }
                    .buttonStyle(.borderedProminent)
            }
            ForEach(viewModel.schedule, id: \.self) { item in
                HStack {
                    Image(systemName: "bell")
                    Text(item.formatted(date: .abbreviated, time: .shortened))
                    Spacer()
                    Button("Notify") { viewModel.scheduleNotification(for: item) }
                }
                .padding(8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var impactMetrics: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Environmental Impact").font(.subheadline).foregroundColor(.secondary)
            let waterSaved = max(0, 20 - Double(viewModel.recentRainfallMm) * 0.1)
            let co2Saved = waterSaved * 0.05
            HStack {
                Label("Water saved: \(String(format: "%.1f", waterSaved)) L/ha", systemImage: "drop.fill")
                Spacer()
                Label("CO₂ saved: \(String(format: "%.2f", co2Saved)) kg/ha", systemImage: "leaf.fill")
            }.font(.footnote)
        }
    }
}

struct OptimizationView_Previews: PreviewProvider {
    static var previews: some View {
        OptimizationView()
            .environmentObject(OptimizationViewModel())
    }
}


