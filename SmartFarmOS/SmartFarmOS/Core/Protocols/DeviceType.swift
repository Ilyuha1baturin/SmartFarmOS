import Foundation

/// Типы фермерских устройств
public enum DeviceType: String, Codable, CaseIterable, Identifiable {
    case brooder, beehive, calfhouse, birdcage
    
    public var id: String { self.rawValue }
    
    public var localizedName: String {
        switch self {
        case .brooder: return "Брудер"
        case .beehive: return "Улей"
        case .calfhouse: return "Домик для телят"
        case .birdcage: return "Вольер (CV)"
        }
    }
    
    public var systemImage: String {
        switch self {
        case .brooder: return "thermometer.sun.fill"
        case .beehive: return "hexagon.3.fill"
        case .calfhouse: return "house.lodge.fill"
        case .birdcage: return "eye.fill"
        }
    }
}
