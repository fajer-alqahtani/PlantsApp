import SwiftUI
import SwiftData

struct PlantsListView: View {
    @Query(sort: \Plant.name, order: .forward) private var plants: [Plant]
    @Environment(\.modelContext) private var context

    @State private var showingAddSheet = false

    private var headerProgress: Double {
        guard !plants.isEmpty else { return 0 }
        let total = plants.map(\.progressTowardNextWater).reduce(0, +)
        return min(1.0, max(0.0, total / Double(plants.count)))
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

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your plants are waiting for a sip 💦")
                        .foregroundStyle(.white.opacity(0.9))
                        .font(.subheadline)

                    ProgressView(value: headerProgress)
                        .tint(.white.opacity(0.9))
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.15))
                        )
                        .frame(height: 6)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(.bottom, 8)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        // NOTE: no $plants, no indices — iterate the models directly
                        ForEach(plants) { (plant: Plant) in
                            PlantRow(plant: plant)
                                .contextMenu {
                                    Button("Mark as Watered", action: {
                                        plant.lastWatered = .now
                                        try? context.save()
                                    })
                                    
                                    Divider()
                                    
                                    Button(role: .destructive, action: {
                                        context.delete(plant)
                                        try? context.save()
                                    }) {
                                        Text("Delete")
                                    }
                                }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // Floating add button
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
    }
}

private struct PlantRow: View {
    @Environment(\.modelContext) private var context
    @Bindable var plant: Plant
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
                    Circle()
                        .strokeBorder(.white.opacity(0.8), lineWidth: 2)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .trim(from: 0, to: min(1, plant.progressTowardNextWater))
                                .stroke(
                                    Color.green.opacity(0.9),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                        )
                }
                .buttonStyle(.plain)

                Text(plant.name)
                    .foregroundStyle(.white)
                    .font(.title3.weight(.semibold))
                Spacer()
            }

            HStack(spacing: 8) {
                Tag(icon: "sun.max", text: plant.light)
                Tag(icon: "drop", text: plant.waterAmount)
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
                .fill(Color.white.opacity(0.12))
                .overlay(Capsule().stroke(Color.white.opacity(0.15)))
        )
        .foregroundStyle(.white.opacity(0.9))
    }
}

#Preview {
    PlantsListView()
        .modelContainer(for: Plant.self, inMemory: true)
}
