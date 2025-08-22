import SwiftUI
import Charts

struct OptimizationView: View {
    @StateObject private var viewModel = OptimizationViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
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
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
        }
        .background(
            LinearGradient.backgroundGradient
                .ignoresSafeArea()
        )
        .overlay(
            // Toast Notification
            VStack {
                if viewModel.showToast {
                    ToastNotification(message: viewModel.toastMessage)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.showToast)
        )
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Smart Farm Optimization")
                        .font(.premiumTitle(28))
                        .foregroundColor(Color.textPrimary)
                    
                    Text("Real-time sensor data analysis and optimization recommendations")
                        .font(.premiumBody(16))
                        .foregroundColor(Color.textSecondary)
                }
                Spacer()
            }
            
            // Quick Stats
            HStack(spacing: 16) {
                PremiumStatCard(
                    title: "Data Points",
                    value: "\(viewModel.sensors.count * 25)",
                    icon: "chart.line.uptrend.xyaxis",
                    color: Color.accentBlue
                )
                
                PremiumStatCard(
                    title: "Efficiency",
                    value: "\(min(95, 70 + viewModel.sensors.count * 5))%",
                    icon: "leaf.fill",
                    color: Color.secondaryGreen
                )
                
                PremiumStatCard(
                    title: "Savings",
                    value: "$\(viewModel.sensors.count * 120)",
                    icon: "dollarsign.circle.fill",
                    color: Color.accentOrange
                )
            }
        }
        .premiumCard(elevation: 6)
    }
    
    // MARK: - Sensor Management Section
    private var sensorManagementSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("🌱 Add Sample Sensor")
                    .font(.premiumHeadline(20))
                    .foregroundColor(Color.textPrimary)
                Spacer()
                Button(action: {
                    viewModel.toggleSensorDropdown()
                }) {
                    Image(systemName: viewModel.showSensorDropdown ? "chevron.up" : "chevron.down")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.backgroundWhite)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                }
            }
            
            Text("Select sensors to collect real-time farm data for optimization analysis.")
                .font(.premiumBody(16))
                .foregroundColor(Color.textSecondary)
            
            // Sensor Dropdown Menu
            if viewModel.showSensorDropdown {
                VStack(spacing: 12) {
                    ForEach(SensorType.allCases, id: \.self) { sensorType in
                        PremiumSensorOption(
                            sensorType: sensorType,
                            onAdd: {
                                viewModel.addSensor(type: sensorType)
                            }
                        )
                    }
                }
                .padding(.top, 8)
            }
        }
        .premiumCard(elevation: 4)
    }
    
    // MARK: - Optimization Engine Section
    private var optimizationEngineSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Optimization Engine")
                .font(.premiumHeadline(20))
                .foregroundColor(Color.textPrimary)
            
            if viewModel.isCalculating {
                VStack(spacing: 16) {
                    HStack {
                        ProgressView(value: viewModel.calculationProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.secondaryGreen))
                        Text("\(Int(viewModel.calculationProgress * 100))%")
                            .font(.premiumCaption(14))
                            .foregroundColor(Color.textSecondary)
                    }
                    
                    Text("Analyzing sensor data and generating recommendations...")
                        .font(.premiumBody(16))
                        .foregroundColor(Color.textSecondary)
                }
            } else {
                VStack(spacing: 12) {
                    Button(action: viewModel.calculateOptimization) {
                        HStack(spacing: 12) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 20, weight: .medium))
                            Text("🧠 Calculate Recommendations")
                                .font(.premiumHeadline(18))
                        }
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient.accentGradient)
                        )
                        .shadow(
                            color: Color.secondaryGreen.opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                    
                    Text("Ready to process \(viewModel.sensors.filter { $0.isConnected }.count) connected sensors")
                        .font(.premiumCaption(14))
                        .foregroundColor(Color.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .premiumCard(elevation: 4)
    }
    
    // MARK: - Recommendations Section
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Optimization Recommendations")
                    .font(.premiumHeadline(20))
                    .foregroundColor(Color.textPrimary)
                Spacer()
                Text("\(viewModel.recommendations.count) recommendations")
                    .font(.premiumCaption(14))
                    .foregroundColor(Color.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.backgroundLight)
                    )
            }
            
            LazyVStack(spacing: 16) {
                ForEach(viewModel.recommendations) { recommendation in
                    PremiumRecommendationCard(recommendation: recommendation)
                }
            }
        }
        .premiumCard(elevation: 4)
    }
    
    // MARK: - Connected Sensors Section
    private var connectedSensorsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Connected Sensors")
                    .font(.premiumHeadline(20))
                    .foregroundColor(Color.textPrimary)
                Spacer()
                Text("\(viewModel.sensors.count) sensors")
                    .font(.premiumCaption(14))
                    .foregroundColor(Color.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.backgroundLight)
                    )
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.sensors) { sensor in
                    PremiumSensorCard(sensor: sensor, viewModel: viewModel)
                }
            }
        }
        .premiumCard(elevation: 4)
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



// MARK: - Premium Components

