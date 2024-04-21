import SwiftUI

struct QuestionView: View {
    let interviewInstance = Interview.shared
    var showViews: [Bool]
    @State private var questionIndex = 0
    @State private var presentFeedbackView = false
    @State private var textResponse = "Type your response here."
    @State private var audioURL: URL? = nil
    @State private var videoURL: URL? = nil
    
    private func postResponse() {
        var response = Response(username: User.shared.getUsername(),
                                interviewID: interviewInstance.getInterviewId(),
                                questionID: interviewInstance.getQuestionId(index: self.questionIndex))
        
        response.textResponse = textResponse
        
        if showViews[1], let audioURL = audioURL {
            do {
                response.audioResponse = try Data(contentsOf: audioURL)
            } catch {
                print("error getting audio data")
            }
        } else if showViews[2], let videoUrl = videoURL {
            do {
                response.videoResponse = try Data(contentsOf: videoUrl)
            } catch {
                print("error getting video data")
            }
        }
        
        interviewInstance.postResponse(response: response)
    }
    
    private func updateQuestion() {
        if questionIndex + 1 == interviewInstance.getQuestionsCount() {
            presentFeedbackView = true
        } else {
            questionIndex += 1
            textResponse = "Type your response here."
        }
    }
    
    private func presentView() -> some View {
        if showViews[0] {
            return AnyView(TextView(textResponse: $textResponse))
        } else if showViews[1] {
            return AnyView(AudioView(didFinishRecording: { url, text in
                self.audioURL = url
                self.textResponse = text
            }))
        } else {
            return AnyView(VideoView(didFinishRecording: { url, text in
                self.videoURL = url
                self.textResponse = text
            }))
        }
    }
    
    @ViewBuilder
    func SubmitButton() -> some View {
        Button(action: {
            postResponse()
            updateQuestion()
        }) {
            Text("Submit")
            Image(systemName: "paperplane")
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text(interviewInstance.getQuestion(index: self.questionIndex))
                .font(.title)
            Spacer()
            presentView()
                .aspectRatio(CGSize(width: 9, height: 16), contentMode: .fit)
                .frame(maxWidth: 800, maxHeight: 1000)
        }
        .toolbar {
            ToolbarItem(placement:.navigationBarTrailing) {
                SubmitButton()
            }
        }
        .fullScreenCover(isPresented: $presentFeedbackView) {
            FeedbackView(showViews: showViews)
        }
        .id(questionIndex)
    }
}
