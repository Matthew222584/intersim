//
//  Interview.swift
//  intersim
//
//  Created by Kyle on 3/21/24.
//

import Foundation

class Interview {
    static let shared = Interview()
    private var questions: [String] = []
    private var questionIds: [String] = []
    private var numQuestions = 0
    private var interviewId = 0
    private var username = ""
    private let serverUrl = "https://18.219.139.85/"
    var feedback: [String] = []
    
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
            "question_answer": "this is a test", //response.textResponse ?? ""
            "audio": response.audioResponse?.base64EncodedString() ?? "",
            "video": response.videoResponse?.base64EncodedString() ?? ""
        ]
        
        print(body)
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Failed to serialize JSON data")
            return
        }
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let _ = data, let response = response as? HTTPURLResponse {
                print(response)
                print("Response: \(response.statusCode)")
            }
        }.resume()
    }
    
    private func fetchQuestions() {
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
            } else {
                print("fetchQuestions: failed to get interview id")
            }
            if let questionsRecv = jsonObj["questions"] as? [[String: String]] {
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
        
        print(request)
        
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

            for item in responseData {
                if let questionContent = item["question_content"] as? String {
                    print(questionContent)
                }
                if let textResponse = item["text_response"] as? String {
                    print(textResponse)
                }
                if let sentiment_results = item["sentiment_results"] as? [Any] {
                    print(sentiment_results)
                }
            }
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
