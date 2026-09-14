//
//  UserProfile.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
//

import Foundation

struct UserProfile: Codable, Equatable {
    var name: String = ""
    var email: String = ""
    var gender: String = "Prefer not to say"
    var age: Int = 25
    var joinedDate: Date = Date()
}
