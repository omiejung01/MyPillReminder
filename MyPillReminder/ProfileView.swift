//
//  ProfileView.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
//

import SwiftUI

struct ProfileView: View {
    @State private var profile = ProfileStorage.load()
    @State private var showSavedAlert = false
    
    private let genderOptions = ["Male", "Female", "Other", "Prefer not to say"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Details") {
                    TextField("Name", text: $profile.name)
                        .autocorrectionDisabled()
                    
                    TextField("Email", text: $profile.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section("Demographics") {
                    Picker("Gender", selection: $profile.gender) {
                        ForEach(genderOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    Stepper("Age: \(profile.age)", value: $profile.age, in: 1...120)
                }
                
                Section("Account Info") {
                    HStack {
                        Text("Joined Date")
                        Spacer()
                        Text(profile.joinedDate.formatted(date: .abbreviated, time: .omitted))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section {
                    Button("Save Profile") {
                        ProfileStorage.save(profile)
                        showSavedAlert = true
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("User Profile")
            .alert("Profile Saved", isPresented: $showSavedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your profile has been serialized to JSON and saved.")
            }
        }
    }
}
