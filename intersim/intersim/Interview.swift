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
    //For each response there is a API call that returns a dictionary
    //these arrays are arrays of dictionaries for each response
    private(set) var sentiment: [[String: String]] = []
    private(set) var speech: [[String: String]] = []
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
            "interview_id": response.interviewID ?? "null",
            "question_id": response.questionID ?? "null",
            "question_answer": response.textResponse ?? "null",
            "audio": response.audioResponse?.base64EncodedString() ?? "null",
            "video_file_path": "null"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Failed to serialize JSON data")
            return
        }
        
        request.httpBody = jsonData
        
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
    
    func getSentiment() {

        guard let apiSentiment = URL(string: "\(serverUrl)sentiment/") else {
            print("sentiments: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiSentiment)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept") // expect response in JSON
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("sentiments: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("sentiments: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("sentiments: failed JSON deserialization")
                return
            }
            //if line below doesn't work try: let chattsReceived = jsonObj["chatts"] as? //[[String?]] ?? [] and change sentiment at top to
            //private(set) var sentiment = [String]()
            let newSentiment = jsonObj["emotions"] as? [String: String] ?? [:]
            self.sentiment.append(newSentiment)
        }
        
    }
    func getSpeechToText() {
        
        guard let apiSpeech = URL(string: "\(serverUrl)speechToText/") else {
            print("speechToText: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiSpeech)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept") // expect response in JSON
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("speechToText: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("speechToText: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("speechToText: failed JSON deserialization")
                return
            }
            let newSpeech = jsonObj["emotions"] as? [String: String] ?? [:]
            self.speech.append(newSpeech)
        }

        }
    func postFeedback() -> String {

        let feedback = ""
        //TODO Iterate over each API dictionary (sentiment, speech) to create a string for each response
        //Then append each string to the overall response
        return feedback
       }
    }


