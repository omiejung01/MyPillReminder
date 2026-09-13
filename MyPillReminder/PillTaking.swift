//
//  PillTaking.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
//

import Foundation

import Foundation
import SwiftData

@Model
class PillTaking {
    var id: UUID = UUID()
    var scheduleName: String = ""
    var doseLabel: String = "" // by Gemini
    var takenDate: Date = Date() // by Gemini
    
    init(scheduleName: String, doseLabel: String, takenDate: Date = Date()) {
        self.id = UUID()
        self.scheduleName = scheduleName
        self.doseLabel = doseLabel
        self.takenDate = takenDate
    }
}

