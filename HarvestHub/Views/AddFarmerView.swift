import SwiftUI

struct AddFarmerView: View {
    let crops: [String]
    let onSave: (String, String, Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var crop = "Maize"
    @State private var seasons = 0

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Farmer") {
                    TextField("Full name", text: $name)
                        .textInputAutocapitalization(.words)
                    Picker("Main crop", selection: $crop) {
                        ForEach(crops, id: \.self) { Text($0) }
                    }
                }

                Section {
                    Stepper("Seasons with the cooperative: \(seasons)", value: $seasons, in: 0...50)
                } footer: {
                    Text("Members with 3 or more seasons earn a \(loyaltyBonus(seasonsWithCoop: 3).formatted()) RWF loyalty bonus.")
                }
            }
            .navigationTitle("New farmer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(trimmedName, crop, seasons)
                        dismiss()
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
        }
    }
}
