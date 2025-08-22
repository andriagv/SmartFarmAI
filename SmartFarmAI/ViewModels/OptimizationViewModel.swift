import Foundation
import SwiftUI
import Combine



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
        sensor.connect()
        showToast(message: "Connecting to \(sensor.type.rawValue) sensor...")
    }
    
    func disconnectSensor(_ sensor: Sensor) {
        sensor.disconnect()
        showToast(message: "\(sensor.type.rawValue) sensor disconnected")
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
                category: "Irrigation",
                title: "Implement Precision Irrigation",
                description: "Based on soil moisture data, implement variable rate irrigation to optimize water usage and improve crop yield by 15-20%.",
                impact: "Improves water use efficiency by 20-30% and crop yield by 15-20%",
                priority: .high,
                estimatedCost: 25000.0,
                estimatedSavings: 45000.0
            ),
            OptimizationRecommendation(
                category: "Fertilization",
                title: "Variable Rate Fertilization",
                description: "Apply site-specific fertilization using sensor data for optimal nutrient distribution and reduced costs.",
                impact: "Reduces fertilizer costs by 15-25% while improving crop response",
                priority: .high,
                estimatedCost: 15000.0,
                estimatedSavings: 30000.0
            ),
            OptimizationRecommendation(
                category: "Soil Management",
                title: "Soil pH Adjustment",
                description: "Apply agricultural lime to raise soil pH to optimal range (6.0-7.0) for better nutrient availability.",
                impact: "Improves nutrient availability and crop yield by 15-25%",
                priority: .medium,
                estimatedCost: 8000.0,
                estimatedSavings: 20000.0
            ),
            OptimizationRecommendation(
                category: "Tillage",
                title: "Deep Tillage Operation",
                description: "Perform deep tillage to improve root penetration and water infiltration in compacted areas.",
                impact: "Improves crop root development and yield potential by 10-15%",
                priority: .medium,
                estimatedCost: 12000.0,
                estimatedSavings: 18000.0
            ),
            OptimizationRecommendation(
                category: "Protection",
                title: "Implement Wind Protection",
                description: "Consider windbreaks or adjust irrigation timing to reduce evaporation and protect young crops.",
                impact: "Reduces water loss and protects young crops",
                priority: .low,
                estimatedCost: 5000.0,
                estimatedSavings: 8000.0
            )
        ]
    }
}


