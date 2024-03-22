//
//  QuestionView.swift
//  intersim
//
//  Created by Kyle on 3/21/24.
//

import SwiftUI

struct QuestionView: View {
    let questionStoreInstance = QuestionStore.shared
    @State private var questionIndex = 0
    @State private var presentFeedbackView = false
    var showTextView: Bool
    
    @ViewBuilder
    func SubmitButton() -> some View {
        Button {
            if questionIndex + 1 == questionStoreInstance.getQuestionsCount() {
                presentFeedbackView = true
            }
            else {
                questionIndex += 1
                // TODO: post response
            }
        } label: {
            Text("Submit")
            Image(systemName: "paperplane")
        }
    }
    
    var body: some View {
        VStack {
            Text(questionStoreInstance.getQuestion(index: self.questionIndex))
            if showTextView {
                TextView()
            }
            else {
                AudioView()
            }
        }
        .toolbar {
            ToolbarItem(placement:.navigationBarTrailing) {
                SubmitButton()
            }
        }
        .sheet(isPresented: $presentFeedbackView) {
            FeedbackView()
        }
    }
}

