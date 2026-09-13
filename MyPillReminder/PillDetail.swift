//
//  PillDetail.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
//

import SwiftUI
import SwiftData

struct PillDetail: View {
    @Bindable var pill: Pill
    let isNew: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    init(pill: Pill, isNew: Bool = false) {
        self.pill = pill
        self.isNew = isNew
    }
    
    var body: some View {
        Form {
            Section("Pill Info") {
                TextField("Name", text: $pill.name)
                    .autocorrectionDisabled()
                TextField("Unit", text: $pill.unit)
                    .autocorrectionDisabled()
            }
            
            Section("Schedule") {
                // Navigate to the persisted schedule
                NavigationLink("Setup Schedulers") {
                    PillScheduleView(schedule: getOrCreateSchedule())
                }
            }
        }
        .navigationTitle(isNew ? "New Pill" : "Pill")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isNew {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        try? context.save()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        context.delete(pill)
                        try? context.save()
                        dismiss()
                    }
                }
            }
        }
    }
    
    /// Returns the existing schedule or creates and attaches a new one once
    private func getOrCreateSchedule() -> PillSchedule {
        if let existing = pill.schedule {
            return existing
        }
        
        let customPattern = Date().formatted(.dateTime.year().month(.twoDigits).day(.twoDigits))
        let scheduleName = (pill.name.isEmpty ? "Pill" : pill.name) + " (\(customPattern))"
        
        let newSchedule = PillSchedule(name: scheduleName)
        context.insert(newSchedule)
        pill.schedule = newSchedule
        try? context.save()
        
        return newSchedule
    }
}
