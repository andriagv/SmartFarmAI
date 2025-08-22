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
    
    var description: String {
        switch self {
        case .corn: return "High-yield grain crop for feed and ethanol"
        case .wheat: return "Versatile cereal grain for bread and pasta"
        case .soybeans: return "Protein-rich legume for oil and feed"
        case .rice: return "Staple grain crop for global consumption"
        case .cotton: return "Fiber crop for textiles and clothing"
        }
    }
}


