import Foundation
import SwiftData

@Model
class PillSchedule{
    var name: String = ""
    var daily: Bool = true
    var weekly: Bool = false
    
    var specific_hour: Bool = true
    var scheduledTime: Date = Date()
    
    var daily_time: Bool = false
    
    var before_breakfast: Bool = false
    var after_breakfast: Bool = false
    var breakfast_time: Date = Date()
    
    var before_lunch: Bool = false
    var after_lunch: Bool = false
    var lunch_time: Date = Date()
    var before_dinner: Bool = false
    var after_dinner: Bool = false
    
    var dinner_time: Date = Date()

    var before_bed: Bool = false
    var bed_time: Date = Date()

    
    var sunday: Bool = false
    var monday: Bool = false
    var tuesday: Bool = false
    var wednesday: Bool = false
    var thursday: Bool = false
    var friday: Bool = false
    var saturday: Bool = false
    
    var additional_detail: String = ""
    
    var finished: Bool = false
    
    init(name: String) {
        self.name = name
    }
    
}


