//
//  MainView.swift
//  swiftUIChatter
//
//  Created by Isley Sepulveda on 2/7/24.
//

import SwiftUI

struct MainView: View {
    @State private var initialized = false
    
    var body: some View {
        Button {
            initialized.toggle()
        } label: {
            Text("Start an interview!")
        }
        .navigationTitle("intersim")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $initialized) {
            StartView(isPresented: $initialized)
        }
    }
}
