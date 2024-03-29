//
//  MainView.swift
//  swiftUIChatter
//
//  Created by Isley Sepulveda on 2/7/24.
//

import SwiftUI

struct MainView: View {
    @State private var initialized = false
    @State private var username = ""
    
    var body: some View {
        Button {
            initialized.toggle()
            username = "testuser"
        } label: {
            Image(systemName: "person")
            Text("Continue as guest.")
        }
        .navigationTitle("intersim")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $initialized) {
            StartView(isPresented: $initialized, username: $username)
        }
    }
}
