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
            Text("Coordinates: \(vm.coordinatesText)")
        }.card()
    }

    private var analytics: some View {
        VStack(alignment: .leading, spacing: 16) {
            section(title: "Soil Moisture (30d)") {
                if moisture.isEmpty {
                    Text("Loading soil moisture data...")
                        .frame(height: 160)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                } else {
                    soilMoistureChart
                }
            }
            section(title: "Temperature Trends") {
                if temps.isEmpty {
                    Text("Loading temperature data...")
                        .frame(height: 160)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                } else {
                    temperatureChart
                }
            }
            section(title: "Vegetation Health Index (NDVI)") {
                if ndvi.isEmpty {
                    Text("Loading NDVI data...")
                        .frame(height: 160)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                } else {
                    ndviChart
                }
            }
            section(title: "7-day Weather Forecast (mm)") {
                if forecast.isEmpty {
                    Text("Loading weather forecast...")
                        .frame(height: 160)
                        .frame(maxWidth: .infinity)
                        .background(Color.cyan.opacity(0.1))
                } else {
                    weatherForecastChart
                }
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

    // MARK: - Chart Components
    private var soilMoistureChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Average: \(String(format: "%.1f", moisture.reduce(0, +) / Double(moisture.count)))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Current: \(String(format: "%.1f", moisture.last ?? 0))%")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            GeometryReader { geometry in
                ZStack {
                    // Background gradient
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Chart line
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let stepX = width / CGFloat(moisture.count - 1)
                        let maxValue = moisture.max() ?? 100
                        let minValue = moisture.min() ?? 0
                        let range = maxValue - minValue
                        
                        for (index, value) in moisture.enumerated() {
                            let x = CGFloat(index) * stepX
                            let y = height - (CGFloat(value - minValue) / CGFloat(range)) * height
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)
                }
            }
            .frame(height: 120)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var temperatureChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("High: \(String(format: "%.1f°C", temps.map { $0.0 }.max() ?? 0))")
                    .font(.caption)
                    .foregroundColor(.red)
                Spacer()
                Text("Low: \(String(format: "%.1f°C", temps.map { $0.1 }.min() ?? 0))")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            GeometryReader { geometry in
                ZStack {
                    // Background gradient
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.red.opacity(0.1), Color.orange.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Temperature range area
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let stepX = width / CGFloat(temps.count - 1)
                        let maxTemp = temps.map { max($0.0, $0.1) }.max() ?? 40
                        let minTemp = temps.map { min($0.0, $0.1) }.min() ?? 0
                        let range = maxTemp - minTemp
                        
                        for (index, temp) in temps.enumerated() {
                            let x = CGFloat(index) * stepX
                            let highY = height - (CGFloat(temp.0 - minTemp) / CGFloat(range)) * height
                            let lowY = height - (CGFloat(temp.1 - minTemp) / CGFloat(range)) * height
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: highY))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: highY))
                            }
                        }
                        
                        for (index, temp) in temps.enumerated().reversed() {
                            let x = CGFloat(temps.count - 1 - index) * stepX
                            let lowY = height - (CGFloat(temp.1 - minTemp) / CGFloat(range)) * height
                            path.addLine(to: CGPoint(x: x, y: lowY))
                        }
                        
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [Color.red.opacity(0.3), Color.orange.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .frame(height: 120)
        }
        .padding()
        .background(Color.red.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var ndviChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Average: \(String(format: "%.3f", ndvi.reduce(0, +) / Double(ndvi.count)))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Current: \(String(format: "%.3f", ndvi.last ?? 0))")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            GeometryReader { geometry in
                ZStack {
                    // Background gradient
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green.opacity(0.1), Color.green.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Chart line
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let stepX = width / CGFloat(ndvi.count - 1)
                        let maxValue = ndvi.max() ?? 1.0
                        let minValue = ndvi.min() ?? 0.0
                        let range = maxValue - minValue
                        
                        for (index, value) in ndvi.enumerated() {
                            let x = CGFloat(index) * stepX
                            let y = height - (CGFloat(value - minValue) / CGFloat(range)) * height
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.green, lineWidth: 2)
                }
            }
            .frame(height: 120)
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var weatherForecastChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Total: \(String(format: "%.1f mm", forecast.reduce(0, +)))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Max: \(String(format: "%.1f mm", forecast.max() ?? 0))")
                    .font(.caption)
                    .foregroundColor(.cyan)
            }
            
            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(forecast.enumerated()), id: \.offset) { index, value in
                        let maxValue = forecast.max() ?? 1.0
                        let height = (CGFloat(value) / CGFloat(maxValue)) * geometry.size.height
                        
                        VStack {
                            Text(String(format: "%.1f", value))
                                .font(.caption2)
                                .foregroundColor(.cyan)
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.cyan, Color.cyan.opacity(0.6)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: max(height, 4))
                                .cornerRadius(2)
                            
                            Text("D\(index + 1)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(height: 120)
        }
        .padding()
        .background(Color.cyan.opacity(0.05))
        .cornerRadius(12)
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


