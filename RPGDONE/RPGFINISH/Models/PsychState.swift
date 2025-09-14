import Foundation

struct PsychState {
    var fear: Double
    var resolve: Double
    var curiosity: Double
    var fatigue: Double
}

struct PsychKnobs {
    var tension: Int
    var weirdness: Int
    var sensoryFocus: String
    var narrativeDevice: String
    var tempoHints: [String]
}

enum PsychStateMapper {
    static func map(_ s: PsychState) -> PsychKnobs {
        let tension = min(5, max(1, Int(round(1 + s.fear * 4))))
        let weird   = min(5, max(1, Int(round(2 + (s.curiosity - s.fatigue) * 2.5))))
        let sensory = s.fatigue > 0.6 ? "auditory" : (s.curiosity > 0.6 ? "olfactory" : "tactile")
        let device  = s.resolve > 0.7 ? "stage directions" :
                      s.fear    > 0.7 ? "prayer" :
                      s.curiosity > 0.7 ? "found log" : "second-person imperative"

        var tempo: [String] = []
        if s.fatigue > 0.6 { tempo.append("shorter sentences, gentle cadence") }
        if s.resolve > 0.6 { tempo.append("decisive verbs, clipped beats") }
        if s.fear > 0.6 { tempo.append("tight sensory tunnel, close distance") }

        return .init(tension: tension, weirdness: weird, sensoryFocus: sensory,
                     narrativeDevice: device, tempoHints: tempo)
    }
}
