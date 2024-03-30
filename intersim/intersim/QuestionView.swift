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
    @State private var textResponse = "Type your response here."
    @State private var audioURL: URL? = nil
    
    @ViewBuilder
    func SubmitButton() -> some View {
        Button {
            var response = Response()
            response.username = User.shared.getUsername()
            response.interviewID = interviewInstance.getInterviewId()
            response.questionID = interviewInstance.getQuestionId(index: self.questionIndex)
            
            if showTextView {
                response.textResponse = textResponse
            } else {
                do {
                    response.audioResponse = try Data(contentsOf: audioURL!)
                } catch {
                    print("error getting audio data")
                }
            }
            
            interviewInstance.postResponse(response: response)
            
            if questionIndex + 1 == interviewInstance.getQuestionsCount() {
                presentFeedbackView = true
            }
            else {
                questionIndex += 1
                textResponse = "Type your response here."
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
                TextView(textResponse: $textResponse)
            }
            else {
                AudioView(didFinishRecording: { url in
                    self.audioURL = url
                    print("got audio!")
                })
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
