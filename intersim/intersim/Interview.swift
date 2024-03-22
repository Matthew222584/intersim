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
    private let serverUrl = "https://3.144.9.248/"
    
    private init() {
        fetchQuestions()
    }
    
    func postResponse(response: Response) {
        guard let apiUrl = URL(string: "\(serverUrl)postanswers/") else {
            print("postResponse: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        
        let body: [String: Any] = [
            "username": response.username,
            "interview_id": response.interviewID!,
            "question_id": response.questionID!,
            "question_answer": response.textResponse!,
            "audio": "null",
            "video_file_path": "null"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Failed to serialize JSON data")
            return
        }
        
        request.httpBody = jsonData
        
        print(request)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data, let response = response as? HTTPURLResponse {
                print("Response: \(response.statusCode)")
            }
        }.resume()
    }
    
    private func fetchQuestions() {
        guard var apiUrl = URLComponents(string: "\(serverUrl)getquestions/") else {
            print("getQuestions: Bad URL")
            return
        }
        apiUrl.queryItems = [
            URLQueryItem(name: "username", value: "testuser"),
            URLQueryItem(name: "num_questions", value: "3")
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
}
