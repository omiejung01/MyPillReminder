//
//  Pill.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
//

import Foundation
import SwiftData

@Model
class Pill {
    var name: String
    var unit: String
    
    init(name: String, unit: String) {
        self.name = name
        self.unit = unit
    }
}
