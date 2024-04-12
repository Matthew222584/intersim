//
//  FeedbackView.swift
//  intersim
//
//  Created by Kyle on 3/21/24.
//

import SwiftUI

struct FeedbackView: View {
    let interviewInstance = Interview.shared
    @State var items: [String] = []
    @State private var initialized = false
    
    func updateItems() {
        self.items = interviewInstance.feedback
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List(items, id: \.self) { item in
                    Text(item)
                }
                .refreshable {
                    interviewInstance.fetchFeedback()
                    updateItems()
                }
                Spacer()
                Button {
                    initialized.toggle()
                } label: {
                    Text("Start another interview")
                    Image(systemName: "arrowshape.backward.fill")
                }
            }
            .navigationTitle("feedback")
            .navigationDestination(isPresented: $initialized) {
                MainView()
            }
            .buttonStyle(DefaultButtonStyle())
        }
        .onAppear() {
            interviewInstance.fetchFeedback()
        }
    }
}
