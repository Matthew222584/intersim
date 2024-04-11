//
//  QuestionView.swift
//  intersim
//
//  Created by Kyle on 3/21/24.
//

import SwiftUI

struct QuestionView: View {
    let interviewInstance = Interview.shared
    var showViews: [Bool]
    @State private var questionIndex = 0
    @State private var presentFeedbackView = false
    @State private var textResponse = "Type your response here."
    @State private var audioURL: URL? = nil
    
    private func postResponse() {
        var response = Response(username: User.shared.getUsername(),
                                interviewID: interviewInstance.getInterviewId(),
                                questionID: interviewInstance.getQuestionId(index: self.questionIndex))
        
        if showViews[0] {
            response.textResponse = textResponse
        } else if showViews[1] {
            do {
                response.audioResponse = try Data(contentsOf: audioURL!)
            } catch {
                print("error getting audio data")
            }
        } else {
            print("TODO: post video")
        }
        
        interviewInstance.postResponse(response: response)
    }
    
    private func updateQuestion() {
        if questionIndex + 1 == interviewInstance.getQuestionsCount() {
            presentFeedbackView = true
        }
        else {
            questionIndex += 1
            textResponse = "Type your response here."
        }
    }
    
    private func presentView() -> some View {
        if showViews[0] {
            return AnyView(TextView(textResponse: $textResponse))
        } else if showViews[1] {
            return AnyView(AudioView(didFinishRecording: { url in
                self.audioURL = url
            }))
        } else {
            return AnyView(VideoView())
        }
    }
    
    @ViewBuilder
    func SubmitButton() -> some View {
        Button {
            postResponse()
            updateQuestion()
        } label: {
            Text("Submit")
            Image(systemName: "paperplane")
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text(interviewInstance.getQuestion(index: self.questionIndex))
            Spacer()
            presentView()
            Spacer()
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
