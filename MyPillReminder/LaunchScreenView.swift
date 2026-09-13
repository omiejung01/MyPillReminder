//
//  LaunchScreenView.swift
//  MyPillReminder
//
//  Created by Omie C on 13/9/2569 BE.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                LinearGradient(colors: [Color.blue, Color.mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Image("pillIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    
                    Text("Loading...")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                }
            }
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
