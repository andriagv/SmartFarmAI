import SwiftUI

struct MapView: View {
    @StateObject private var vm = FieldSelectionViewModel()
    @State private var navigateToAnalysis = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                MapWebView(viewModel: vm)
                    .ignoresSafeArea(edges: .bottom)
                VStack(spacing: 8) {
                    Button(action: { navigateToAnalysis = true }) {
                        Text("DONE").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .background(.ultraThinMaterial)
            }
            .navigationDestination(isPresented: $navigateToAnalysis) {
                FieldAnalysisView(vm: vm)
            }
        }
        .navigationTitle("Map")
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { MapView() }
    }
}


