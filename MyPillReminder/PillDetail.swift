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
                // Optional: disable until the user enters a pill name
                .disabled(pill.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
    
    /// Returns the existing schedule or creates and attaches a new one, keeping the name in sync
    private func getOrCreateSchedule() -> PillSchedule {
        let cleanName = pill.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentName = cleanName.isEmpty ? "Pill" : cleanName
        
        if let existing = pill.schedule {
            // Always sync the schedule name with the current pill name
            existing.name = currentName
            try? context.save()
            return existing
        }
        
        let newSchedule = PillSchedule(name: currentName)
        context.insert(newSchedule)
        pill.schedule = newSchedule
        try? context.save()
        
        return newSchedule
    }
}
