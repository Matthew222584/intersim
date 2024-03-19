//
//  PostView.swift
//  swiftUIIntersim
//
//  Created by Isley Sepulveda on 2/7/24.
//

import SwiftUI

struct PostView: View {
    @Binding var isPresented: Bool

    private let username = "isleysep"
    @State private var interviewID = "0"
    @State private var questionText = ""
    @State private var textResponse = ""
    @State private var audioResponse = ""
    @State private var videoResponse = ""
    @State private var timestamp = ""
    @ViewBuilder
    func SubmitButton() -> some View {
        Button {
            QuestionStore.shared.postQuestion(Question(
                username: username,
                interviewID: interviewID,
                questionText: questionText,
                textResponse: textResponse,
                audioResponse: audioResponse,
                videoResponse: videoResponse,
                timestamp: timestamp)) {
                QuestionStore.shared.getQuestions()
        }
            isPresented.toggle()
        } label: {
            Image(systemName: "paperplane")
        }
    }
    var body: some View {
        VStack {
            Text(username)
                .padding(.top, 30.0)
            TextEditor(text: $questionText)
                .padding(EdgeInsets(top: 10, leading: 18, bottom: 0, trailing: 4))
                .navigationTitle("Post")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement:.navigationBarTrailing) {
                        SubmitButton()
                    }
                }
        }
    } //TODO: update to interview ui
}
