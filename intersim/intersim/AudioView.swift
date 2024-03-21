//
//  AudioView.swift
//  intersim
//
//  Created by Isley Sepulveda on 3/21/24.
//

import SwiftUI

struct AudioView: View {
    @Binding var isPresented: Bool
    @Environment(AudioPlayer.self) private var audioPlayer
    
    @State private var isPresenting = false
    @State private var questionText = "Describe a time you resolved a workplace conflict."
    
    @ViewBuilder
    func SubmitButton() -> some View {
        Button {
            ResponseStore.shared.postResponse(Response(
                username: "isleysep",
                interviewID: "0",
                questionText: questionText,
                textResponse: nil,
                audioResponse: audioPlayer.audio?.base64EncodedString(),
                videoResponse: nil)
            ) {
                isPresented.toggle()
            }
        } label: {
            Text("Submit")
            Image(systemName: "paperplane")
        }
    }
    
    var body: some View {
        VStack {
            Text(questionText)
                .padding(EdgeInsets(top:10, leading:18, bottom:0, trailing:4))
                .navigationTitle("Audio Interview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement:.navigationBarTrailing) {
                        SubmitButton()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        AudioButton(isPresenting: $isPresenting)
                    }
                }
                .fullScreenCover(isPresented: $isPresenting) {
                    AudioPlayerView(isPresented: $isPresenting, autoPlay: false)
                }
                .onAppear {
                    audioPlayer.setupRecorder()
                }
        }
    }
}

struct AudioButton: View {
    @Binding var isPresenting: Bool
    @Environment(AudioPlayer.self) private var audioPlayer

    var body: some View {
        Button {
            isPresenting.toggle()
        } label: {
            if let _ = audioPlayer.audio {
                Image(systemName: "mic.fill").padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)).scaleEffect(1.5).foregroundColor(Color(.systemRed))
            } else {
                Image(systemName: "mic").padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)).scaleEffect(1.5).foregroundColor(Color(.systemGreen))
            }
        }
    }
}
