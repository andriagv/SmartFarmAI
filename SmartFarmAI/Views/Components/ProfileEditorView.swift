import SwiftUI

struct ProfileEditorView: View {
    @Binding var profile: UserProfile
    @State private var fullName: String = ""
    @State private var farmName: String = ""

    var body: some View {
        Form {
            Section(header: Text("User")) {
                TextField("Full name", text: $fullName)
                TextField("Farm name", text: $farmName)
            }
            Section {
                Button("Save") {
                    profile.fullName = fullName
                    profile.farmName = farmName
                }
            }
        }
        .onAppear {
            fullName = profile.fullName
            farmName = profile.farmName
        }
        .navigationTitle("Edit Profile")
    }
}


