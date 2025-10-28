import Foundation
import SwiftData

@Model
final class Plant {

    var name: String
    var room: String
    var light: String
    var wateringFrequencyDays: Int
    var waterAmount: String
    var lastWatered: Date

    init(
        name: String,
        room: String,
        light: String,
        wateringFrequencyDays: Int,
        waterAmount: String,
        lastWatered: Date = Date.now
    ) {
        self.name = name
        self.room = room
        self.light = light
        self.wateringFrequencyDays = wateringFrequencyDays
        self.waterAmount = waterAmount
        self.lastWatered = lastWatered
    }

    // 0 = just watered, 1+ = overdue; clamp to 0...1 for progress bar
    var progressTowardNextWater: Double {
        let interval = Date().timeIntervalSince(lastWatered)
        let days = interval / (60 * 60 * 24)
        let pct = days / Double(wateringFrequencyDays)
        return max(0.0, min(1.0, pct))
    }

    var needsWater: Bool {
        progressTowardNextWater >= 1.0
    }
}
extension Plant: Identifiable {}

