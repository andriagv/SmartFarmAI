import SwiftUI

struct MapView: View {
    @StateObject private var vm = FieldSelectionViewModel()
    @State private var navigateToAnalysis = false
    @State private var mode: DrawingMode = .marker
    @StateObject private var loc = LocationService.shared

    var body: some View {
        ZStack {
            MapKitView(viewModel: vm, mode: mode)
                .ignoresSafeArea()
            
            // Top-left corner: Marker button
            VStack {
                HStack {
                    PillButton(title: "Marker", systemImage: "mappin.and.ellipse", isActive: mode == .marker) { mode = .marker }
                    Spacer()
                }
                Spacer()
            }
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
            .padding(.leading, 16)
            .ignoresSafeArea()
            
            // Top-right corner: Clear and Location buttons
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        PillButton(title: "Clear", systemImage: "xmark.circle", isActive: false) { vm.markers.removeAll(); vm.polygon.removeAll() }
                        // PillButton(title: "My Location", systemImage: "location.fill", isActive: false) {
                        //     if let userLoc = vm.userLocation {
                        //         vm.mapCenter = userLoc
                        //     }
                        // }
                    }
                }
                Spacer()
            }
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
            .padding(.trailing, 16)
            .ignoresSafeArea()
            
            NavigationLink(destination: FieldAnalysisView(vm: vm), isActive: $navigateToAnalysis) { EmptyView() }
        }
        .overlay(alignment: .bottom) {
            doneBar
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if vm.mapCenter == nil {
                loc.requestWhenInUse()
            }
        }
        .onReceive(loc.$lastLocation) { location in
            if let location = location, vm.mapCenter == nil {
                vm.mapCenter = location.coordinate
                vm.userLocation = location.coordinate
            }
        }
    }



    private var doneBar: some View {
        VStack(spacing: 10) {
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


