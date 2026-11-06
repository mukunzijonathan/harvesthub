import SwiftUI

struct FarmerDetailView: View {
    let farmerID: String
    @ObservedObject var vm: CoopViewModel
    @State private var showingRecordSheet = false

    var body: some View {
        if let farmer = vm.farmer(with: farmerID) {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(farmer.name).font(.largeTitle).bold()
                        Text("\(farmer.seasonsWithCoop) seasons with the cooperative")
                            .foregroundStyle(.secondary)
                        Label(message(for: farmer.status), systemImage: "circle.fill")
                            .foregroundStyle(farmer.status.color)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }

                Section("This season") {
                    LabeledContent("Total delivered", value: "\(farmer.totalKilos) kg")
                    if let due = farmer.amountDue, farmer.status != .logged {
                        LabeledContent(farmer.status == .paid ? "Paid" : "Amount due",
                                       value: "\(due.formatted()) RWF")
                        let bonus = loyaltyBonus(seasonsWithCoop: farmer.seasonsWithCoop)
                        if bonus > 0 {
                            LabeledContent("Includes loyalty bonus", value: "\(bonus.formatted()) RWF")
                        }
                    } else if farmer.status == .held {
                        Text("⚠️ A crop has no price set, payment held.")
                            .foregroundStyle(.red)
                    }
                }

                Section("Harvest history") {
                    if farmer.harvests.isEmpty {
                        Text("No harvests recorded yet.").foregroundStyle(.secondary)
                    }
                    ForEach(farmer.harvests.reversed()) { harvest in
                        HarvestRow(harvest: harvest)
                    }
                }

                Section {
                    Button {
                        showingRecordSheet = true
                    } label: {
                        Label("Record a harvest", systemImage: "scalemass")
                    }
                    .disabled(farmer.status == .paid)

                    Button {
                        vm.markPaid(farmerID)
                    } label: {
                        Label("Mark as paid", systemImage: "checkmark.seal.fill")
                    }
                    .disabled(farmer.status != .priced)
                } footer: {
                    if farmer.status == .paid {
                        Text("This farmer's season is settled.")
                    }
                }
            }
            .navigationTitle("Farmer")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingRecordSheet) {
                RecordHarvestView(crops: vm.crops, defaultCrop: farmer.crop) { kilos, crop in
                    vm.recordHarvest(for: farmerID, kilos: kilos, crop: crop)
                }
            }
        } else {
            ContentUnavailableView("Farmer not found", systemImage: "person.slash")
        }
    }
}

struct HarvestRow: View {
    let harvest: Harvest

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(harvest.kilos) kg of \(harvest.crop)").font(.body)
                Text(harvest.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let price = priceFor(crop: harvest.crop) {
                Text("\(payout(kilos: harvest.kilos, pricePerKg: price).formatted()) RWF")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            } else {
                Text("no price").font(.caption).foregroundStyle(.red)
            }
        }
    }
}
