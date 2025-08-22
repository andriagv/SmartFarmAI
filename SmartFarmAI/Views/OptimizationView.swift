import SwiftUI
import Charts

struct OptimizationView: View {
    @StateObject private var viewModel = OptimizationViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    headerSection
                    
                    // Sensor Management
                    sensorManagementSection
                    
                    // Connected Sensors Display
                    if !viewModel.sensors.isEmpty {
                        connectedSensorsSection
                    }
                    
                    // Optimization Engine
                    optimizationEngineSection
                    
                    // Recommendations
                    if !viewModel.recommendations.isEmpty {
                        recommendationsSection
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.3, blue: 0.1),
                        Color(red: 0.2, green: 0.4, blue: 0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Farm Optimization")
            .navigationBarTitleDisplayMode(.large)
            .overlay(
                // Toast Notification
                VStack {
                    if viewModel.showToast {
                        toastView
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    Spacer()
                }
                .animation(.spring(), value: viewModel.showToast)
            )
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Smart Farm Optimization")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Real-time sensor data analysis and optimization recommendations")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
            }
            
            // Quick Stats
            HStack(spacing: 16) {
                StatCard(
                    title: "Data Points",
                    value: "150",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
                
                StatCard(
                    title: "Efficiency",
                    value: "92%",
                    icon: "leaf.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Savings",
                    value: "$450",
                    icon: "dollarsign.circle.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Sensor Management Section
    private var sensorManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sensor Management")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Add sensors to collect real-time farm data for optimization analysis.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Button("Add Sample Sensors") {
                viewModel.addSampleSensors()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Optimization Engine Section
    private var optimizationEngineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Optimization Engine")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if viewModel.isCalculating {
                VStack(spacing: 16) {
                    ProgressView(value: viewModel.calculationProgress) {
                        Text("Analyzing sensor data...")
                            .foregroundColor(.white)
                    }
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    
                    Text("\(Int(viewModel.calculationProgress * 100))% Complete")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            } else {
                Button(action: viewModel.calculateOptimization) {
                    HStack(spacing: 12) {
                        Image(systemName: "brain.head.profile")
                            .font(.title2)
                        Text("Calculate Recommendations")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Recommendations Section
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Optimization Recommendations")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            ForEach(viewModel.recommendations) { recommendation in
                SimpleRecommendationCard(recommendation: recommendation)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Connected Sensors Section
    private var connectedSensorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Connected Sensors")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(viewModel.sensors) { sensor in
                    SensorCard(sensor: sensor)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Toast View
    private var toastView: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(viewModel.toastMessage)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.green.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .padding(.top, 60)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct SimpleRecommendationCard: View {
    let recommendation: OptimizationRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(recommendation.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(recommendation.priority.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(recommendation.priority.color)
                    )
            }
            
            Text(recommendation.description)
                .font(.body)
                .foregroundColor(.primary)
            
            Text("Impact: \(recommendation.impact)")
                .font(.caption)
                .foregroundColor(.green)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(recommendation.priority.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct SensorCard: View {
    let sensor: Sensor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: sensor.type.icon)
                    .font(.title2)
                    .foregroundColor(sensor.type.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(sensor.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(sensor.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Connection Status Indicator
                Circle()
                    .fill(sensor.isConnected ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            
            if sensor.isConnected {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Status: Connected")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    if !sensor.data.isEmpty {
                        ForEach(Array(sensor.data.keys.sorted()), id: \.self) { key in
                            HStack {
                                Text(key)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text(String(format: "%.1f", sensor.data[key] ?? 0))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            } else {
                Text("Disconnected")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(sensor.type.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct OptimizationView_Previews: PreviewProvider {
    static var previews: some View {
        OptimizationView()
    }
}


