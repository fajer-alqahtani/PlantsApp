import SwiftUI
import SwiftData

struct PlantsListView: View {
    @Query(sort: \Plant.name, order: .forward) private var plants: [Plant]
    @Environment(\.modelContext) private var context

    @State private var showingAddSheet = false
    @State private var editingPlant: Plant?

    // Header progress: fraction of plants watered today
    private var wateredTodayCount: Int {
        let cal = Calendar.current
        return plants.filter { cal.isDateInToday($0.lastWatered) }.count
    }
    private var headerProgress: Double {
        guard !plants.isEmpty else { return 0 }
        return Double(wateredTodayCount) / Double(plants.count)
    }
    private var allDoneToday: Bool {
        !plants.isEmpty && wateredTodayCount == plants.count
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("My Plants 🌱")
                    .font(.largeTitle.weight(.heavy))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)

                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 1)

                if allDoneToday {
                    // Completion state
                    CompletionView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 32)
                } else {
                    // Normal header + list
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(wateredTodayCount) of your plants feel loved today ✨")
                            .foregroundStyle(.white.opacity(0.9))
                            .font(.subheadline)

                        ProgressView(value: headerProgress)
                            .tint(Color(red: 0.27, green: 0.82, blue: 0.58))
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.15))
                            )
                            .frame(height: 6)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .animation(.easeInOut(duration: 0.25), value: headerProgress)
                    }
                    .padding(.bottom, 8)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(plants) { (plant: Plant) in
                                PlantRow(plant: plant)
                                    .contextMenu {
                                        Button("Mark as Watered", action: {
                                            plant.lastWatered = .now
                                            try? context.save()
                                        })
                                        Button("Edit") { editingPlant = plant }
                                        Divider()
                                        Button(role: .destructive, action: {
                                            context.delete(plant)
                                            try? context.save()
                                        }) {
                                            Text("Delete")
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        // Custom pill-shaped red delete like the mock
                                        Button {
                                            context.delete(plant)
                                            try? context.save()
                                        } label: {
                                            ZStack {
                                                Capsule(style: .continuous)
                                                    .fill(Color.red)
                                                    .frame(width: 72, height: 72)
                                                Image(systemName: "trash")
                                                    .font(.system(size: 22, weight: .bold))
                                                    .foregroundStyle(.white)
                                            }
                                            .padding(.vertical, 6)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button {
                                            plant.lastWatered = .now
                                            try? context.save()
                                        } label: {
                                            Label("Water", systemImage: "drop.fill")
                                        }
                                        .tint(Color(red: 0.27, green: 0.82, blue: 0.58))
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button {
                                            editingPlant = plant
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.indigo)
                                    }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // Floating add button (always visible)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button { showingAddSheet = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.34, green: 0.82, blue: 0.54),
                                        Color(red: 0.22, green: 0.79, blue: 0.54)
                                    ],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.6), radius: 10, y: 6)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            SetReminder()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
        .sheet(item: $editingPlant) { plant in
            EditPlantView(plant: plant)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
    }
}

private struct CompletionView: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 260, height: 260)
                Image("Plant")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
            }

            Text("All Done! 🎉")
                .font(.title.weight(.bold))
                .foregroundStyle(.white)

            Text("All Reminders Completed")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct PlantRow: View {
    @Environment(\.modelContext) private var context
    @Bindable var plant: Plant

    private var isWateredToday: Bool {
        Calendar.current.isDateInToday(plant.lastWatered)
    }

    // Colors for tag pills
    private var pillFill: Color { Color(red: 0.17, green: 0.19, blue: 0.21) } // ~ #2B2F33
    private var pillStroke: Color { Color.white.opacity(0.10) }
    private var sunColor: Color { Color(red: 0xCC/255.0, green: 0xC7/255.0, blue: 0x85/255.0) }   // #CCC785
    private var waterColor: Color { Color(red: 0xCA/255.0, green: 0xF3/255.0, blue: 0xFB/255.0) } // #CAF3FB

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "paperplane")
                    .foregroundStyle(.white.opacity(0.8))
                Text("in \(plant.room)")
                    .foregroundStyle(.white.opacity(0.8))
                    .font(.footnote)
                Spacer()
            }

            HStack(alignment: .firstTextBaseline) {
                Button {
                    plant.lastWatered = Date.now
                    try? context.save()
                } label: {
                    Group {
                        if isWateredToday {
                            Circle()
                                .fill(Color(red: 0.27, green: 0.82, blue: 0.58))
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.black.opacity(0.9))
                                )
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Circle()
                                .strokeBorder(.white.opacity(0.8), lineWidth: 2)
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Circle()
                                        .trim(from: 0, to: min(1, plant.progressTowardNextWater))
                                        .stroke(
                                            Color(red: 0.27, green: 0.82, blue: 0.58),
                                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                        )
                                        .rotationEffect(.degrees(-90))
                                        .animation(.easeInOut(duration: 0.25), value: plant.progressTowardNextWater)
                                )
                        }
                    }
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.25, dampingFraction: 0.9), value: isWateredToday)

                Text(plant.name)
                    .foregroundStyle(.white)
                    .font(.title3.weight(.semibold))
                Spacer()
            }

            HStack(spacing: 8) {
                Tag(icon: "sun.max", text: plant.light, foreground: sunColor, background: pillFill, stroke: pillStroke)
                Tag(icon: "drop", text: plant.waterAmount, foreground: waterColor, background: pillFill, stroke: pillStroke)
                Spacer()
            }

            Divider().background(Color.white.opacity(0.15))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(0.35)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

private struct Tag: View {
    let icon: String
    let text: String
    var foreground: Color = .white.opacity(0.9)
    var background: Color = Color.white.opacity(0.12)
    var stroke: Color = Color.white.opacity(0.15)

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(background)
                .overlay(Capsule().stroke(stroke))
        )
        .foregroundStyle(foreground)
    }
}

#Preview {
    PlantsListView()
        .modelContainer(for: Plant.self, inMemory: true)
}
