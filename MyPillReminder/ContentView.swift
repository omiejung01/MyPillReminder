//
//  ContentView.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        TabView {
            Tab ("Pills", systemImage: "pencil.and.list.clipboard") {
                PillList()
            }
            
            Tab ("Dashboard", systemImage: "inset.filled.rectangle.and.person.filled") {
                DashboardView()
            }
            
            Tab("History", systemImage: "clock.arrow.circlepath") {
                    PillHistoryView()
                }
            
            Tab ("User Profiles", systemImage: "person.circle") {
                ProfileView()
            }
        }
        
        //ProfileView()
    }
}

#Preview {
    ContentView()
}
