//
//  StartView.swift
//  intersim
//
//  Created by Isley Sepulveda on 3/20/24.
//

import SwiftUI

struct StartView: View {
    @Binding var isPresented: Bool
    @State private var isPresenting = false
    @State private var showQuestion = false
    @State private var showText = false
    
    @ViewBuilder
    func TextButton() -> some View {
        Button {
            showQuestion = true
            showText = true
        } label: {
            Text("Text")
            Image(systemName: "doc.text")
        }
    }
    
    @ViewBuilder
    func AudioButton() -> some View {
        Button {
            showQuestion = true
        } label: {
            Text("Audio")
            Image(systemName: "mic")
        }
    }
    
    var body: some View {
        VStack {
            Text("Choose an interview type.")
                .padding(.top, 30.0)
            HStack {
                TextButton()
                AudioButton()
            }
            .navigationTitle("Start")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showQuestion) {
                QuestionView(showTextView: showText)
            }
        }
    }
}
