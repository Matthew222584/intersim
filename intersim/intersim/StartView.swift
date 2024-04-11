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
    
    // text, audio, video
    @State private var showViews = [false, false, false]
    
    @ViewBuilder
    func TextButton() -> some View {
        Button {
            showQuestion = true
            showViews = [true, false, false]
        } label: {
            Text("Text")
            Image(systemName: "doc.text")
        }
    }
    
    @ViewBuilder
    func AudioButton() -> some View {
        Button {
            showQuestion = true
            showViews = [false, true, false]
        } label: {
            Text("Audio")
            Image(systemName: "mic")
        }
    }
    
    @ViewBuilder
    func VideoButton() -> some View {
        Button {
            showQuestion = true
            showViews = [false, false, true]
        } label: {
            Text("Video")
            Image(systemName: "video")
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Choose an interview type.")
                .padding(.top, 30.0)
                .font(.system(size: 40))
            Spacer()
            VStack {
                TextButton()
                AudioButton()
                VideoButton()
            }
            Spacer()
            .navigationTitle("Start")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $showQuestion) {
                QuestionView(showViews: showViews)
            }
        }
        .buttonStyle(DefaultButtonStyle())
    }
}
