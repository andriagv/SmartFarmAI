import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var settingsVM: AppSettingsViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 96))
                .foregroundColor(.green)
            Text("Smart Farm AI")
                .font(.largeTitle).bold()
            Text("AI-powered tools for yield planning, pest detection, and resource optimization.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            Spacer()
            Button {
                settingsVM.isFirstLaunch = false
                NotificationService.shared.requestAuthorization()
            } label: {
                Text("Get Started")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView().environmentObject(AppSettingsViewModel())
    }
}


