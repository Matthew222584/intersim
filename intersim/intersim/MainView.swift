//
//  MainView.swift
//  swiftUIChatter
//
//  Created by Isley Sepulveda on 2/7/24.
//

import SwiftUI

struct MainView: View {
    let userInstance = User.shared
    @State private var initialized = false
    
    var body: some View {
        Button {
            initialized.toggle()
            userInstance.setUsername(username: "testuser")
        } label: {
            Image(systemName: "person")
            Text("Continue as guest")
        }
        .navigationTitle("intersim")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $initialized) {
            StartView(isPresented: $initialized)
        }
        .buttonStyle(DefaultButtonStyle())
    }
}
