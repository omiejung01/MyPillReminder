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
    
    @Query(sort: \Pill.name) private var pills: [Pill]

    init(pill: Pill, isNew: Bool = false) {
        self.pill = pill
        self.isNew = isNew
    }
    
    var body: some View {
        Form {
            TextField("Name", text: $pill.name )
                .autocorrectionDisabled()
            TextField("Unit", text: $pill.unit )
                .autocorrectionDisabled()
            
            /*
            Picker("Favorite Movie", selection: $friend.favoriteMovie) {
                ForEach(movies) { movie in
                    Text(movie.title)
                        .tag(nil as Movie?)
                }
                
            }*/
        }
        .navigationTitle(isNew ? "New Pill" : "Pill")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isNew {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/*
#Preview {
    PillDetail()
}*/
