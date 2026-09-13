//
//  ProfileViewModel.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile
    
    init() {
        // Mock data initialization
        self.profile = UserProfile(
            name: "Jane Doe",
            email: "jane.doe@example.com",
            gender: "Female",
            age: 21,
            //isSubscribedToNewsletter: true,
            joinedDate: Date()
        )
    }
    
    func saveChanges() {
        // Logic to persist data locally or update Firestore/Backend
        print("Profile saved successfully.")
    }
    
    func logout() {
        // Triggers the authentication flow sign-out routine
        print("User logged out.")
    }
}
