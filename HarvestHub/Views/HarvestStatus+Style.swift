import SwiftUI

extension HarvestStatus {
    var color: Color {
        switch self {
        case .paid:              return .green
        case .priced, .weighed:  return .orange
        case .held:              return .red
        case .logged:            return .gray
        }
    }

    var label: String {
        switch self {
        case .logged:  return "No harvest"
        case .weighed: return "Weighed"
        case .priced:  return "Pending"
        case .paid:    return "Paid"
        case .held:    return "Held"
        }
    }
}
