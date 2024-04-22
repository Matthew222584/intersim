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
    var showViews: [Bool]
    @State var items: [FeedbackUnit] = []
    @State var initialized = false
    @State var timeoutCounter = 0
    @State private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @State private var cancellable: AnyCancellable?
    
    func updateItems() {
        let itemCount = self.items.count
        self.items = interviewInstance.feedback
        timeoutCounter += 1
        if self.items.count > itemCount {
            timeoutCounter = 0
        }
        // if a minute has passed
        print(timeoutCounter * 3, " seconds with no response.")
        if timeoutCounter >= 20 {
            cancellable?.cancel()  // Cancel the timer when feedback data is received
        }
    }
    
    @ViewBuilder
    func ItemsView(for item:FeedbackUnit) -> some View {
        HStack {
            VStack {
                Text("Question: " + item.Question)
                    .fontWeight(.bold)
                    .font(.title)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .top)
                Text("Response: " + item.Response)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: 300, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 10)
                    .fill(Color.white)
            )
            HStack {
                // if sentiment items exist & in appropriate view
                if let sentiment = item.Sentiment, showViews[0] || showViews[1] {
                    VStack {
                        Text("Sentiment Top 3")
                            .font(.title)
                            .foregroundColor(.blue)
                            .padding(.bottom, 5)
                        ForEach(sentiment.sorted().prefix(3)) { emotion in
                            HStack {
                                Text(emotion.Name)
                                    .bold()
                                Spacer()
                                Text(String(format: "%.1f%%", emotion.Percentage))
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(LinearGradient(gradient: Gradient(colors: [.blue, .blue.opacity(0.5)]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                        }
                    }
                }
                // if tone items exist & in appropriate view
                if let tone = item.Tone, showViews[1] {
                    VStack {
                        Text("Tone Top 3")
                            .font(.title)
                            .foregroundColor(.blue)
                            .padding(.bottom, 5)
                        ForEach(tone) { emotion in
                            HStack {
                                Text(emotion.Name)
                                    .bold()
                                Spacer()
                                Text(String(format: "%.1f%%", emotion.Percentage))
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(LinearGradient(gradient: Gradient(colors: [.blue, .blue.opacity(0.5)]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
        }
        .padding()
        .frame(height: 400)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(items, id: \.Question) { item in
                            ItemsView(for: item)
                    }
                    Spacer()
                }
                .navigationTitle("feedback")
                .navigationDestination(isPresented: $initialized) {
                    MainView()
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
            Button {
                interviewInstance.fetchQuestions()
                interviewInstance.feedback = []
                initialized.toggle()
            } label: {
                Text("Start another interview")
                Image(systemName: "arrowshape.backward.fill")
            }
            .buttonStyle(DefaultButtonStyle())
        }
    }
}
