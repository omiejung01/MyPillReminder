//
//  PillHistoryView.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
// Gemini

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

enum HistoryFilter: String, CaseIterable, Identifiable {
    case yesterday = "Yesterday"
    case today = "Today"
    case all = "All"
    
    var id: String { rawValue }
}

struct PillHistoryView: View {
    @Environment(\.modelContext) private var context
    
    // Fetch all logs sorted newest first
    @Query(sort: \PillTaking.takenDate, order: .reverse) private var logs: [PillTaking]
    
    // State for the file exporter
    @State private var documentToExport: PillHistoryDocument?
    @State private var isExporting: Bool = false
    
    @State private var selectedFilter: HistoryFilter = .yesterday
    private let calendar = Calendar.current
    
    // Filtered records based on the segmented picker
    private var filteredLogs: [PillTaking] {
        switch selectedFilter {
        case .yesterday:
            return logs.filter { calendar.isDateInYesterday($0.takenDate) }
        case .today:
            return logs.filter { calendar.isDateInToday($0.takenDate) }
        case .all:
            return logs
        }
    }
    
    // Group logs by midnight
    private var groupedLogs: [(date: Date, records: [PillTaking])] {
        let grouped = Dictionary(grouping: filteredLogs) { log in
            calendar.startOfDay(for: log.takenDate)
        }
        return grouped.sorted { $0.key > $1.key }
            .map { (date: $0.key, records: $0.value) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Time Period", selection: $selectedFilter) {
                    ForEach(HistoryFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                Group {
                    if groupedLogs.isEmpty {
                        ContentUnavailableView(
                            selectedFilter == .yesterday ? "No Records for Yesterday" : "No Records Found",
                            systemImage: "calendar.badge.clock",
                            description: Text(selectedFilter == .yesterday
                                              ? "No medication logs were recorded yesterday."
                                              : "Medications you mark as 'Taken' will appear here.")
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
            }
            .navigationTitle("Pill History")
           
            .toolbar {
                // Top-left Share / Export Button
                ToolbarItem(placement: .topBarLeading) {
                    if !logs.isEmpty {
                        Button {
                            exportHistory()
                        } label: {
                            Label("Export JSON", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                
                // Existing Add Yesterday Test Button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addSampleYesterdayRecord()
                    } label: {
                        Label("Add Yesterday Test", systemImage: "plus.circle.dashed")
                    }
                }
            }
            // Native Save to Files Sheet
            .fileExporter(
                isPresented: $isExporting,
                document: documentToExport,
                contentType: .json,
                defaultFilename: "pill_history"
            ) { result in
                switch result {
                case .success(let url):
                    print("✅ Saved to Files successfully at: \(url.path)")
                case .failure(let error):
                    print("❌ Export error: \(error.localizedDescription)")
                }
            }
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
    
    /// Inserts a test log with a timestamp 24 hours in the past
    private func addSampleYesterdayRecord() {
        let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let sample = PillTaking(
            scheduleName: "Sample Medication",
            doseLabel: "Breakfast",
            takenDate: yesterdayDate
        )
        context.insert(sample)
        try? context.save()
    }
    
    private func exportHistory() {
        let dtos = logs.map { PillTakingRecordDTO(from: $0) }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        if let data = try? encoder.encode(dtos),
           let jsonString = String(data: data, encoding: .utf8) {
            self.documentToExport = PillHistoryDocument(jsonText: jsonString)
            self.isExporting = true
        }
    }
}

#Preview {
    PillHistoryView()
        .modelContainer(for: PillTaking.self, inMemory: true)
}
