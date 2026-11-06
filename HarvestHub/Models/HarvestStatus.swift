import Foundation

// A harvest can never be "paid" before it is weighed and priced.
enum HarvestStatus: String, Codable, Hashable {
    case logged, weighed, priced, paid, held
}

func message(for status: HarvestStatus) -> String {
    switch status {
    case .logged:  return "Logged. Waiting for the scale."
    case .weighed: return "Weighed. Waiting for a price."
    case .priced:  return "Priced. Ready to pay."
    case .paid:    return "Paid. The farmer can go home."
    case .held:    return "Held. A crop has no price yet."
    }
}
