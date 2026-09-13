//
//  PillHistoryView.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
// Gemini

import SwiftUI
import SwiftData

struct PillHistoryView: View {
    @Environment(\.modelContext) private var context
    
    // Fetch all logs sorted by newest timestamp first
    @Query(sort: \PillTaking.takenDate, order: .reverse) private var logs: [PillTaking]
    
    private let calendar = Calendar.current
    
    // Group logs by midnight of their respective days
    private var groupedLogs: [(date: Date, records: [PillTaking])] {
        let grouped = Dictionary(grouping: logs) { log in
            calendar.startOfDay(for: log.takenDate)
        }
        return grouped.sorted { $0.key > $1.key }
            .map { (date: $0.key, records: $0.value) }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if logs.isEmpty {
                    ContentUnavailableView(
                        "No History Yet",
                        systemImage: "calendar.badge.clock",
                        description: Text("Medications you mark as 'Taken' will appear here.")
                    )
                } else {
                    List {
                        ForEach(groupedLogs, id: \.date) { group in
                            Section(header: Text(formattedDateHeader(group.date))) {
                                ForEach(group.records) { record in
                                    HStack(spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                            .font(.title3)
                                        
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(record.scheduleName)
                                                .font(.headline)
                                            Text(record.doseLabel)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(record.takenDate.formatted(date: .omitted, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 2)
                                }
                                .onDelete { indexSet in
                                    deleteRecord(from: group.records, at: indexSet)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Pill History")
        }
    }
    
    // MARK: - Helpers
    
    private func formattedDateHeader(_ date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    private func deleteRecord(from records: [PillTaking], at offsets: IndexSet) {
        for index in offsets {
            let item = records[index]
            context.delete(item)
        }
        try? context.save()
    }
}

#Preview {
    PillHistoryView()
        .modelContainer(for: PillTaking.self, inMemory: true)
}
