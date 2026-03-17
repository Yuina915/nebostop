import Foundation
import UserNotifications

final class DeclarationReminderManager {
    static let shared = DeclarationReminderManager()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let reminderIdentifier = "nebostop.declarationReminder"

    private init() {}

    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("declaration reminder auth error:", error.localizedDescription)
            } else if !granted {
                print("declaration reminder permission denied")
            }
        }
    }

    func rescheduleReminderIfNeeded(hasDeclared: Bool) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        guard !hasDeclared else { return }
        guard let reminderDate = nextReminderDate() else { return }
        scheduleReminder(at: reminderDate)
    }

    private func scheduleReminder(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "わすれてない？😭"
        content.body = "明日は何時におきるのか教えて欲しいな！"
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
        notificationCenter.add(request) { error in
            if let error = error {
                print("failed to schedule declaration reminder:", error.localizedDescription)
            }
        }
    }

    private func nextReminderDate(from reference: Date = Date()) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: reference)
        components.hour = 23
        components.minute = 0
        components.second = 0
        guard let todayTrigger = calendar.date(from: components) else {
            return nil
        }
        if todayTrigger > reference {
            return todayTrigger
        }
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: reference) else {
            return nil
        }
        var nextComponents = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        nextComponents.hour = 23
        nextComponents.minute = 0
        nextComponents.second = 0
        return calendar.date(from: nextComponents)
    }
}

final class WakeupFollowupManager {
    static let shared = WakeupFollowupManager()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let reminderIdentifier = "nebostop.wakeupFollowup"

    private init() {}

    func scheduleFollowup(after declaredDate: Date) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        guard let followupDate = Calendar.current.date(byAdding: .minute, value: 5, to: declaredDate) else { return }
        guard followupDate > Date() else { return }
        scheduleFollowupNotification(at: followupDate)
    }

    func cancelFollowup() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }

    private func scheduleFollowupNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "おきてるー？"
        content.body = "おきてたら教えに来て欲しいな！！"
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
        notificationCenter.add(request) { error in
            if let error = error {
                print("failed to schedule wakeup follow-up:", error.localizedDescription)
            }
        }
    }
}
