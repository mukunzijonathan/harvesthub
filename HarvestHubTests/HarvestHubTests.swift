//
//  HarvestHubTests.swift
//  HarvestHubTests
//
//  Created by APimpNamedSlickBack on 14/10/2026.
//

import Testing
@testable import HarvestHub

struct HarvestHubTests {

    @Test func payoutIsKilosTimesPrice() {
        #expect(payout(kilos: 340, pricePerKg: 350) == 119_000)
    }

    @Test func loyaltyBonusStartsAtThreeSeasons() {
        #expect(loyaltyBonus(seasonsWithCoop: 2) == 0)
        #expect(loyaltyBonus(seasonsWithCoop: 3) == 5_000)
        #expect(loyaltyBonus() == 0)
    }

    @Test func unknownCropHasNoPrice() {
        #expect(priceFor(crop: "Maize") == 350)
        #expect(priceFor(crop: "Sorghum") == nil)
    }

    @Test func recordingAPricedHarvestMakesTheFarmerPending() {
        var farmer = Farmer(name: "Uwase Jeanne", crop: "Maize", seasonsWithCoop: 4)
        #expect(farmer.status == .logged)

        farmer.recordHarvest(kilos: 200, crop: "Maize")
        farmer.recordHarvest(kilos: 140, crop: "Maize")

        #expect(farmer.status == .priced)
        #expect(farmer.totalKilos == 340)
        #expect(farmer.amountDue == 124_000)
    }

    @Test func unpricedCropHoldsThePayment() {
        var farmer = Farmer(name: "Ingabire C.", crop: "Beans", seasonsWithCoop: 0)
        farmer.recordHarvest(kilos: 120, crop: "Sorghum")

        #expect(farmer.status == .held)
        #expect(farmer.amountDue == nil)

        farmer.markPaid()
        #expect(farmer.status == .held)
    }

    @Test func onlyAPricedFarmerCanBePaid() {
        var farmer = Farmer(name: "Kamanzi D.", crop: "Coffee", seasonsWithCoop: 3)
        farmer.markPaid()
        #expect(farmer.status == .logged)

        farmer.recordHarvest(kilos: 100, crop: "Coffee")
        farmer.markPaid()
        #expect(farmer.status == .paid)
    }

    @Test func sampleFarmersAreStampedWithTheirOwner() {
        let samples = Farmer.samples(ownerID: "officer-1")
        #expect(samples.count == 6)
        #expect(samples.allSatisfy { $0.ownerID == "officer-1" })
    }
}
