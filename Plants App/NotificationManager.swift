// NotificationManager.swift
import Foundation
import UserNotifications

enum NotificationManager {
    static func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }

    static func scheduleWateringNotification(for plantName: String, everyNDays n: Int, atHour hour: Int = 9, minute: Int = 0) async {
        // Build content
        let content = UNMutableNotificationContent()
        content.title = "Time to water \(plantName)"
        content.body = "Keep your plant happy! 💧"
        content.sound = .default

        // First fire date: next occurrence of selected time, respecting the N-day cadence.
        // We’ll schedule as repeating calendar triggers across multiple days by creating one trigger per day-offset modulo n.
        // Simpler approach: schedule the next fire date once, non-repeating, and reschedule on app launch. But for convenience, we’ll use repeating with a custom next date sequence.

        // Calendar-based repeating cannot repeat “every N days” directly; it repeats on specific date components.
        // Workaround: schedule a single notification for the next date, non-repeating. When it fires, schedule the next one. For a simple first version, schedule multiple triggers ahead.
        // Here, we’ll schedule the next one non-repeating; when the app next launches/foregrounds, you could reschedule more. For now, schedule a series ahead (e.g., next 10 occurrences).

        let center = UNUserNotificationCenter.current()
        // Remove any pending duplicates for the same title (basic cleanup)
        await center.removeAllPendingNotificationRequests()

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
            do {
                try await center.add(request)
            } catch {
                // You might want to log or handle this in production
            }
        }
    }
}
