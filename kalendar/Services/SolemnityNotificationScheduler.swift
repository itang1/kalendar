//
//  SolemnityNotificationScheduler.swift
//  kalendar
//
//  Schedules a local notification on the morning of each upcoming solemnity.

import Foundation
import UserNotifications

enum SolemnityNotificationScheduler {
    private static let identifierPrefix = "kalendar.solemnity."
    private static let notificationHour = 8

    /// Requests notification permission if needed, then schedules. Calls back on
    /// the main thread with whether permission is granted, so the caller can
    /// reflect that in a toggle.
    static func enable(for days: [DayCard], completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                schedule(for: days)
                DispatchQueue.main.async { completion(true) }
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    if granted { schedule(for: days) }
                    DispatchQueue.main.async { completion(granted) }
                }
            default:
                // Denied or restricted: nothing we can schedule until the user
                // re-enables notifications for the app in Settings.
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    static func disable() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ours = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(identifierPrefix) }
            center.removePendingNotificationRequests(withIdentifiers: ours)
        }
    }

    /// Replaces any previously scheduled solemnity notifications with a fresh set
    /// built from the current day window (the window shifts forward on every
    /// launch, so this keeps coverage current).
    static func schedule(for days: [DayCard]) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ours = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(identifierPrefix) }
            center.removePendingNotificationRequests(withIdentifiers: ours)

            let calendar = Calendar.current
            for day in days where day.isSolemnity {
                guard let feastName = day.feastName else { continue }

                var trigger = calendar.dateComponents([.year, .month, .day], from: day.date)
                trigger.hour = notificationHour
                trigger.minute = 0

                let content = UNMutableNotificationContent()
                content.title = feastName
                content.body = "A solemnity in the Church's calendar today."
                content.sound = .default

                let identifier = identifierPrefix + String(format: "%04d-%02d-%02d", trigger.year ?? 0, trigger.month ?? 0, trigger.day ?? 0)
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: false)
                )
                center.add(request) { error in
                    if let error {
                        assertionFailure("Failed to schedule notification \(identifier): \(error)")
                    }
                }
            }
        }
    }
}