// MARK: - Premium Stat Card
struct PremiumStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.premiumHeadline(20))
                .foregroundColor(Color.textPrimary)
            
            Text(title)
                .font(.premiumCaption(12))
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.backgroundWhite)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Premium Sensor Option
struct PremiumSensorOption: View {
    let sensorType: SensorType
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text(sensorType.icon)
                .font(.system(size: 20, weight: .medium))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(sensorType.rawValue)
                    .font(.premiumBody(16))
                    .foregroundColor(Color.textPrimary)
                
                Text("Monitor \(sensorType.rawValue.lowercased()) data")
                    .font(.premiumCaption(12))
                    .foregroundColor(Color.textSecondary)
            }
            
            Spacer()
            
            Button(action: onAdd) {
                Text("+ Add")
                    .font(.premiumCaption(14))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.secondaryGreen)
                    )
                    .shadow(color: Color.secondaryGreen.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.backgroundWhite)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

// MARK: - Premium Sensor Card
struct PremiumSensorCard: View {
    let sensor: Sensor
    @ObservedObject var viewModel: OptimizationViewModel
    
    private var statusText: String {
        switch sensor.status {
        case .disconnected:
            return "🔴 Disconnected"
        case .connecting:
            return "🟡 Connecting..."
        case .connected:
            return "🟢 Connected"
        }
    }
    
    private var statusColor: Color {
        switch sensor.status {
        case .disconnected:
            return Color.statusDisconnected
        case .connecting:
            return Color.accentOrange
        case .connected:
            return Color.statusConnected
        }
    }
    
    private var lastUpdateText: String {
        switch sensor.status {
        case .disconnected:
            return "Never"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "2 min ago"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left Side: Icon + Content
            HStack(spacing: 12) {
                // Sensor Icon
                Text(sensor.type.icon)
                    .font(.system(size: 24, weight: .medium))
                
                Text(sensor.name)
                    .foregroundColor(Color.textPrimary)
            }
            
            Spacer()
            
            // Right Side: Status + Buttons
            VStack(alignment: .trailing, spacing: 8) {
                // Status Indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                        .scaleEffect(sensor.status == .connecting ? 1.2 : 1.0)
                        .animation(
                            sensor.status == .connecting ?
                            Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true) :
                            .default,
                            value: sensor.status
                        )
                    
                    Text(sensor.status == .disconnected ? "Disconnected" :
                         sensor.status == .connecting ? "Connecting" : "Connected")
                        .font(.premiumCaption(14))
                        .fontWeight(.medium)
                        .foregroundColor(statusColor)
                }
                
                // Action Buttons
                HStack(spacing: 8) {
                    // Connect/Disconnect Button
                    Button(action: {
                        if sensor.status == .connected {
                            viewModel.disconnectSensor(sensor)
                        } else if sensor.status == .disconnected {
                            viewModel.connectSensor(sensor)
                        }
                        // Do nothing if connecting
                    }) {
                        Text(sensor.status == .connected ? "Disconnect" :
                             sensor.status == .connecting ? "Cancel" : "Connect")
                            .font(.premiumCaption(14))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.white)
                            //.padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .frame(minWidth: 80)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(sensor.status == .connected ? Color.accentOrange : Color.statusConnected)
                            )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(sensor.status == .connecting)
                    
                    // Remove Button
                    Button(action: {
                        viewModel.removeSensor(sensor)
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.white)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.statusWarning)
                            )
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.backgroundWhite)
                .overlay(
                    // Left border accent for connected sensors
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            sensor.status == .connected ? Color.statusConnected.opacity(0.3) : Color.clear,
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Premium Recommendation Card
struct PremiumRecommendationCard: View {
    let recommendation: OptimizationRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(recommendation.title)
                    .font(.premiumHeadline(18))
                    .foregroundColor(Color.textPrimary)
                
                Spacer()
                
                Text(recommendation.priority.rawValue)
                    .font(.premiumCaption(12))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(recommendation.priority.color)
                    )
            }
            
            // Description
            Text(recommendation.description)
                .font(.premiumBody(16))
                .foregroundColor(Color.textSecondary)
                .lineLimit(3)
            
            // Impact
            VStack(alignment: .leading, spacing: 8) {
                Text("Impact:")
                    .font(.premiumCaption(14))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.textPrimary)
                
                Text(recommendation.impact)
                    .font(.premiumCaption(14))
                    .foregroundColor(Color.textSecondary)
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button("View Details") {
                    // TODO: Implement details view
                }
                .premiumButton(.secondary)
                
                Spacer()
                
                Button("Implement") {
                    // TODO: Implement action
                }
                .premiumButton(.primary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.backgroundWhite)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Toast Notification
struct ToastNotification: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color.statusConnected)
                .font(.system(size: 18, weight: .medium))
            
            Text(message)
                .font(.premiumBody(16))
                .foregroundColor(Color.textPrimary)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.backgroundWhite)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

struct OptimizationView_Previews: PreviewProvider {
    static var previews: some View {
        OptimizationView()
    }
}


