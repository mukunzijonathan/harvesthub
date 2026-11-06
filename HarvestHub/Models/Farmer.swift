import Foundation
import FirebaseFirestore

struct Harvest: Identifiable, Codable, Hashable {
    var id = UUID().uuidString
    var kilos: Int
    var crop: String
    var date: Date
}

// One Firestore document in the "farmers" collection, harvests included.
struct Farmer: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var ownerID: String?
    var name: String
    var crop: String
    var seasonsWithCoop: Int
    var status: HarvestStatus = .logged
    var harvests: [Harvest] = []

    var totalKilos: Int {
        harvests.map { $0.kilos }.reduce(0, +)
    }

    // nil when any harvest is a crop we cannot price yet: never guess with people's money.
    var amountDue: Int? {
        var total = 0
        for harvest in harvests {
            guard let price = priceFor(crop: harvest.crop) else { return nil }
            total += payout(kilos: harvest.kilos, pricePerKg: price)
        }
        return total + loyaltyBonus(seasonsWithCoop: seasonsWithCoop)
    }

    func summary() -> String {
        return "\(name) · \(crop) · \(totalKilos) kg"
    }

    mutating func recordHarvest(kilos: Int, crop: String, date: Date = .now) {
        harvests.append(Harvest(kilos: kilos, crop: crop, date: date))
        self.crop = crop
        status = amountDue == nil ? .held : .priced
    }

    mutating func markPaid() {
        guard status == .priced else { return }
        status = .paid
    }
}

extension Farmer {
    static func samples(ownerID: String?) -> [Farmer] {
        let day: TimeInterval = 86_400

        var jeanne = Farmer(ownerID: ownerID, name: "Uwase Jeanne", crop: "Maize", seasonsWithCoop: 4)
        jeanne.recordHarvest(kilos: 200, crop: "Maize", date: .now.addingTimeInterval(-day * 12))
        jeanne.recordHarvest(kilos: 140, crop: "Maize", date: .now.addingTimeInterval(-day * 3))
        jeanne.markPaid()

        var habimana = Farmer(ownerID: ownerID, name: "Habimana P.", crop: "Beans", seasonsWithCoop: 1)
        habimana.recordHarvest(kilos: 180, crop: "Beans", date: .now.addingTimeInterval(-day * 5))
        habimana.markPaid()

        var mukamana = Farmer(ownerID: ownerID, name: "Mukamana A.", crop: "Coffee", seasonsWithCoop: 2)
        mukamana.recordHarvest(kilos: 90, crop: "Coffee", date: .now.addingTimeInterval(-day * 2))

        var nsabimana = Farmer(ownerID: ownerID, name: "Nsabimana J.", crop: "Maize", seasonsWithCoop: 6)
        nsabimana.recordHarvest(kilos: 210, crop: "Maize", date: .now.addingTimeInterval(-day * 7))
        nsabimana.markPaid()

        var ingabire = Farmer(ownerID: ownerID, name: "Ingabire C.", crop: "Beans", seasonsWithCoop: 0)
        ingabire.recordHarvest(kilos: 120, crop: "Sorghum", date: .now.addingTimeInterval(-day))

        let kamanzi = Farmer(ownerID: ownerID, name: "Kamanzi D.", crop: "Coffee", seasonsWithCoop: 3)

        return [jeanne, habimana, mukamana, nsabimana, ingabire, kamanzi]
    }
}
