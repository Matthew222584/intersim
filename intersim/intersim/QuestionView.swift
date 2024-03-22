//
//  QuestionView.swift
//  intersim
//
//  Created by Kyle on 3/21/24.
//

import SwiftUI

struct QuestionView: View {
    let interviewInstance = Interview.shared
    var showTextView: Bool
    @State private var questionIndex = 0
    @State private var presentFeedbackView = false
    @State private var responseText = "Type your response here."
    
    @ViewBuilder
    func SubmitButton() -> some View {
        Button {
            var response = Response()
            response.interviewID = interviewInstance.getInterviewId()
            response.questionID = interviewInstance.getQuestionId(index: self.questionIndex)
            response.textResponse = responseText
            interviewInstance.postResponse(response: response)
            
            if questionIndex + 1 == interviewInstance.getQuestionsCount() {
                presentFeedbackView = true
            }
            else {
                questionIndex += 1
                responseText = "Type your response here."
            }
        } label: {
            Text("Submit")
            Image(systemName: "paperplane")
        }
    }
    
    var body: some View {
        VStack {
            Text(interviewInstance.getQuestion(index: self.questionIndex))
            if showTextView {
                TextView(textResponse: $responseText)
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
        .fullScreenCover(isPresented: $presentFeedbackView) {
            FeedbackView()
        }
    }
}
