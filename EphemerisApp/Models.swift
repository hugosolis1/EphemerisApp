import Foundation

enum Planet: String, CaseIterable, Identifiable {
    case sun = "Sun"
    case moon = "Moon"
    case mercury = "Mercury"
    case venus = "Venus"
    case mars = "Mars"
    case jupiter = "Jupiter"
    case saturn = "Saturn"
    case uranus = "Uranus"
    case neptune = "Neptune"
    case pluto = "Pluto"
    case trueNode = "True Node"
    case meanNode = "Mean Node"

    var id: String { rawValue }

    var seBody: Int32 {
        switch self {
        case .sun: return SE_SUN
        case .moon: return SE_MOON
        case .mercury: return SE_MERCURY
        case .venus: return SE_VENUS
        case .mars: return SE_MARS
        case .jupiter: return SE_JUPITER
        case .saturn: return SE_SATURN
        case .uranus: return SE_URANUS
        case .neptune: return SE_NEPTUNE
        case .pluto: return SE_PLUTO
        case .trueNode: return SE_TRUE_NODE
        case .meanNode: return SE_MEAN_NODE
        }
    }
}

enum CalcMode: String, CaseIterable, Identifiable {
    case geocentric = "Geocentric"
    case heliocentric = "Heliocentric"

    var id: String { rawValue }

    var flags: Int32 {
        switch self {
        case .geocentric:
            return SEFLG_SWIEPH | SEFLG_SPEED
        case .heliocentric:
            return SEFLG_SWIEPH | SEFLG_SPEED | SEFLG_HELCTR
        }
    }
}

struct PlanetPosition: Identifiable {
    let id = UUID()
    let planet: Planet
    let longitude: Double
    let latitude: Double
    let distance: Double
    let speed: Double
    let retrograde: Bool

    var degreeString: String {
        String(format: "%.5f°", longitude)
    }
}

struct HousePositions {
    let ascendant: Double
    let descendant: Double
    let midheaven: Double
    let ic: Double

    var ascString: String { String(format: "%.5f°", ascendant) }
    var descString: String { String(format: "%.5f°", descendant) }
    var mcString: String { String(format: "%.5f°", midheaven) }
    var icString: String { String(format: "%.5f°", ic) }
}

struct SearchResult: Identifiable {
    let id = UUID()
    let planet: Planet
    let degree: Double
    let date: Date
    let isRetrograde: Bool

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }
}
