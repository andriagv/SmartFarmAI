import SwiftUI

struct MapView: View {
    @StateObject private var vm = FieldSelectionViewModel()
    @State private var navigateToAnalysis = false
    @State private var mode: DrawingMode = .marker
    @StateObject private var loc = LocationService.shared

    var body: some View {
        VStack(spacing: 0) {
            MapKitView(viewModel: vm, mode: mode)
                .ignoresSafeArea(edges: .bottom)
                .overlay(alignment: .topLeading) { tools }
                .overlay(alignment: .bottom) { doneBar }
            NavigationLink(destination: FieldAnalysisView(vm: vm), isActive: $navigateToAnalysis) { EmptyView() }
        }
        .navigationTitle("Map")
        .onAppear {
            loc.requestWhenInUse()
        }
        .onReceive(loc.$lastLocation) { loc in
            if let loc = loc { vm.mapCenter = loc.coordinate; vm.userLocation = loc.coordinate }
        }
    }

    private var tools: some View {
        HStack(spacing: 8) {
            Button("Marker") { mode = .marker }
            Button("Polygon") { mode = .polygon }
            Button("Rectangle") { mode = .rectangle }
            Button("Clear") { vm.markers.removeAll(); vm.polygon.removeAll() }
        }
        .padding(8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .padding()
    }

    private var doneBar: some View {
        VStack(spacing: 6) {
            Text("Click to place markers, draw to outline your field").font(.footnote).foregroundColor(.secondary)
            Button(action: { navigateToAnalysis = true }) {
                Text("DONE").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { MapView() }
    }
}


