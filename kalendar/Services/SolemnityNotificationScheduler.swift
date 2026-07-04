//
//  SolemnityNotificationScheduler.swift
//  kalendar
//
//  Schedules a local notification on the morning of each upcoming solemnity.

import Foundation
import UserNotifications

enum SolemnityNotificationScheduler {
    private static let identifierPrefix = "kalendar.solemnity."
    private static let windowExpirationIdentifier = "kalendar.windowExpiration"
    private static let notificationHour = 8

    /// Requests notification permission if needed, then schedules. Returns whether
    /// permission is granted, so the caller can reflect that in a toggle.
    static func enable(for days: [DayCard]) async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional:
            await schedule(for: days)
            return true
        case .notDetermined:
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            if granted {
                await schedule(for: days)
            }
            return granted
        default:
            return false
        }
    }

    static func disable() async {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()
        let ours = requests
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) || $0 == windowExpirationIdentifier }
        center.removePendingNotificationRequests(withIdentifiers: ours)
    }

    /// Replaces any previously scheduled solemnity notifications with a fresh set
    /// built from the current day window (the window shifts forward on every
    /// launch, so this keeps coverage current).
    static func schedule(for days: [DayCard]) async {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()
        let ours = requests
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) || $0 == windowExpirationIdentifier }
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
            do {
                try await center.add(request)
            } catch {
                assertionFailure("Failed to schedule notification \(identifier): \(error)")
            }
        }

        // The window only extends when the app is actually opened (see the
        // `.task` in CircleCalendarView), so a user who stops opening it would
        // otherwise just stop hearing from us with no signal anything lapsed.
        // A reminder at the far edge of the window degrades gracefully: it nudges
        // them back, which reschedules everything and pushes the window forward
        // again, indefinitely.
        if let lastDay = days.last {
            var trigger = calendar.dateComponents([.year, .month, .day], from: lastDay.date)
            trigger.hour = notificationHour
            trigger.minute = 0

            let content = UNMutableNotificationContent()
            content.title = "Keep the reminders coming"
            content.body = "Open Kalendar to line up next year's solemnity notifications."
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: windowExpirationIdentifier,
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: false)
            )
            do {
                try await center.add(request)
            } catch {
                assertionFailure("Failed to schedule window-expiration notification: \(error)")
            }
        }
    }
}
