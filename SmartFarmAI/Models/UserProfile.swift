import Foundation

struct UserProfile: Codable, Equatable {
    var fullName: String
    var farmName: String
    var avatarPNGData: Data?

    static let `default` = UserProfile(fullName: "Farmer", farmName: "My Farm", avatarPNGData: nil)
}


