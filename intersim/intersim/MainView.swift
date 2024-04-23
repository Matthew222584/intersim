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
    @State private var selectedNumberOfQuestions: Int = 1
    @State private var showPicker = false
    
    var body: some View {
        VStack {
            Button {
                showPicker = true
            } label: {
                Image(systemName: "person")
                Text("Continue as guest")
            }
            .sheet(isPresented: $showPicker) {
                VStack {
                    Text("Select Number of Questions").font(.headline).padding()
                    Picker("picker", selection: $selectedNumberOfQuestions) {
                        ForEach(1..<11) { number in
                            Text("\(number)")
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(WheelPickerStyle())
                    .padding()
                    
                    Button("Done") {
                        userInstance.setUsername(username: "testuser")
                        userInstance.setNumQuestions(numQuestions: selectedNumberOfQuestions + 1)
                        Interview.shared.fetchQuestions()
                        print(selectedNumberOfQuestions + 1)
                        showPicker = false
                        initialized = true
                    }
                    .navigationBarTitleDisplayMode(.large)
                    .buttonStyle(DefaultButtonStyle())
                }
            }
        }
        .navigationTitle("intersim")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $initialized) {
            StartView(isPresented: $initialized)
        }
        .buttonStyle(DefaultButtonStyle())
    }
}
