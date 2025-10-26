//
//  SetReminder.swift
//  Plants App
//
//  Created by Fajer alQahtani on 30/04/1447 AH.
//

import SwiftUI
import SwiftData

//MARK: -DARK MODE
struct Dark: PreviewProvider {
    static var previews: some View {
        SetReminder()
            .preferredColorScheme(.dark)
            .modelContainer(for: Plant.self, inMemory: true)
    }
}

//MARK: - Card
struct ReminderCard: View {
    @Binding var plantName: String
    @Binding var room: String
    @Binding var light: String
    @Binding var watering: String
    @Binding var waterAmount: String

    var onCancel: () -> Void
    var onSave: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            // Header
            HStack {
                CircleIconButton(
                    systemName: "xmark",
                    fill: .black.opacity(0.35),
                    action: onCancel
                )
                Spacer()
                Text("Set Reminder")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.95))
                Spacer()
                CircleIconButton(
                    systemName: "checkmark",
                    fill: Color(red: 0.27, green: 0.82, blue: 0.58),
                    action: onSave
                )
            }
            .padding(.top, 6)

            // Fields
            PillTextField(label: "Plant Name", text: $plantName)

            SectionCard {
                SettingRow(
                    systemIcon: "paperplane",
                    title: "Room",
                    value: $room,
                    options: ["Bedroom", "Living Room", "Kitchen", "Balcony"]
                )
                SectionDivider()
                SettingRow(
                    systemIcon: "sun.max",
                    title: "Light",
                    value: $light,
                    options: ["Full sun", "Half sun", "Indirect", "Low light"]
                )
            }

            SectionCard {
                SettingRow(
                    systemIcon: "drop",
                    title: "Watering Days",
                    value: $watering,
                    options: ["Every day", "Every 2 days", "Twice a week", "Weekly"]
                )
                SectionDivider()
                SettingRow(
                    systemIcon: "drop",
                    title: "Water",
                    value: $waterAmount,
                    options: ["10–20 ml", "20–50 ml", "50–100 ml"]
                )
            }
        }
        .padding(18)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.55), radius: 20, y: 10)
    }
}

// MARK: - SettingRow
struct SettingRow: View {
    let systemIcon: String
    let title: String
    @Binding var value: String
    let options: [String]

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemIcon)
                .frame(width: 24)
                .foregroundStyle(.white.opacity(0.9))
            Text(title)
                .foregroundStyle(.white)
                .font(.headline)
            Spacer()
            Menu {
                ForEach(options, id: \.self) { opt in
                    Button(opt) { value = opt }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(value)
                        .foregroundStyle(.white.opacity(0.9))
                    Image(systemName: "chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .contentShape(Rectangle())
            }
            .menuStyle(.automatic)
        }
        .padding(.horizontal, 18)
        .frame(height: 64)
        .background(Color.white.opacity(0.001))
    }
}

//MARK: -
struct SectionCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

struct SectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(height: 1)
            .padding(.leading, 56)
    }
}

//MARK: - HEADER
struct CircleIconButton: View {
    let systemName: String
    let fill: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(fill)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: systemName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                )
        }
        .buttonStyle(.plain)
    }
}

//MARK: -
struct PillTextField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .foregroundStyle(.white.opacity(0.9))
                .font(.headline)
            TextField("Pothos", text: $text)
                .foregroundStyle(.white.opacity(0.85))
                .tint(Color(red: 0.18, green: 0.83, blue: 0.74))
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

//MARK: - Code
struct SetReminder: View {
    @State private var plantName: String = "Pothos"
    @State private var room: String = "Bedroom"
    @State private var light: String = "Full sun"
    @State private var watering: String = "Every day"
    @State private var waterAmount: String = "20–50 ml"

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                ReminderCard(
                    plantName: $plantName,
                    room: $room,
                    light: $light,
                    watering: $watering,
                    waterAmount: $waterAmount,
                    onCancel: { dismiss() },
                    onSave: {
                        addPlant()
                        dismiss()
                    }
                )
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    private func addPlant() {
        let frequencyDays = wateringToDays(watering)
        let plant = Plant(
            name: plantName.isEmpty ? "Unnamed Plant" : plantName,
            room: room,
            light: light,
            wateringFrequencyDays: frequencyDays,
            waterAmount: waterAmount,
            lastWatered: Date.now
        )
        context.insert(plant)
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
}

#Preview {
    SetReminder()
        .modelContainer(for: Plant.self, inMemory: true)
}
