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
        }
        .modelContainer(for: [Pill.self])
    }
}
