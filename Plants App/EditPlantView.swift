import SwiftUI
import SwiftData

struct EditPlantView: View {
    @Bindable var plant: Plant
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    // Local working copies so user can cancel without changing
    @State private var name: String = ""
    @State private var room: String = ""
    @State private var light: String = ""
    @State private var watering: String = ""
    @State private var waterAmount: String = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                ReminderCard(
                    plantName: $name,
                    room: $room,
                    light: $light,
                    watering: $watering,
                    waterAmount: $waterAmount,
                    onCancel: { dismiss() },
                    onSave: {
                        applyChanges()
                        dismiss()
                    }
                )
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .onAppear(perform: loadFromPlant)
    }

    private func loadFromPlant() {
        name = plant.name
        room = plant.room
        light = plant.light
        watering = daysToWatering(plant.wateringFrequencyDays)
        waterAmount = plant.waterAmount
    }

    private func applyChanges() {
        plant.name = name.isEmpty ? "Unnamed Plant" : name
        plant.room = room
        plant.light = light
        plant.wateringFrequencyDays = wateringToDays(watering)
        plant.waterAmount = waterAmount
        try? context.save()
    }

    private func wateringToDays(_ value: String) -> Int {
        switch value {
        case "Every day": return 1
        case "Every 2 days": return 2
        case "Twice a week": return 3
        case "Weekly": return 7
        default: return 3
        }
    }

    private func daysToWatering(_ days: Int) -> String {
        switch days {
        case 1: return "Every day"
        case 2: return "Every 2 days"
        case 3: return "Twice a week"
        case 7: return "Weekly"
        default: return "Twice a week"
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Plant.self, configurations: .init(isStoredInMemoryOnly: true))
    let context = container.mainContext
    let plant = Plant(name: "Orchid", room: "Living Room", light: "Full sun", wateringFrequencyDays: 3, waterAmount: "20–50 ml")
    context.insert(plant)
    return EditPlantView(plant: plant).modelContainer(container)
}
