import Foundation
import SwiftUI

// MARK: - Sensor Types
enum SensorType: String, CaseIterable, Identifiable {
    case soilPh = "Soil pH"
    case optical = "Optical"
    case electrochemical = "Electrochemical"
    case mechanical = "Mechanical"
    case airFlow = "Air Flow"
    case environmental = "Environmental"
    case moisture = "Moisture"
    case weather = "Weather"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .soilPh: return "drop.circle.fill"
        case .optical: return "eye.fill"
        case .electrochemical: return "bolt.circle.fill"
        case .mechanical: return "gauge"
        case .airFlow: return "wind"
        case .environmental: return "thermometer"
        case .moisture: return "humidity"
        case .weather: return "cloud.sun.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .soilPh: return .orange
        case .optical: return .green
        case .electrochemical: return .purple
        case .mechanical: return .brown
        case .airFlow: return .blue
        case .environmental: return .cyan
        case .moisture: return .blue
        case .weather: return .yellow
        }
    }
    
    var description: String {
        switch self {
        case .soilPh: return "Measures soil acidity/alkalinity levels"
        case .optical: return "Monitors plant health via NDVI, light intensity, canopy density"
        case .electrochemical: return "Detects nutrient concentrations (nitrates, phosphates, ion levels)"
        case .mechanical: return "Measures soil compaction and resistance"
        case .airFlow: return "Monitors soil aeration and air movement"
        case .environmental: return "Tracks temperature, humidity, light intensity, CO2 levels"
        case .moisture: return "Soil and air humidity monitoring"
        case .weather: return "Wind speed, precipitation, atmospheric pressure"
        }
    }
}

// MARK: - Connection Status
enum ConnectionStatus: String, CaseIterable {
    case disconnected = "Disconnected"
    case searching = "Searching..."
    case pairing = "Pairing..."
    case connected = "Connected"
    
    var color: Color {
        switch self {
        case .disconnected: return .red
        case .searching: return .orange
        case .pairing: return .yellow
        case .connected: return .green
        }
    }
    
    var icon: String {
        switch self {
        case .disconnected: return "wifi.slash"
        case .searching: return "wifi"
        case .pairing: return "wifi"
        case .connected: return "wifi"
        }
    }
}

// MARK: - Sensor Data
struct SensorData: Identifiable, Codable {
    let id = UUID()
    let sensorType: SensorType
    let timestamp: Date
    let values: [String: Double]
    let unit: String
    
    static func generateRandomData(for sensorType: SensorType) -> SensorData {
        let values: [String: Double]
        let unit: String
        
        switch sensorType {
        case .soilPh:
            values = ["pH": Double.random(in: 4.5...8.5)]
            unit = "pH"
        case .optical:
            values = [
                "NDVI": Double.random(in: 0.1...0.9),
                "Plant Health": Double.random(in: 60...95),
                "Light Intensity": Double.random(in: 20000...120000)
            ]
            unit = "NDVI/Lux"
        case .electrochemical:
            values = [
                "Nitrogen": Double.random(in: 15...45),
                "Phosphorus": Double.random(in: 8...25),
                "Potassium": Double.random(in: 12...35)
            ]
            unit = "mg/kg"
        case .mechanical:
            values = [
                "Compaction": Double.random(in: 100...800),
                "Resistance": Double.random(in: 0.5...3.0)
            ]
            unit = "kPa"
        case .airFlow:
            values = [
                "Air Permeability": Double.random(in: 0.1...2.5),
                "Oxygen Level": Double.random(in: 15...21)
            ]
            unit = "cm/s"
        case .environmental:
            values = [
                "Temperature": Double.random(in: 15...35),
                "Humidity": Double.random(in: 40...85),
                "CO2": Double.random(in: 350...450),
                "Light": Double.random(in: 50000...100000)
            ]
            unit = "°C/%/ppm"
        case .moisture:
            values = [
                "Soil Moisture": Double.random(in: 25...75),
                "Air Humidity": Double.random(in: 45...90)
            ]
            unit = "%"
        case .weather:
            values = [
                "Wind Speed": Double.random(in: 0...25),
                "Precipitation": Double.random(in: 0...15),
                "Pressure": Double.random(in: 980...1020)
            ]
            unit = "m/s/mm/hPa"
        }
        
        return SensorData(sensorType: sensorType, timestamp: Date(), values: values, unit: unit)
    }
}

// MARK: - Sensor Instance
class Sensor: Identifiable, ObservableObject {
    let id = UUID()
    let type: SensorType
    let name: String
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var data: SensorData?
    @Published var isConnected: Bool = false
    
    init(type: SensorType, name: String) {
        self.type = type
        self.name = name
    }
    
    func connect() {
        connectionStatus = .searching
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.connectionStatus = .pairing
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.connectionStatus = .connected
            self.isConnected = true
            self.startDataGeneration()
        }
    }
    
    func disconnect() {
        connectionStatus = .disconnected
        isConnected = false
        data = nil
    }
    
    private func startDataGeneration() {
        // Generate initial data
        data = SensorData.generateRandomData(for: type)
        
        // Update data every 30 seconds
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            if self.isConnected {
                self.data = SensorData.generateRandomData(for: self.type)
            }
        }
    }
}

// MARK: - Optimization Recommendation
struct OptimizationRecommendation: Identifiable, Codable {
    let id = UUID()
    let category: String
    let title: String
    let description: String
    let impact: String
    let priority: Priority
    let estimatedCost: Double
    let estimatedSavings: Double
    
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
