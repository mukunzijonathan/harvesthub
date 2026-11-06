import Foundation
import FirebaseAuth
import FirebaseFirestore

class CoopViewModel: ObservableObject {

    @Published var farmers: [Farmer] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    let crops = ["Maize", "Beans", "Coffee", "Sorghum"]

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private var farmersRef: CollectionReference {
        db.collection("farmers")
    }

    deinit {
        listener?.remove()
    }

    // Biggest deliveries on top, your Act 7 season report.
    var rankedFarmers: [Farmer] {
        farmers.sorted { $0.totalKilos > $1.totalKilos }
    }

    var unpaidFarmers: [Farmer] {
        farmers.filter { $0.status != .paid }
    }

    var paidOut: Int {
        farmers
            .filter { $0.status == .paid }
            .compactMap { $0.amountDue }
            .reduce(0, +)
    }

    func farmer(with id: String) -> Farmer? {
        farmers.first { $0.id == id }
    }

    // READ: only the signed-in officer's farmers, kept live from the cloud.
    func listen() {
        guard listener == nil, let uid = Auth.auth().currentUser?.uid else { return }

        listener = farmersRef
            .whereField("ownerID", isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self.farmers = documents.compactMap { try? $0.data(as: Farmer.self) }
            }
    }

    // WRITE: every new farmer is stamped with the officer who registered them.
    func addFarmer(name: String, crop: String, seasonsWithCoop: Int) {
        let farmer = Farmer(ownerID: Auth.auth().currentUser?.uid,
                            name: name,
                            crop: crop,
                            seasonsWithCoop: seasonsWithCoop)
        create(farmer)
    }

    func loadSampleFarmers() {
        for farmer in Farmer.samples(ownerID: Auth.auth().currentUser?.uid) {
            create(farmer)
        }
    }

    func recordHarvest(for id: String, kilos: Int, crop: String) {
        if let i = farmers.firstIndex(where: { $0.id == id }) {
            farmers[i].recordHarvest(kilos: kilos, crop: crop)
            update(farmers[i])
        }
    }

    func markPaid(_ id: String) {
        if let i = farmers.firstIndex(where: { $0.id == id }) {
            farmers[i].markPaid()
            update(farmers[i])
        }
    }

    func delete(_ farmer: Farmer) {
        guard let id = farmer.id else { return }
        farmersRef.document(id).delete { [weak self] error in
            if let error { self?.errorMessage = error.localizedDescription }
        }
    }

    private func create(_ farmer: Farmer) {
        do {
            try farmersRef.addDocument(from: farmer)
        } catch {
            errorMessage = "Could not save \(farmer.name): \(error.localizedDescription)"
        }
    }

    private func update(_ farmer: Farmer) {
        guard let id = farmer.id else { return }
        do {
            try farmersRef.document(id).setData(from: farmer)
        } catch {
            errorMessage = "Could not save \(farmer.name): \(error.localizedDescription)"
        }
    }
}
