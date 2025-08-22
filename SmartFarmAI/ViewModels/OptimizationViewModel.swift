import Foundation
import SwiftUI
import Combine

// MARK: - Basic Sensor Types
enum SensorType: String, CaseIterable, Identifiable {
    case soilPh = "Soil pH"
    case moisture = "Moisture"
    case environmental = "Environmental"
    case optical = "Optical"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .soilPh: return "drop.circle.fill"
        case .moisture: return "humidity"
        case .environmental: return "thermometer"
        case .optical: return "eye.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .soilPh: return .orange
        case .moisture: return .blue
        case .environmental: return .cyan
        case .optical: return .green
        }
    }
}

// MARK: - Connection Status
enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
}

// MARK: - Simple Sensor Model
struct Sensor: Identifiable {
    let id = UUID()
    let type: SensorType
    let name: String
    var status: ConnectionStatus = .disconnected
    var data: [String: Double] = [:]
    
    var isConnected: Bool {
        return status == .connected
    }
}

// MARK: - Basic Types for Simple Implementation
struct OptimizationRecommendation: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let impact: String
    let priority: Priority
    
    enum Priority: String, CaseIterable, Codable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .green
            }
        }
    }
}

@MainActor
final class OptimizationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var sensors: [Sensor] = []
    @Published var isCalculating = false
    @Published var calculationProgress: Double = 0.0
    @Published var recommendations: [OptimizationRecommendation] = []
    @Published var showToast = false
    @Published var toastMessage = ""
    @Published var showSensorDropdown = false
    
    // MARK: - Initialization
    init() {
        // Initialize with empty state
    }
    
    // MARK: - Public Methods
    func toggleSensorDropdown() {
        showSensorDropdown.toggle()
    }
    
    func addSensor(type: SensorType) {
        let sensor = Sensor(type: type, name: "\(type.rawValue) Sensor")
        sensors.append(sensor)
        showToast(message: "Added \(type.rawValue) sensor")
    }
    
    func removeSensor(_ sensor: Sensor) {
        sensors.removeAll { $0.id == sensor.id }
        showToast(message: "Removed \(sensor.type.rawValue) sensor")
    }
    
    func connectSensor(_ sensor: Sensor) {
        guard let index = sensors.firstIndex(where: { $0.id == sensor.id }) else { return }
        sensors[index].status = .connecting
        showToast(message: "Connecting to \(sensor.type.rawValue) sensor...")
        
        // Simulate connection delay
        Task {
            try await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 seconds
            await MainActor.run {
                if index < sensors.count {
                    sensors[index].status = .connected
                    sensors[index].data = generateSampleData(for: sensor.type)
                    showToast(message: "\(sensor.type.rawValue) sensor connected")
                }
            }
        }
    }
    
    func disconnectSensor(_ sensor: Sensor) {
        guard let index = sensors.firstIndex(where: { $0.id == sensor.id }) else { return }
        sensors[index].status = .disconnected
        sensors[index].data = [:]
        showToast(message: "\(sensor.type.rawValue) sensor disconnected")
    }
    
    private func generateSampleData(for type: SensorType) -> [String: Double] {
        switch type {
        case .soilPh:
            return ["pH": Double.random(in: 5.5...7.5)]
        case .moisture:
            return ["Moisture": Double.random(in: 25...75)]
        case .environmental:
            return [
                "Temperature": Double.random(in: 15...35),
                "Humidity": Double.random(in: 40...85)
            ]
        case .optical:
            return [
                "NDVI": Double.random(in: 0.3...0.8),
                "Plant Health": Double.random(in: 60...95)
            ]
        }
    }
    
    private func showToast(message: String) {
        toastMessage = message
        showToast = true
        
        // Hide toast after 3 seconds
        Task {
            try await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run {
                showToast = false
            }
        }
    }
    
    func calculateOptimization() {
        isCalculating = true
        calculationProgress = 0.0
        
        // Simulate calculation progress
        Task {
            for i in 1...50 {
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                await MainActor.run {
                    calculationProgress = Double(i) / 50.0
                }
            }
            
            await MainActor.run {
                generateRecommendations()
                isCalculating = false
            }
        }
    }
    
    // MARK: - Private Methods
    private func generateRecommendations() {
        recommendations = [
            OptimizationRecommendation(
                title: "Implement Precision Irrigation",
                description: "Based on soil moisture data, implement variable rate irrigation to optimize water usage and improve crop yield by 15-20%.",
                impact: "Improves water use efficiency by 20-30% and crop yield by 15-20%",
                priority: .high
            ),
            OptimizationRecommendation(
                title: "Variable Rate Fertilization",
                description: "Apply site-specific fertilization using sensor data for optimal nutrient distribution and reduced costs.",
                impact: "Reduces fertilizer costs by 15-25% while improving crop response",
                priority: .high
            ),
            OptimizationRecommendation(
                title: "Soil pH Adjustment",
                description: "Apply agricultural lime to raise soil pH to optimal range (6.0-7.0) for better nutrient availability.",
                impact: "Improves nutrient availability and crop yield by 15-25%",
                priority: .medium
            ),
            OptimizationRecommendation(
                title: "Deep Tillage Operation",
                description: "Perform deep tillage to improve root penetration and water infiltration in compacted areas.",
                impact: "Improves crop root development and yield potential by 10-15%",
                priority: .medium
            ),
            OptimizationRecommendation(
                title: "Implement Wind Protection",
                description: "Consider windbreaks or adjust irrigation timing to reduce evaporation and protect young crops.",
                impact: "Reduces water loss and protects young crops",
                priority: .low
            )
        ]
    }
}


