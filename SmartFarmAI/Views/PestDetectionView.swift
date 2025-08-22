import SwiftUI

struct PestDetectionView: View {
    @EnvironmentObject private var viewModel: PestDetectionViewModel
    @State private var showCamera = false
    @State private var searchText: String = ""
    @State private var selectedResult: PestAnalysisResult? = nil
    @State private var animateHeader = false
    @State private var animateScanButton = false
    @State private var animateHistory = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                headerSection
                
                // Scan Button Section
                scanButtonSection
                
                // Analysis Progress
                if viewModel.isAnalyzing {
                    analysisProgressSection
                }
                
                // Last Result
                if let result = viewModel.lastResult {
                    lastResultSection(result)
                }
                
                // History Section
                historySection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(
            LinearGradient.backgroundGradient
                .ignoresSafeArea()
        )
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                if let image = image {
                    viewModel.analyze(image: image)
                }
            }
        }
        .sheet(item: $selectedResult) { item in
            PestResultDetailView(result: item)
        }
        .onAppear { 
            viewModel.loadHistory()
            withAnimation(.easeOut(duration: 0.6)) {
                animateHeader = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateScanButton = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
                animateHistory = true
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("AI-powered plant health monitoring and disease detection")
                        .font(.premiumBody(16))
                        .foregroundColor(Color.textSecondary)
                }
                Spacer()
            }
            
            // Quick Stats
            HStack(spacing: 16) {
                PremiumStatCard(
                    title: "Accuracy",
                    value: "96.8%",
                    icon: "target",
                    color: Color.secondaryGreen
                )
                
                PremiumStatCard(
                    title: "Scans",
                    value: "\(viewModel.history.count)",
                    icon: "camera.viewfinder",
                    color: Color.accentBlue
                )
                
                PremiumStatCard(
                    title: "Detected",
                    value: "\(viewModel.history.filter { $0.severity != .mild }.count)",
                    icon: "exclamationmark.triangle.fill",
                    color: Color.accentOrange
                )
            }
        }
        .premiumCard(elevation: 6)
        .opacity(animateHeader ? 1 : 0)
        .offset(y: animateHeader ? 0 : 20)
    }

    // MARK: - Scan Button Section
    private var scanButtonSection: some View {
        VStack(spacing: 16) {
            Button {
                switch CameraService.shared.authorizationStatus() {
                case .authorized: showCamera = true
                case .notDetermined:
                    CameraService.shared.requestAccess { granted in 
                        if granted { showCamera = true } 
                    }
                default: break
                }
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 24, weight: .medium))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Scan Plant")
                            .font(.premiumHeadline(20))
                            .fontWeight(.semibold)
                        Text("Detect diseases and pests instantly")
                            .font(.premiumCaption(14))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(Color.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient.accentGradient)
                )
                .shadow(
                    color: Color.secondaryGreen.opacity(0.3),
                    radius: 12,
                    x: 0,
                    y: 6
                )
            }
            .buttonStyle(PressableButtonStyle())
            
            // Quick Tips
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color.accentOrange)
                Text("Tip: Ensure good lighting and focus on affected areas for best results")
                    .font(.premiumCaption(12))
                    .foregroundColor(Color.textSecondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentOrange.opacity(0.1))
            )
        }
        .premiumCard(elevation: 4)
        .opacity(animateScanButton ? 1 : 0)
        .offset(y: animateScanButton ? 0 : 30)
    }

    // MARK: - Analysis Progress Section
    private var analysisProgressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🔍 Analyzing Plant")
                    .font(.premiumHeadline(20))
                    .foregroundColor(Color.textPrimary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.secondaryGreen))
                        .scaleEffect(1.2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Processing image...")
                            .font(.premiumBody(16))
                            .foregroundColor(Color.textPrimary)
                        Text("AI is analyzing plant health")
                            .font(.premiumCaption(12))
                            .foregroundColor(Color.textSecondary)
                    }
                    Spacer()
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.secondaryGreen)
                            .frame(width: 8, height: 8)
                        Text("Image processing")
                            .font(.premiumCaption(12))
                            .foregroundColor(Color.textSecondary)
                    }
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.accentBlue)
                            .frame(width: 8, height: 8)
                        Text("Disease detection")
                            .font(.premiumCaption(12))
                            .foregroundColor(Color.textSecondary)
                    }
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.accentOrange)
                            .frame(width: 8, height: 8)
                        Text("Treatment recommendations")
                            .font(.premiumCaption(12))
                            .foregroundColor(Color.textSecondary)
                    }
                }
            }
        }
        .premiumCard(elevation: 4)
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Last Result Section
    private func lastResultSection(_ result: PestAnalysisResult) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("📊 Latest Detection")
                    .font(.premiumHeadline(20))
                    .foregroundColor(Color.textPrimary)
                Spacer()
                Button("View Details") {
                    selectedResult = result
                }
                .font(.premiumCaption(14))
                .foregroundColor(Color.accentBlue)
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // Severity Icon
                    Image(systemName: result.severity.iconName)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(result.severity.color)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(result.severity.color.opacity(0.1))
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(result.diseaseName)
                            .font(.premiumHeadline(18))
                            .foregroundColor(Color.textPrimary)
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Confidence")
                                    .font(.premiumCaption(12))
                                    .foregroundColor(Color.textSecondary)
                                Text("\(Int(result.confidence * 100))%")
                                    .font(.premiumBody(16))
                                    .foregroundColor(Color.textPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Severity")
                                    .font(.premiumCaption(12))
                                    .foregroundColor(Color.textSecondary)
                                Text(result.severity.rawValue.capitalized)
                                    .font(.premiumBody(16))
                                    .foregroundColor(result.severity.color)
                            }
                        }
                    }
                    Spacer()
                }
                
                Divider()
                
                Text(result.recommendation)
                    .font(.premiumBody(14))
                    .foregroundColor(Color.textPrimary)
                    .multilineTextAlignment(.leading)
                
                // Done Button
                HStack {
                    Spacer()
                    Button("Done") {
                        viewModel.dismissLastResult()
                    }
                    .font(.premiumBody(16))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient.accentGradient)
                    )
                    .shadow(
                        color: Color.accentBlue.opacity(0.3),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
                }
            }
        }
        .premiumCard(elevation: 4)
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - History Section
    private var historySection: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Text("📋 Recent Scans")
                    .font(.premiumHeadline(20))
                    .foregroundColor(Color.textPrimary)
                Spacer()
                
                Menu {
                    Picker("Severity", selection: $viewModel.filterSeverity) {
                        Text("All Severities").tag(PestSeverity?.none)
                        ForEach(PestSeverity.allCases, id: \.self) { sev in
                            Text(sev.rawValue.capitalized).tag(PestSeverity?.some(sev))
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 18, weight: .medium))
                        Text("Filter")
                            .font(.premiumCaption(14))
                    }
                    .foregroundColor(Color.accentBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.accentBlue, lineWidth: 1)
                    )
                }
            }
            
            // Search Bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.textSecondary)
                TextField("Search disease name", text: $searchText)
                    .font(.premiumBody(16))
                    .foregroundColor(Color.textPrimary)
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
            
            // History List
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredHistory.filter { 
                    searchText.isEmpty ? true : $0.diseaseName.localizedCaseInsensitiveContains(searchText) 
                }) { item in
                    historyItem(item)
                }
            }
        }
        .premiumCard(elevation: 4)
        .opacity(animateHistory ? 1 : 0)
        .offset(y: animateHistory ? 0 : 30)
    }

    // MARK: - History Item
    private func historyItem(_ item: PestAnalysisResult) -> some View {
        Button(action: { selectedResult = item }) {
            HStack(spacing: 16) {
                // Severity Icon
                Image(systemName: item.severity.iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(item.severity.color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(item.severity.color.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.diseaseName)
                        .font(.premiumBody(16))
                        .foregroundColor(Color.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(item.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.premiumCaption(12))
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(item.confidence * 100))%")
                        .font(.premiumBody(16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.textPrimary)
                    
                    Text("Confidence")
                        .font(.premiumCaption(10))
                        .foregroundColor(Color.textSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.backgroundWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PestDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        PestDetectionView()
            .environmentObject(PestDetectionViewModel())
    }
}


