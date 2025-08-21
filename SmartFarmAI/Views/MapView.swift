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
                .padding(.horizontal, 16)
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
        HStack(spacing: 10) {
            PillButton(title: "Marker", systemImage: "mappin.and.ellipse", isActive: mode == .marker) { mode = .marker }
            PillButton(title: "Clear", systemImage: "xmark.circle", isActive: false) { vm.markers.removeAll(); vm.polygon.removeAll() }
        }
        .padding()
    }

    private var doneBar: some View {
        VStack(spacing: 10) {
            Text("Click to place markers, draw to outline your field")
                .font(.callout.weight(.semibold))
                .padding(8)
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
            Button(action: {
                if vm.markers.count < 1 && vm.polygon.count < 3 {
                    showSelectAlert()
                } else {
                    navigateToAnalysis = true
                }
            }) {
                Text("DONE")
                    .font(.headline)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PressableButtonStyle())
            .background(LinearGradient.farmGreen)
            .foregroundColor(.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(14)
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


