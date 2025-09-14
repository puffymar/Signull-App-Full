import Foundation

public enum Journey: String, CaseIterable, Identifiable {
    case scp, postApoc, sciFi, isekai, fantasy, crime
    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .scp: return "SCP Foundation"
        case .postApoc: return "Post-Apocalyptic"
        case .sciFi: return "Sci-Fi"
        case .isekai: return "Isekai"
        case .fantasy: return "Fantasy"
        case .crime: return "Crime"
        }
    }

    public var seed: String {
        switch self {
        case .scp: return "SCP Site; dome cameras; negative-pressure labs; blast doors; Level-2 badge; intercom"
        case .postApoc: return "abandoned overpass; ration lines; quarantine checkpoints; blackouts; radio chatter"
        case .sciFi: return "orbital docks; hab-rings; EVA suits; cold starlight; illegal AI cores"
        case .isekai: return "summoned into alien court; runes; pact-creatures; unfamiliar sky"
        case .fantasy: return "storm-lit keep; oathbound blade; sigils; magefire; hooded envoy"
        case .crime: return "city alley stakeout; burner phones; drop sites; wiretap hum; getaway routes"
        }
    }

    public var openingBrief: String {
        switch self {
        case .scp: return "SCP Site blackout; Level-2 badge; gleaming dome cameras top-left; Dr Reed on intercom"
        case .postApoc: return "Evacuated district; cracked sirens; curfew patrols; scarce water"
        case .sciFi: return "Docking bay breach; contraband AI; station lockdown"
        case .isekai: return "Waking in a sigil circle; court expects a champion; wrong name"
        case .fantasy: return "Courtyard under storm; emissary missing; wards strain"
        case .crime: return "Night stakeout; cash drop; target late; unmarked sedan loops the block"
        }
    }

    public var openingContext: String {
        switch self {
        case .scp: return "corridor C-7, negative pressure, coolant haze, card reader glow"
        case .postApoc: return "floodlit checkpoints, ash smell, boarded pharmacies, battery radios"
        case .sciFi: return "hull frost, mag-boots, airlock warnings, customs drones"
        case .isekai: return "chalk sigils, braziers, horned steward, oath script"
        case .fantasy: return "wet flagstones, lamplight, castle wardens, scent of ozone"
        case .crime: return "wet asphalt, sodium lamps, scanner app, police bands"
        }
    }

    public var tags: [String] {
        switch self {
        case .scp: return ["scp","containment","lab"]
        case .postApoc: return ["survival","quarantine","ruins"]
        case .sciFi: return ["orbital","ai","smuggling"]
        case .isekai: return ["portal","court","runes"]
        case .fantasy: return ["magic","oath","castle"]
        case .crime: return ["heist","stakeout","wiretap"]
        }
    }
}


