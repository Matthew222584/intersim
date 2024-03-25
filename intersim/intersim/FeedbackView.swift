//
//  FeedbackView.swift
//  intersim
//
//  Created by Kyle on 3/21/24.
//

import SwiftUI

struct FeedbackView: View {
    let interviewInstance = Interview.shared
    
    var body: some View {
        NavigationView {
            List(interviewInstance.feedback!, id: \.self) { item in
                Text(item)
            }
            .refreshable {
                interviewInstance.getFeedback()
            }
        }
        .onAppear() {
            interviewInstance.getFeedback()
        }
    }
}
