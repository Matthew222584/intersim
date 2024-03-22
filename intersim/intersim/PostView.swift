//
//  PostView.swift
//  swiftUIIntersim
//
//  Created by Isley Sepulveda on 2/7/24.
//

import SwiftUI

struct PostView: View {
    @Binding var isPresented: Bool
    @State private var interviewID = "0"
    @State private var questionText = ""
    @State private var textResponse = ""
    @State private var audioResponse = ""
    
    @ViewBuilder
    func SubmitButton() -> some View {
        Button {
            ResponseStore.shared.postResponse(
                Response(
                    questionText: questionText,
                    textResponse: textResponse,
                    audioResponse: audioResponse)
                ) {
                    ResponseStore.shared.getResponses()
                }
            isPresented.toggle()
        } label: {
            Image(systemName: "paperplane")
        }
    }
    var body: some View {
        VStack {
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
