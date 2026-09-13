//
//  PillScheduleView.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
//  Gemini
//
//  PillScheduleView.swift
//  MyPillReminder
//

import SwiftUI
import SwiftData
struct PillScheduleView: View {
    @Bindable var schedule: PillSchedule
    @Environment(\.modelContext) private var context  // 👈 Add context
    
    // Day helper mapping for the weekday selector
    private let days: [(label: String, keyPath: ReferenceWritableKeyPath<PillSchedule, Bool>)] = [
        ("S", \.sunday),
        ("M", \.monday),
        ("T", \.tuesday),
        ("W", \.wednesday),
        ("T", \.thursday),
        ("F", \.friday),
        ("S", \.saturday)
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 20) {
                
                // MARK: - Schedule Info
                GroupBox("Schedule Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Schedule Name (e.g. Daily Vitamins)", text: $schedule.name)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                        
                        Toggle("Mark as Finished", isOn: $schedule.finished)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Frequency Section
                GroupBox("Repeat Frequency") {
                    VStack(spacing: 14) {
                        Picker("Frequency", selection: Binding(
                            get: { schedule.weekly ? "Weekly" : "Daily" },
                            set: { newValue in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if newValue == "Weekly" {
                                        schedule.weekly = true
                                        schedule.daily = false
                                    } else {
                                        schedule.daily = true
                                        schedule.weekly = false
                                    }
                                }
                            }
                        )) {
                            Text("Daily").tag("Daily")
                            Text("Weekly").tag("Weekly")
                        }
                        .pickerStyle(.segmented)
                        
                        // Weekday Circular Badges (Weekly Mode)
                        if schedule.weekly {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Repeat on")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                HStack {
                                    ForEach(days.indices, id: \.self) { index in
                                        let item = days[index]
                                        let isSelected = schedule[keyPath: item.keyPath]
                                        
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.15)) {
                                                schedule[keyPath: item.keyPath].toggle()
                                            }
                                        } label: {
                                            Text(item.label)
                                                .font(.subheadline.bold())
                                                .frame(maxWidth: .infinity, minHeight: 40)
                                                .background(isSelected ? Color.blue : Color(.systemGray5))
                                                .foregroundStyle(isSelected ? .white : .primary)
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Timing Method
                GroupBox("Timing Method") {
                    VStack(spacing: 12) {
                        Toggle("Specific Hour", isOn: $schedule.specific_hour.animation(.easeInOut(duration: 0.2)))
                        
                        // Inline Wheel Time Picker
                        if schedule.specific_hour {
                            VStack(spacing: 6) {
                                DatePicker(
                                    "Select Time",
                                    selection: $schedule.scheduledTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        Divider()
                        
                        Toggle("Meal & Bed Routines", isOn: $schedule.daily_time.animation(.easeInOut(duration: 0.2)))
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Meal & Bed Routine Times
                if schedule.daily_time {
                    GroupBox("Meal & Bed Schedule") {
                        VStack(spacing: 16) {
                            // Breakfast
                            MealRoutineRow(
                                title: "Breakfast",
                                systemImage: "cup.and.saucer.fill",
                                before: $schedule.before_breakfast,
                                after: $schedule.after_breakfast,
                                time: $schedule.breakfast_time
                            )
                            
                            Divider()
                            
                            // Lunch
                            MealRoutineRow(
                                title: "Lunch",
                                systemImage: "fork.knife",
                                before: $schedule.before_lunch,
                                after: $schedule.after_lunch,
                                time: $schedule.lunch_time
                            )
                            
                            Divider()
                            
                            // Dinner
                            MealRoutineRow(
                                title: "Dinner",
                                systemImage: "takeoutbag.and.cup.and.straw.fill",
                                before: $schedule.before_dinner,
                                after: $schedule.after_dinner,
                                time: $schedule.dinner_time
                            )
                            
                            Divider()
                            
                            // Bed Time
                            VStack(spacing: 8) {
                                Toggle(isOn: $schedule.before_bed.animation(.easeInOut(duration: 0.2))) {
                                    Label("Before Bed", systemImage: "moon.zzz.fill")
                                        .font(.subheadline.bold())
                                }
                                
                                if schedule.before_bed {
                                    DatePicker(
                                        "Bed Time",
                                        selection: $schedule.bed_time,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .datePickerStyle(.compact)
                                    .padding(.top, 2)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // MARK: - Additional Notes
                GroupBox("Instructions / Notes") {
                    VStack(alignment: .leading, spacing: 6) {
                        TextField("e.g. Take with food, avoid dairy", text: $schedule.additional_detail, axis: .vertical)
                            .lineLimit(3...5)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Edit Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            try? context.save()
            NotificationManager.shared.scheduleNotifications(for: schedule)
            
        }       
    }
}

// MARK: - Helper Component for Meal Rows
private struct MealRoutineRow: View {
    let title: String
    let systemImage: String
    @Binding var before: Bool
    @Binding var after: Bool
    @Binding var time: Date
    
    // Shows time picker whenever before or after is chosen
    private var isMealActive: Bool {
        before || after
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.bold())
            
            HStack(spacing: 12) {
                Toggle("Before", isOn: $before.animation(.easeInOut(duration: 0.2)))
                    .toggleStyle(.button)
                    .tint(.blue)
                
                Toggle("After", isOn: $after.animation(.easeInOut(duration: 0.2)))
                    .toggleStyle(.button)
                    .tint(.blue)
                
                Spacer()
            }
            
            // Compact Time Picker appears dynamically when selected
            if isMealActive {
                DatePicker(
                    "\(title) Time",
                    selection: $time,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
