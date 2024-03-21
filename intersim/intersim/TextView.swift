//
//  TextView.swift
//  intersim
//
//  Created by Isley Sepulveda on 3/21/24.
//

import SwiftUI

struct TextView: View {
    @Binding var isPresented: Bool
    @State private var textResponse = "Type your response here."
    @State private var isPresenting = false
    @State private var questionText = "Describe a time you resolved a workplace conflict."
    let questionStoreInstance = QuestionStore.shared
    @State private var questionIndex = 0
    @State private var presentFeedbackView = false
    
    @ViewBuilder
    func SubmitButton() -> some View {
        Button {
            if questionIndex + 1 == questionStoreInstance.getQuestionsCount() {
                print("display feedback view")
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
            TextEditor(text: $textResponse)
                .padding(EdgeInsets(top:10, leading:18, bottom:0, trailing:4))
                .navigationTitle("Text Interview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement:.navigationBarTrailing) {
                        SubmitButton()
                    }
                }
                .onTapGesture {
                    // dismiss virtual keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        }
        .sheet(isPresented: $presentFeedbackView) {
            FeedbackView()
        }
    }
}
