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
    
    @ViewBuilder
    func SubmitButton() -> some View {
        Button {
            ResponseStore.shared.postResponse(Response(
                username: "isleysep",
                interviewID: "0",
                questionText: questionText,
                textResponse: textResponse,
                audioResponse: nil,
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
            TextEditor(text: $textResponse)
                .padding(EdgeInsets(top:10, leading:18, bottom:0, trailing:4))
                .navigationTitle("Text Interview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement:.navigationBarTrailing) {
                        SubmitButton()
                    }
                }
        }
    }
}
