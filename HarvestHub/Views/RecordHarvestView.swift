import SwiftUI

struct RecordHarvestView: View {
    let crops: [String]
    let onSave: (Int, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var kilosText = ""
    @State private var crop: String

    init(crops: [String], defaultCrop: String, onSave: @escaping (Int, String) -> Void) {
        self.crops = crops
        self.onSave = onSave
        _crop = State(initialValue: defaultCrop)
    }

    private var kilos: Int? {
        guard let value = Int(kilosText), value > 0 else { return nil }
        return value
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Weighing station") {
                    TextField("Kilos", text: $kilosText)
                        .keyboardType(.numberPad)
                    Picker("Crop", selection: $crop) {
                        ForEach(crops, id: \.self) { Text($0) }
                    }
                }

                if let kilos {
                    Section {
                        if kilos > 350 {
                            Text("⚠️ Large load, please re-weigh.").foregroundStyle(.orange)
                        }
                        if let price = priceFor(crop: crop) {
                            LabeledContent("Pays", value: "\(payout(kilos: kilos, pricePerKg: price).formatted()) RWF")
                        } else {
                            Text("⚠️ No price set for \(crop), payment will be held.")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("Record harvest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let kilos {
                            onSave(kilos, crop)
                            dismiss()
                        }
                    }
                    .disabled(kilos == nil)
                }
            }
        }
    }
}
