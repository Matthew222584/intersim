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
    
    func updateItems() {
        self.items = interviewInstance.feedback
    }
    
    var body: some View {
        NavigationView {
            List(items, id: \.self) { item in
                Text(item)
            }
            .refreshable {
                interviewInstance.getFeedback()
                updateItems()
            }
        }
        .onAppear() {
            interviewInstance.getFeedback()
        }
    }
}
