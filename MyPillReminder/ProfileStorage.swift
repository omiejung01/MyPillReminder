//
//  ProfileStorage.swift
//  MyPillReminder
//
//  Created by Omie C on 14/9/2569 BE.
//

import Foundation

class ProfileStorage {
    private static let key = "saved_user_profile_json"
    
    // MARK: - Save to JSON (Encodable)
    static func save(_ profile: UserProfile) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Clean readable JSON
        encoder.dateEncodingStrategy = .iso8601    // Standard date format
        
        do {
            let data = try encoder.encode(profile)
            UserDefaults.standard.set(data, forKey: key)
            
            // Optional: Print the JSON string to debug console
            if let jsonString = String(data: data, encoding: .utf8) {
                print(" Saved Profile JSON:\n\(jsonString)")
            }
        } catch {
            print("❌ Failed to encode UserProfile: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Load from JSON (Decodable)
    static func load() -> UserProfile {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return UserProfile() // Return default empty profile if none saved
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(UserProfile.self, from: data)
        } catch {
            print("❌ Failed to decode UserProfile: \(error.localizedDescription)")
            return UserProfile()
        }
    }
}
