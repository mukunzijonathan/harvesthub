import SwiftUI

struct FarmerListView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = CoopViewModel()
    @State private var showingAddFarmer = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("🌾 HarvestHub")
                .navigationDestination(for: String.self) { id in
                    FarmerDetailView(farmerID: id, vm: vm)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        accountMenu
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAddFarmer = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Add farmer")
                    }
                }
                .sheet(isPresented: $showingAddFarmer) {
                    AddFarmerView(crops: vm.crops) { name, crop, seasons in
                        vm.addFarmer(name: name, crop: crop, seasonsWithCoop: seasons)
                    }
                }
                .alert("Something went wrong", isPresented: errorBinding) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(vm.errorMessage ?? "")
                }
        }
        .tint(.green)
        .onAppear {
            vm.listen()
        }
    }

    @ViewBuilder
    private var content: some View {
        if vm.isLoading {
            ProgressView("Loading farmers…")
        } else if vm.farmers.isEmpty {
            ContentUnavailableView {
                Label("No farmers yet", systemImage: "person.3")
            } description: {
                Text("Register your cooperative's first farmer to start recording harvests.")
            } actions: {
                Button("Add a farmer") { showingAddFarmer = true }
                    .buttonStyle(.borderedProminent)
                Button("Load sample farmers") { vm.loadSampleFarmers() }
            }
        } else {
            List {
                Section {
                    SeasonSummaryView(vm: vm)
                }

                Section("Farmers") {
                    ForEach(vm.rankedFarmers) { farmer in
                        NavigationLink(value: farmer.id) {
                            FarmerRow(farmer: farmer)
                        }
                    }
                    .onDelete { offsets in
                        offsets.map { vm.rankedFarmers[$0] }.forEach(vm.delete)
                    }
                }
            }
        }
    }

    private var accountMenu: some View {
        Menu {
            if let email = auth.user?.email {
                Text("Signed in as \(email)")
            }
            Button("Sign out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                auth.signOut()
            }
        } label: {
            Image(systemName: "person.crop.circle")
        }
        .accessibilityLabel("Account")
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )
    }
}

struct FarmerRow: View {
    let farmer: Farmer

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(farmer.status.color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(farmer.name).font(.headline)
                Text("\(farmer.crop) · \(farmer.totalKilos) kg")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if farmer.status == .held || farmer.status == .logged {
                    Text("—").font(.subheadline)
                } else if let due = farmer.amountDue {
                    Text("\(due.formatted()) RWF")
                        .font(.subheadline.monospacedDigit())
                }
                Text(farmer.status.label)
                    .font(.caption2.bold())
                    .foregroundStyle(farmer.status.color)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SeasonSummaryView: View {
    @ObservedObject var vm: CoopViewModel

    var body: some View {
        HStack {
            stat(title: "Paid out", value: "\(vm.paidOut.formatted()) RWF")
            Divider()
            stat(title: "Still unpaid", value: "\(vm.unpaidFarmers.count)")
            Divider()
            stat(title: "Farmers", value: "\(vm.farmers.count)")
        }
        .padding(.vertical, 6)
    }

    private func stat(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Farmer rows") {
    List(Farmer.samples(ownerID: nil), id: \.name) { farmer in
        FarmerRow(farmer: farmer)
    }
}
