//
//  UserProfile.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
//

import Foundation

struct UserProfile: Codable {
    var name: String
    var email: String
    var gender: String
    var age: Int
    var joinedDate: Date
}
