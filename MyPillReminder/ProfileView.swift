//
//  ProfileView.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
//

import SwiftUI

enum Gender: String, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    case preferNotToSay = "Prefer not to say"
    
    var id: String { self.rawValue }
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isEditing = false
    
    @State private var selectedGender: Gender = .preferNotToSay
    @State private var age: Int = 25
    
    var body: some View {
        NavigationView {
            Form {
                // Section 1: Avatar Header
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .foregroundColor(.accentColor)
                            
                            Text(viewModel.profile.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Member since \(viewModel.profile.joinedDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Section 2: Account Information Details
                Section(header: Text("Account Details")) {
                    if isEditing {
                        TextField("Name", text: $viewModel.profile.name)
                        TextField("Email", text: $viewModel.profile.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        Picker("Gender", selection: $selectedGender) {
                                                ForEach(Gender.allCases) { gender in
                                                    Text(gender.rawValue).tag(gender)
                                                }
                                            }
                                            .pickerStyle(.menu)

                                            Stepper("Age: \(age)", value: $age, in: 1...120)
                        
                        
                    } else {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(viewModel.profile.name).foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(viewModel.profile.email).foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Gender")
                            Spacer()
                            Text(viewModel.profile.gender).foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Age")
                            Spacer()
                            Text(String(viewModel.profile.age)).foregroundColor(.secondary)
                        }
                        
                    }
                }
                
                // Section 3: Preferences & Toggles
                //Section(header: Text("Preferences")) {
                //    Toggle("Newsletter Subscription", isOn:
                //    $viewModel.profile.isSubscribedToNewsletter)
                //  .disabled(!isEditing)
                //}
                
                // Section 4: Log Out Actions
                /*
                Section {
                    Button(action: {
                        viewModel.logout()
                    }) {
                        Text("Log Out")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                 */
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if isEditing {
                            viewModel.saveChanges()
                        }
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "Done" : "Edit")
                            .fontWeight(isEditing ? .bold : .regular)
                    }
                }
            }
        }
    }
}

// Xcode Canvas Preview Layout Provider
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
