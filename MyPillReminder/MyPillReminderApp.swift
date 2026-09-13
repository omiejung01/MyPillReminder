//
//  MyPillReminderApp.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
//

import SwiftUI
import SwiftData

@main
struct MyPillReminderApp: App {
    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
            //let schedule = PillSchedule()
            //PillScheduleView(schedule: schedule)
        }
        .modelContainer(for: [Pill.self, PillSchedule.self, PillTaking.self])
        
        
    }
}
