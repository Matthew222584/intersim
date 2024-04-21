//
//  TextView.swift
//  intersim
//
//  Created by Isley Sepulveda on 3/21/24.
//

import SwiftUI

struct TextView: View {
    @Binding var textResponse : String
    @State private var presentFeedbackView = false
    
    var body: some View {
        VStack {
            TextEditor(text: $textResponse)
        }
        .padding(EdgeInsets(top:10, leading:18, bottom:0, trailing:4))
        .navigationTitle("Text Interview")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .sheet(isPresented: $presentFeedbackView) {
            FeedbackView(showViews: [true, false, false])
        }
    }
}
