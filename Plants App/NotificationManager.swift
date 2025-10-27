// NotificationManager.swift
import Foundation
import UserNotifications

enum NotificationManager {
    static func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }

    static func scheduleWateringNotification(for plantName: String, everyNDays n: Int, atHour hour: Int = 9, minute: Int = 0) async {
        let content = UNMutableNotificationContent()
        content.title = "Hey! let’s water your plant"
        content.body = "\(plantName) will be happy 💧"
        content.sound = .default

        let center = UNUserNotificationCenter.current()

        // Do not use `await` here; this API is synchronous.
        center.removeAllPendingNotificationRequests()

        let cal = Calendar.current
        let now = Date()
        var next = cal.date(bySettingHour: hour, minute: minute, second: 0, of: now) ?? now
        if next <= now {
            next = cal.date(byAdding: .day, value: 1, to: next) ?? now
        }

        // Schedule next 10 occurrences separated by n days
        for i in 0..<10 {
            guard let fireDate = cal.date(byAdding: .day, value: i * n, to: next) else { continue }
            let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let id = "water-\(plantName)-\(i)-\(Int(fireDate.timeIntervalSince1970))"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            // Use completion-handler variant for broader compatibility
            center.add(request) { error in
                if let error = error {
                    print("Failed to schedule \(id): \(error)")
                }
            }
        }
    }
}
