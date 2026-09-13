//
//  DashboardView.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
// Gemini

import SwiftUI
import SwiftData

// Helper struct representing an actionable reminder item for today
struct TodayDoseItem: Identifiable {
    let id: String
    let scheduleName: String
    let doseLabel: String
    let time: Date
    let icon: String
}

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    
    // Fetch all schedules and logs
    @Query private var schedules: [PillSchedule]
    @Query private var logs: [PillTaking]
    
    private let calendar = Calendar.current
    
    // MARK: - Computed Properties for Today's Filter
    
    /// Filters schedules that should run today (Daily or matching Day of the Week)
    private var todaySchedules: [PillSchedule] {
        let weekdayIndex = calendar.component(.weekday, from: Date()) // 1 = Sunday, 7 = Saturday
        
        return schedules.filter { schedule in
            guard !schedule.finished else { return false }
            
            // If daily is true OR if both are false (newly created default), show it
            if schedule.daily || (!schedule.daily && !schedule.weekly) {
                return true
            }
            
            if schedule.weekly {
                switch weekdayIndex {
                case 1: return schedule.sunday
                case 2: return schedule.monday
                case 3: return schedule.tuesday
                case 4: return schedule.wednesday
                case 5: return schedule.thursday
                case 6: return schedule.friday
                case 7: return schedule.saturday
                default: return false
                }
            }
            return false
        }
    }
    
    /// Generates individual dose times from active schedules
    private var todayDoses: [TodayDoseItem] {
        var items: [TodayDoseItem] = []
        
        for schedule in todaySchedules {
            let name = schedule.name.isEmpty ? "Medication" : schedule.name
            
            // 1. Specific Hour
            if schedule.specific_hour {
                items.append(TodayDoseItem(
                    id: "\(name)-specific",
                    scheduleName: name,
                    doseLabel: "Scheduled Time",
                    time: schedule.scheduledTime,
                    icon: "clock.fill"
                ))
            }
            
            // 2. Meal & Routine Times
            if schedule.daily_time {
                if schedule.before_breakfast || schedule.after_breakfast {
                    let timing = schedule.before_breakfast ? "Before Breakfast" : "After Breakfast"
                    items.append(TodayDoseItem(
                        id: "\(name)-breakfast",
                        scheduleName: name,
                        doseLabel: timing,
                        time: schedule.breakfast_time,
                        icon: "cup.and.saucer.fill"
                    ))
                }
                
                if schedule.before_lunch || schedule.after_lunch {
                    let timing = schedule.before_lunch ? "Before Lunch" : "After Lunch"
                    items.append(TodayDoseItem(
                        id: "\(name)-lunch",
                        scheduleName: name,
                        doseLabel: timing,
                        time: schedule.lunch_time,
                        icon: "fork.knife"
                    ))
                }
                
                if schedule.before_dinner || schedule.after_dinner {
                    let timing = schedule.before_dinner ? "Before Dinner" : "After Dinner"
                    items.append(TodayDoseItem(
                        id: "\(name)-dinner",
                        scheduleName: name,
                        doseLabel: timing,
                        time: schedule.dinner_time,
                        icon: "takeoutbag.and.cup.and.straw.fill"
                    ))
                }
                
                if schedule.before_bed {
                    items.append(TodayDoseItem(
                        id: "\(name)-bed",
                        scheduleName: name,
                        doseLabel: "Before Bed",
                        time: schedule.bed_time,
                        icon: "moon.zzz.fill"
                    ))
                }
            }
        }
        
        // Sort items by time of day
        return items.sorted { $0.time < $1.time }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Summary Header Card
                    summaryCard
                    
                    // Actionable Schedule List
                    if todayDoses.isEmpty {
                        ContentUnavailableView(
                            "No Doses For Today",
                            systemImage: "checkmark.seal.fill",
                            description: Text("You have no pending medications scheduled for today.")
                        )
                        .padding(.top, 40)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Schedule")
                                .font(.title3.bold())
                                .padding(.horizontal)
                            
                            ForEach(todayDoses) { dose in
                                doseRow(dose: dose)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Today")
        }
    }
    
    // MARK: - Subviews
    
    private var summaryCard: some View {
        let total = todayDoses.count
        let takenCount = todayDoses.filter { isDoseTaken(scheduleName: $0.scheduleName, doseLabel: $0.doseLabel) }.count
        
        return VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Date().formatted(date: .complete, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Daily Progress")
                        .font(.title2.bold())
                }
                Spacer()
                
                Text("\(takenCount)/\(total)")
                    .font(.title.bold())
                    .foregroundStyle(.blue)
            }
            
            ProgressView(value: total == 0 ? 0 : Double(takenCount) / Double(total))
                .tint(.blue)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    private func doseRow(dose: TodayDoseItem) -> some View {
        let taken = isDoseTaken(scheduleName: dose.scheduleName, doseLabel: dose.doseLabel)
        
        return HStack(spacing: 14) {
            Image(systemName: dose.icon)
                .font(.title2)
                .foregroundStyle(taken ? .gray : .blue)
                .frame(width: 44, height: 44)
                .background(taken ? Color(.systemGray5) : Color.blue.opacity(0.12))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 3) {
                Text(dose.scheduleName)
                    .font(.headline)
                    .strikethrough(taken, color: .secondary)
                    .foregroundStyle(taken ? .secondary : .primary)
                
                HStack(spacing: 6) {
                    Text(dose.doseLabel)
                    Text("•")
                    Text(dose.time.formatted(date: .omitted, time: .shortened))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // "Taken" Toggle Button
            Button {
                toggleDose(dose: dose, currentlyTaken: taken)
            } label: {
                if taken {
                    Label("Taken", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.green)
                } else {
                    Text("Take")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }
    
    // MARK: - Actions
    
    private func isDoseTaken(scheduleName: String, doseLabel: String) -> Bool {
        logs.contains { log in
            log.scheduleName == scheduleName &&
            log.doseLabel == doseLabel &&
            calendar.isDateInToday(log.takenDate)
        }
    }
    
    private func toggleDose(dose: TodayDoseItem, currentlyTaken: Bool) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if currentlyTaken {
                // Remove existing log for today if untapping
                if let logToDelete = logs.first(where: {
                    $0.scheduleName == dose.scheduleName &&
                    $0.doseLabel == dose.doseLabel &&
                    calendar.isDateInToday($0.takenDate)
                }) {
                    context.delete(logToDelete)
                }
            } else {
                // Record new pill taking
                let newRecord = PillTaking(scheduleName: dose.scheduleName, doseLabel: dose.doseLabel)
                context.insert(newRecord)
            }
            try? context.save()
        }
    }
}
