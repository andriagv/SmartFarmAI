import SwiftUI

struct MapView: View {
    @StateObject private var vm = FieldSelectionViewModel()
    @State private var navigateToAnalysis = false
    @State private var mode: DrawingMode = .marker
    @StateObject private var loc = LocationService.shared

    var body: some View {
        ZStack(alignment: .topLeading) {
            MapKitView(viewModel: vm, mode: mode)
                .ignoresSafeArea()
            tools
                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
            NavigationLink(destination: FieldAnalysisView(vm: vm), isActive: $navigateToAnalysis) { EmptyView() }
        }
        .overlay(alignment: .bottom) {
            doneBar
                .padding(.bottom, 80)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
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
            Button(action: {
                if vm.markers.count < 1 && vm.polygon.count < 3 {
                    showSelectAlert()
                } else {
                    navigateToAnalysis = true
                }
            }) {
                Text("DONE").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(14)
        .shadow(radius: 2)
    }

    private func showSelectAlert() {
        let alert = UIAlertController(title: nil, message: "მონიშნე მიწის ნაკვეთი", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.keyWindow?.rootViewController?
            .present(alert, animated: true)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { MapView() }
    }
}


