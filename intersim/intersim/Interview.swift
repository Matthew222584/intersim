//
//  Interview.swift
//  intersim
//
//  Created by Kyle on 3/21/24.
//

import Foundation

struct Emotion: Identifiable, Comparable {
    var id: String { Name }
    var Name:String
    var Percentage:Double
    
    static func <(lhs: Emotion, rhs: Emotion) -> Bool {
        return lhs.Percentage > rhs.Percentage // Sort in descending order by percentage
    }
}

struct FeedbackUnit {
    var Question:String
    var Response:String
    var Sentiment:[Emotion]?
    var Tone:[Emotion]?
    var Facial:[Emotion]?
}

class Interview {
    static let shared = Interview()
    private var questions: [String] = []
    private var questionIds: [String] = []
    private var numQuestions = 0
    private var interviewId = 0
    private var username = ""
    private let serverUrl = "https://18.221.19.88/"
    var feedback: [FeedbackUnit] = []
    
    private init() {
        self.username = User.shared.getUsername()
        fetchQuestions()
    }
    
    func postResponse(response: Response) {
        guard let apiUrl = URL(string: "\(serverUrl)postresponse/") else {
            print("postResponse: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        
        let body: [String: Any] = [
            "username": response.username,
            "interview_id": response.interviewID ,
            "question_id": response.questionID,
            "question_answer": response.textResponse ?? "",
            "audio": response.audioResponse?.base64EncodedString() ?? "",
            "video": response.videoResponse?.base64EncodedString() ?? ""
        ]
        
        //print(body)
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Failed to serialize JSON data")
            return
        }
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let _ = data, let response = response as? HTTPURLResponse {
                //print(response)
                print("Response: \(response.statusCode)")
            }
        }.resume()
    }
    
    public func fetchQuestions() {
        guard var apiUrl = URLComponents(string: "\(serverUrl)getquestions/") else {
            print("fetchQuestions: Bad URL")
            return
        }
        apiUrl.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "num_questions", value: "2")
        ]
        
        var request = URLRequest(url: apiUrl.url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("fetchQuestions: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("fetchQuestions: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("fetchQuestions: failed JSON deserialization")
                return
            }
            
            if let id = jsonObj["interview_id"] as? Int {
                self.interviewId = id
                print(id)
            } else {
                print("fetchQuestions: failed to get interview id")
            }
            if let questionsRecv = jsonObj["questions"] as? [[String: String]] {
                self.questions = []
                self.questionIds = []
                self.numQuestions = 0
                
                for questionDict in questionsRecv {
                    if let questionId = questionDict.keys.first,
                       let questionText = questionDict.values.first {
                        self.questions.append(questionText)
                        self.questionIds.append(questionId)
                        self.numQuestions += 1
                    }
                }
            } else {
                print("fetchQuestions: failed to parse questions")
            }
        }.resume()
    }
    
    func fetchFeedback() {
        guard var apiUrl = URLComponents(string: "\(serverUrl)getfeedback/") else {
            print("getFeedback: Bad URL")
            return
        }
        apiUrl.queryItems = [
            URLQueryItem(name: "username", value: "testuser"),
            URLQueryItem(name: "interview_id", value: String(self.interviewId))
        ]
        
        var request = URLRequest(url: apiUrl.url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("getFeedback: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getFeedback: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("getFeedback: failed JSON deserialization")
                return
            }
            
            guard let responseData = jsonObj["response_data"] as? [[String: Any]] else {
                print("Error: Unable to extract response_data from JSON")
                return
            }
            
            var feedback: [FeedbackUnit] = []
            
            for item in responseData {
                var unit = FeedbackUnit(Question: "", Response: "")
                
                if let questionContent = item["question_content"] as? String {
                    unit.Question = questionContent
                    print(questionContent)
                }
                if let textResponse = item["text_response"] as? String {
                    print(textResponse)
                    unit.Response = textResponse
                }
                
                // sentiment
                var sentimentEmotions: [Emotion] = []
                if let sentimentResults = item["sentiment_results"] as? [[Any]], !sentimentResults.isEmpty {
                    for result in sentimentResults {
                        if let emotion = result.first as? String, let value = result.last as? Double {
                            sentimentEmotions.append(Emotion(Name: emotion, Percentage: value * 100))
                            print("Sentiment: \(emotion), Value: \(value)")
                        }
                    }
                    unit.Sentiment = sentimentEmotions
                }
                
                // tone
                var toneEmotions: [Emotion] = []
                if let toneResults = item["speech_emotion_results"] as? [[Any]], !toneResults.isEmpty {
                    for result in toneResults {
                        if let emotion = result.first as? String, let value = result.last as? Double {
                            toneEmotions.append(Emotion(Name: emotion, Percentage: value * 100))
                            print("Tone: \(emotion), Value: \(value)")
                        }
                    }
                    unit.Tone = toneEmotions
                }
                
                // facial
    //            var facialEmotions: [Emotion] = []
    //            if let facialResults = item["facial_emotion"] as? [[Any]] {
    //                for result in facialResults {
    //                    if let emotion = result.first as? String, let value = result.last as? Double {
    //                        facialEmotions.append(Emotion(Name: emotion, Percentage: value * 100))
    //                        print("Emotion: \(emotion), Value: \(value)")
    //                    }
    //                }
    //                unit.Facial = facialEmotions
    //            }
                
                feedback.append(unit)
            }
            
            self.feedback = feedback
        }.resume()
    }
    
    func getQuestion(index: Int) -> String {
        return questions[index]
    }
    
    func getQuestionsCount() -> Int {
        return numQuestions
    }
    
    func getInterviewId() -> Int {
        return interviewId
    }
    
    func getQuestionId(index: Int) -> Int {
        return Int(questionIds[index])!
    }
    
    func setUsername(username: String) {
        self.username = username
    }
}
