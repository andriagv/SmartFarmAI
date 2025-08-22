import SwiftUI

struct YieldPredictionView: View {
    @EnvironmentObject private var viewModel: YieldPredictionViewModel
    @State private var showingCropPicker = false
    @State private var showingRegionPicker = false
    @State private var animateForm = false
    @State private var animateResults = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                headerSection
                
                // Main Form Card
                yieldFormCard
                
                // Results Section
                if let prediction = viewModel.predictionResult {
                    resultsSection(prediction)
                }
                
                // Generate Plan Button (always visible if form is valid)
                if viewModel.isFormValid {
                    generatePlanSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(
            LinearGradient.backgroundGradient
                .ignoresSafeArea()
        )
        .onAppear { 
            viewModel.loadMock()
            withAnimation(.easeOut(duration: 0.6)) {
                animateForm = true
            }
        }
        .sheet(isPresented: $showingCropPicker) {
            CropPickerView(selectedCrop: $viewModel.selectedCrop)
        }
        .sheet(isPresented: $showingRegionPicker) {
            RegionPickerView(selectedRegion: $viewModel.selectedRegion, regions: viewModel.regions)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .overlay(
            // Toast Notification
            VStack {
                if viewModel.showPlanGeneratedToast {
                    ToastNotification(message: viewModel.planGeneratedMessage)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.showPlanGeneratedToast)
        )
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("AI-powered yield prediction and farming optimization")
                        .font(.premiumBody(16))
                        .foregroundColor(Color.textSecondary)
                }
                Spacer()
            }
            
            // Quick Stats
            HStack(spacing: 16) {
                PremiumStatCard(
                    title: "Accuracy",
                    value: "94.2%",
                    icon: "target",
                    color: Color.secondaryGreen
                )
                
                PremiumStatCard(
                    title: "Data Points",
                    value: "2.4M",
                    icon: "chart.line.uptrend.xyaxis",
                    color: Color.accentBlue
                )
                
                PremiumStatCard(
                    title: "Savings",
                    value: "$1.2K",
                    icon: "dollarsign.circle.fill",
                    color: Color.accentOrange
                )
            }
        }
        .premiumCard(elevation: 6)
        .opacity(animateForm ? 1 : 0)
        .offset(y: animateForm ? 0 : 20)
    }

    // MARK: - Yield Form Card
    private var yieldFormCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Section Header
            HStack {
                Text("🌱 Farm Inputs")
                    .font(.premiumHeadline(20))
                    .foregroundColor(Color.textPrimary)
                Spacer()
                
                if viewModel.isFormValid {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.secondaryGreen)
                        Text("Ready")
                            .font(.premiumCaption(12))
                            .foregroundColor(Color.secondaryGreen)
                    }
                }
            }
            
            // Input Fields
            VStack(spacing: 20) {
                // Crop Selection
                PremiumInputField(
                    title: "Crop Type",
                    value: viewModel.selectedCrop.displayName,
                    icon: "leaf.fill",
                    color: Color.secondaryGreen
                ) {
                    showingCropPicker = true
                }
                
                // Region Selection
                PremiumInputField(
                    title: "Region",
                    value: viewModel.selectedRegion,
                    icon: "map.fill",
                    color: Color.accentBlue
                ) {
                    showingRegionPicker = true
                }
                
                // Soil Quality
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "drop.circle.fill")
                            .foregroundColor(Color.orange)
                        Text("Soil Quality")
                            .font(.premiumBody(16))
                            .foregroundColor(Color.textPrimary)
                        Spacer()
                        Text("\(viewModel.soilQuality)/5")
                            .font(.premiumBody(16))
                            .foregroundColor(Color.textSecondary)
                    }
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            if viewModel.soilQuality > 1 {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.soilQuality -= 1
                                }
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(viewModel.soilQuality > 1 ? Color.accentOrange : Color.gray.opacity(0.3))
                        }
                        .disabled(viewModel.soilQuality <= 1)
                        
                        // Quality Indicator
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { index in
                                Circle()
                                    .fill(index <= viewModel.soilQuality ? Color.orange : Color.gray.opacity(0.2))
                                    .frame(width: 12, height: 12)
                                    .scaleEffect(index <= viewModel.soilQuality ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.soilQuality)
                            }
                        }
                        
                        Button(action: {
                            if viewModel.soilQuality < 5 {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.soilQuality += 1
                                }
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(viewModel.soilQuality < 5 ? Color.accentOrange : Color.gray.opacity(0.3))
                        }
                        .disabled(viewModel.soilQuality >= 5)
                    }
                }
                
                // Farm Size
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "square.fill")
                            .foregroundColor(Color.purple)
                        Text("Farm Size")
                            .font(.premiumBody(16))
                            .foregroundColor(Color.textPrimary)
                        Spacer()
                        Text("hectares")
                            .font(.premiumCaption(12))
                            .foregroundColor(Color.textSecondary)
                    }
                    
                    HStack {
                        TextField("50", text: $viewModel.farmSizeText)
                            .keyboardType(.decimalPad)
                            .font(.premiumBody(18))
                            .foregroundColor(Color.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.backgroundWhite)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                }
                            }
                        
                        Button(action: {
                            if let current = Double(viewModel.farmSizeText) {
                                viewModel.farmSizeText = String(current + 10)
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.purple)
                        }
                    }
                }
            }
            
            // Error Message
            if let error = viewModel.formErrorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color.red)
                    Text(error)
                        .font(.premiumCaption(14))
                        .foregroundColor(Color.red)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.1))
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            // Predict Button
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    viewModel.predictYield()
                    animateResults = true
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .medium))
                    Text("Predict Yield")
                        .font(.premiumHeadline(18))
                        .fontWeight(.semibold)
                }
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            viewModel.isFormValid ? 
                            LinearGradient.accentGradient : 
                            LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
                        )
                )
                .shadow(
                    color: viewModel.isFormValid ? Color.secondaryGreen.opacity(0.3) : Color.clear,
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(!viewModel.isFormValid)
        }
        .premiumCard(elevation: 4)
        .opacity(animateForm ? 1 : 0)
        .offset(y: animateForm ? 0 : 30)
    }

    // MARK: - Generate Plan Section
    private var generatePlanSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📋 Farm Planning")
                    .font(.premiumHeadline(20))
                    .foregroundColor(Color.textPrimary)
                Spacer()
            }
            
            Button(action: { viewModel.generatePlan() }) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 20, weight: .medium))
                    Text("Generate Farm Plan")
                        .font(.premiumHeadline(18))
                        .fontWeight(.semibold)
                }
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient.accentGradient)
                )
                .shadow(
                    color: Color.accentBlue.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
            .buttonStyle(PressableButtonStyle())
            
            Text("Create a comprehensive farming plan based on your inputs")
                .font(.premiumCaption(14))
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .premiumCard(elevation: 4)
        .opacity(animateForm ? 1 : 0)
        .offset(y: animateForm ? 0 : 30)
    }

    // MARK: - Results Section
    private func resultsSection(_ prediction: YieldPredictionResult) -> some View {
        VStack(spacing: 20) {
            // Prediction Summary
            VStack(spacing: 16) {
                HStack {
                    Text("📊 Prediction Results")
                        .font(.premiumHeadline(20))
                        .foregroundColor(Color.textPrimary)
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("\(String(format: "%.1f", prediction.totalYieldTonnes))")
                            .font(.premiumTitle(28))
                            .foregroundColor(Color.secondaryGreen)
                        Text("Total Yield (tonnes)")
                            .font(.premiumCaption(12))
                            .foregroundColor(Color.textSecondary)
                    }
                    
                    Divider()
                        .frame(height: 40)
                    
                    VStack(spacing: 8) {
                        Text("\(String(format: "%.1f", prediction.totalYieldTonnes / (Double(viewModel.farmSizeText) ?? 1)))")
                            .font(.premiumTitle(28))
                            .foregroundColor(Color.accentBlue)
                        Text("Yield/ha")
                            .font(.premiumCaption(12))
                            .foregroundColor(Color.textSecondary)
                    }
                }
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.backgroundWhite.opacity(0.5))
                )
            }
            .premiumCard(elevation: 4)
            
            // Recommendations
            if !viewModel.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("💡 Recommendations")
                        .font(.premiumHeadline(20))
                        .foregroundColor(Color.textPrimary)
                    
                    VStack(spacing: 12) {
                        ForEach(viewModel.recommendations, id: \.text) { recommendation in
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(recommendation.color)
                                    .frame(width: 8, height: 8)
                                    .padding(.top, 6)
                                
                                Text(recommendation.text)
                                    .font(.premiumBody(14))
                                    .foregroundColor(Color.textPrimary)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .premiumCard(elevation: 4)
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: { viewModel.generatePlan() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                        Text("Generate Plan")
                    }
                    .font(.premiumBody(16))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentBlue)
                    )
                }
                .buttonStyle(PressableButtonStyle())
                
                Button(action: {
                if let url = viewModel.exportCSV() { share(url: url) }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export")
                    }
                    .font(.premiumBody(16))
                    .foregroundColor(Color.accentOrange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentOrange, lineWidth: 1)
                    )
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .opacity(animateResults ? 1 : 0)
        .offset(y: animateResults ? 0 : 30)
    }

    private func share(url: URL) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        root.present(av, animated: true)
    }
}

