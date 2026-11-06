import Foundation

let prices = ["Maize": 350, "Beans": 800, "Coffee": 900]

func priceFor(crop: String) -> Int? {
    return prices[crop]
}

func payout(kilos: Int, pricePerKg: Int) -> Int {
    return kilos * pricePerKg
}

func loyaltyBonus(seasonsWithCoop: Int = 0) -> Int {
    if seasonsWithCoop >= 3 { return 5000 }
    return 0
}
