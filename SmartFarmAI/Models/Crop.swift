import Foundation

enum Crop: String, CaseIterable, Codable, Hashable {
    case corn
    case wheat
    case soybeans
    case rice
    case cotton

    var displayName: String {
        switch self {
        case .corn: return "Corn"
        case .wheat: return "Wheat"
        case .soybeans: return "Soybeans"
        case .rice: return "Rice"
        case .cotton: return "Cotton"
        }
    }
}


