//
//  PillList.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
//

import SwiftUI
import SwiftData

struct PillList: View {
    @Query(sort: \Pill.name) private var pills: [Pill]
    @Environment(\.modelContext) private var context
    @State private var newPill: Pill?
    
    var body: some View {
        NavigationSplitView {
            Group {
                if !pills.isEmpty {
                    List {
                        ForEach(pills) { pill in
                            NavigationLink(pill.name + " - " + pill.unit) {
                                PillDetail(pill: pill)
                            }
                        }
                        .onDelete(perform: deletePills(indexes:))
                    }
                } else {
                    ContentUnavailableView("Add Pills", systemImage: "pills.fill")
                }
            }
            .navigationTitle("Pill reminders")
            .toolbar {
                ToolbarItem {
                    Button("Add Pill", systemImage: "plus", action: addPill)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            /*
            .sheet(item: $newPill) { pill in
                NavigationStack {
                    PillDetail(pill: pill, isNew: true)
                }
                .interactiveDismissDisabled()
            }*/
        } detail: {
            Text("Select a pill")
                .navigationTitle("Pill")
                .navigationBarTitleDisplayMode(.inline)
            
        }
    }
    
    private func addPill() {
        let newPill = Pill(name: "", unit: "")
        context.insert(newPill)
        self.newPill = newPill
    }
    
    private func deletePills(indexes: IndexSet) {
        for index in indexes {
            context.delete(pills[index])
        }
    }
}
/*
#Preview {
    FriendList()
        .modelContainer(SampleData.shared.modelContainer)
}

#Preview("Empty List") {
    FriendList()
        .modelContainer(for: Friend.self, inMemory: true)
}

*/
