//
//  NotificationManager.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
// Gemini

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    /// Requests user authorization for banners, sounds, and badges
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Schedules all dose reminders for a given PillSchedule
    func scheduleNotifications(for schedule: PillSchedule) {
        // Remove old pending alerts for this schedule before re-adding
        cancelNotifications(for: schedule)
        
        guard !schedule.finished else { return }
        
        // 1. Specific Hour
        if schedule.specific_hour {
            scheduleDose(
                id: "\(schedule.name)-specific",
                title: "Time for \(schedule.name)",
                body: "Don't forget your scheduled medication dose.",
                time: schedule.scheduledTime,
                schedule: schedule
            )
        }
        
        // 2. Meal & Sleep Times
        if schedule.daily_time {
            if schedule.before_breakfast || schedule.after_breakfast {
                let timing = schedule.before_breakfast ? "Before Breakfast" : "After Breakfast"
                scheduleDose(
                    id: "\(schedule.name)-breakfast",
                    title: "Breakfast Dose: \(schedule.name)",
                    body: "Take \(timing).",
                    time: schedule.breakfast_time,
                    schedule: schedule
                )
            }
            if schedule.before_lunch || schedule.after_lunch {
                let timing = schedule.before_lunch ? "Before Lunch" : "After Lunch"
                scheduleDose(
                    id: "\(schedule.name)-lunch",
                    title: "Lunch Dose: \(schedule.name)",
                    body: "Take \(timing).",
                    time: schedule.lunch_time,
                    schedule: schedule
                )
            }
            if schedule.before_dinner || schedule.after_dinner {
                let timing = schedule.before_dinner ? "Before Dinner" : "After Dinner"
                scheduleDose(
                    id: "\(schedule.name)-dinner",
                    title: "Dinner Dose: \(schedule.name)",
                    body: "Take \(timing).",
                    time: schedule.dinner_time,
                    schedule: schedule
                )
            }
            if schedule.before_bed {
                scheduleDose(
                    id: "\(schedule.name)-bed",
                    title: "Bedtime Dose: \(schedule.name)",
                    body: "Take your bedtime medication.",
                    time: schedule.bed_time,
                    schedule: schedule
                )
            }
        }
    }
    
    /// Cancels scheduled notifications for this pill
    func cancelNotifications(for schedule: PillSchedule) {
        let identifiers = [
            "\(schedule.name)-specific",
            "\(schedule.name)-breakfast",
            "\(schedule.name)-lunch",
            "\(schedule.name)-dinner",
            "\(schedule.name)-bed"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // MARK: - Private Trigger Helper
    
    private func scheduleDose(id: String, title: String, body: String, time: Date, schedule: PillSchedule) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let cal = Calendar.current
        let hour = cal.component(.hour, from: time)
        let minute = cal.component(.minute, from: time)
        
        // Clean identifier: strip parentheses, spaces, and slashes
        let cleanId = id.replacingOccurrences(of: "[^A-Za-z0-9_-]", with: "_", options: .regularExpression)
        
        // Check if daily or default (neither selected yet)
        let isDaily = schedule.daily || (!schedule.daily && !schedule.weekly)
        
        if isDaily {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.second = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: cleanId, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Failed to add notification [\(cleanId)]: \(error.localizedDescription)")
                } else {
                    print("✅ Scheduled DAILY for \(hour):\(String(format: "%02d", minute)):00 (ID: \(cleanId))")
                    if let next = trigger.nextTriggerDate() {
                        print("   👉 Next trigger at: \(next.formatted(date: .complete, time: .complete))")
                    }
                }
            }
        } else if schedule.weekly {
            let activeDays: [(Int, Bool)] = [
                (1, schedule.sunday),
                (2, schedule.monday),
                (3, schedule.tuesday),
                (4, schedule.wednesday),
                (5, schedule.thursday),
                (6, schedule.friday),
                (7, schedule.saturday)
            ]
            
            for (weekday, isActive) in activeDays where isActive {
                var dateComponents = DateComponents()
                dateComponents.weekday = weekday
                dateComponents.hour = hour
                dateComponents.minute = minute
                dateComponents.second = 0
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "\(cleanId)-day\(weekday)", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("❌ Failed to add weekly notification: \(error.localizedDescription)")
                    } else {
                        print("✅ Scheduled WEEKLY day \(weekday) for \(hour):\(String(format: "%02d", minute)):00")
                    }
                }
            }
        }
    }
    
    
}
