//
//  FeedbackView.swift
//  intersim
//
//  Created by Kyle on 3/21/24.
//

import SwiftUI
import Charts
import Combine

struct FeedbackView: View {
    let interviewInstance = Interview.shared
    @State var items: [FeedbackUnit] = []
    @State var initialized = false
    @State private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @State private var cancellable: AnyCancellable?
    
    func updateItems() {
        self.items = interviewInstance.feedback
        if !items.isEmpty {
            cancellable?.cancel()  // Cancel the timer when feedback data is received
        }
    }
    
    @ViewBuilder
    func ItemsView(for item:FeedbackUnit) -> some View {
        HStack {
            VStack {
                Text(item.Question)
                    .fontWeight(.bold)
                    .font(.title)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                Text(item.Response)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
            }
            .frame(maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 10)
                    .fill(Color.white)
            )
            Chart(item.Emotions, id: \.Name) { emotion in
                BarMark(
                    x: .value("Emotion", emotion.Name),
                    y: .value("Percentage", emotion.Percentage)
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
                    .fill(Color.black)
            )
            .padding(.horizontal)
        }
        .padding()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ForEach(items, id: \.Question) { item in
                        ItemsView(for: item)
                }
                Spacer()
                Button {
                    initialized.toggle()
                } label: {
                    Text("Start another interview")
                    Image(systemName: "arrowshape.backward.fill")
                }
            }
//            .frame(maxWidth: )
            .navigationTitle("feedback")
            .navigationDestination(isPresented: $initialized) {
                MainView()
            }
            .buttonStyle(DefaultButtonStyle())
        }
        .onAppear() {
            interviewInstance.fetchFeedback()
            updateItems()
            cancellable = timer
                .sink { _ in
                    interviewInstance.fetchFeedback()
                    updateItems()
                }
        }
        .onDisappear {
            cancellable?.cancel()  // Cancel the timer when the view disappears
        }
    }
}
