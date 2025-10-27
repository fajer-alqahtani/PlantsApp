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

    @State private var showDeleteConfirm = false

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

                // Delete button with same capsule glass shape (red destructive tint)
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Text("Delete Reminder")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                // Glass base
                                Capsule(style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                                    )
                                    .shadow(color: .black.opacity(0.35), radius: 10, y: 5)

                                // Destructive red gradient tint
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.95, green: 0.23, blue: 0.23).opacity(0.90),
                                        Color(red: 0.80, green: 0.11, blue: 0.11).opacity(0.90)
                                    ],
                                    startPoint: .top, endPoint: .bottom
                                )
                                .clipShape(Capsule(style: .continuous))

                                // Subtle inner highlight
                                Capsule(style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.45), Color.white.opacity(0.05)],
                                            startPoint: .top, endPoint: .bottom
                                        ),
                                        lineWidth: 1
                                    )
                                    .blur(radius: 0.5)
                            }
                        )
                        .clipShape(Capsule(style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 6)
                .confirmationDialog("Delete this reminder?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        deletePlant()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will remove the plant and its reminder.")
                }

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

    private func deletePlant() {
        context.delete(plant)
        try? context.save()
        dismiss()
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