// MARK: - Premium Input Field
struct PremiumInputField: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.premiumCaption(12))
                        .foregroundColor(Color.textSecondary)
                    Text(value)
                        .font(.premiumBody(16))
                        .foregroundColor(Color.textPrimary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.backgroundWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Crop Picker View
struct CropPickerView: View {
    @Binding var selectedCrop: Crop
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(Crop.allCases, id: \.self) { crop in
                Button(action: {
                    selectedCrop = crop
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(crop.displayName)
                                .font(.premiumBody(16))
                                .foregroundColor(Color.textPrimary)
                            Text(crop.description)
                                .font(.premiumCaption(12))
                                .foregroundColor(Color.textSecondary)
                        }
                        
                        Spacer()
                        
                        if selectedCrop == crop {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.secondaryGreen)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Select Crop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Region Picker View
struct RegionPickerView: View {
    @Binding var selectedRegion: String
    let regions: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(regions, id: \.self) { region in
                Button(action: {
                    selectedRegion = region
                    dismiss()
                }) {
                    HStack {
                        Text(region)
                            .font(.premiumBody(16))
                            .foregroundColor(Color.textPrimary)
                        
                        Spacer()
                        
                        if selectedRegion == region {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.accentBlue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Select Region")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct YieldPredictionView_Previews: PreviewProvider {
    static var previews: some View {
        YieldPredictionView()
            .environmentObject(YieldPredictionViewModel())
    }
}


