import SwiftUI

struct PestDetectionView: View {
    @EnvironmentObject private var viewModel: PestDetectionViewModel
    @State private var showCamera = false
    @State private var searchText: String = ""
    @State private var selectedResult: PestAnalysisResult? = nil

    var body: some View {
        VStack(spacing: 12) {
            ScrollView {
                VStack(spacing: 16) {
                    Button {
                        switch CameraService.shared.authorizationStatus() {
                        case .authorized: showCamera = true
                        case .notDetermined:
                            CameraService.shared.requestAccess { granted in if granted { showCamera = true } }
                        default: break
                        }
                    } label: {
                        Label("Scan Plant", systemImage: "camera.viewfinder")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    if viewModel.isAnalyzing {
                        ProgressView("Analyzing...")
                    }

                    if let result = viewModel.lastResult {
                        resultCard(result)
                    }

                    historySection
                }
                .padding()
            }
        }
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
        .onAppear { viewModel.loadHistory() }
    }

    private func resultCard(_ result: PestAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(result.diseaseName)
                .font(.headline)
            Text("Confidence: \(Int(result.confidence * 100))% • Severity: \(result.severity.rawValue.capitalized)")
                .foregroundColor(.secondary)
            Text(result.recommendation)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent Scans").font(.headline)
                Spacer()
                Menu {
                    Picker("Severity", selection: $viewModel.filterSeverity) {
                        Text("All").tag(PestSeverity?.none)
                        ForEach(PestSeverity.allCases, id: \.self) { sev in
                            Text(sev.rawValue.capitalized).tag(PestSeverity?.some(sev))
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
            TextField("Search disease name", text: $searchText)
                .textFieldStyle(.roundedBorder)
            ForEach(viewModel.filteredHistory.filter { searchText.isEmpty ? true : $0.diseaseName.localizedCaseInsensitiveContains(searchText) }) { item in
                HStack {
                    Image(systemName: item.severity.iconName)
                        .foregroundColor(item.severity.color)
                    VStack(alignment: .leading) {
                        Text(item.diseaseName)
                        Text(item.date.formatted()).font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(Int(item.confidence * 100))%")
                }
                .padding(8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .onTapGesture { selectedResult = item }
            }
        }
    }
}

struct PestDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        PestDetectionView()
            .environmentObject(PestDetectionViewModel())
    }
}


