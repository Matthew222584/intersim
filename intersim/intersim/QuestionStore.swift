//
//  QuestionStore.swift
//  swiftUIChatter
//
//  Created by Isley Sepulveda on 2/7/24.
//
import SwiftUI
import Observation

@Observable
final class QuestionStore {
    static let shared = QuestionStore() // create one instance of the class to be shared
    private init() {}                // and make the constructor private so no other
                                     // instances can be created
    private(set) var questions = [Question]()
    private let nFields = Mirror(reflecting: Question()).children.count

    private let serverUrl = "https://3.133.127.223/"
    
    func getQuestions() {
        guard let apiUrl = URL(string: "\(serverUrl)getquestions/") else {
            print("getQuestions: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept") // expect response in JSON
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("getQuestions: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getQuestions: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getQuestions: failed JSON deserialization")
                return
            }
            let questionsReceived = jsonObj["questions"] as? [[String?]] ?? []
            
            DispatchQueue.main.async {
                self.questions = [Question]()
                for questionEntry in questionsReceived {
                    if questionEntry.count == self.nFields {
                        self.questions.append(Question(username: questionEntry[0],
                                                interviewID: questionEntry[1],
                                                questionText: questionEntry[2],
                                                textResponse: questionEntry[3],
                                                audioResponse: questionEntry[4],
                                                videoResponse: questionEntry[5],
                                                timestamp: questionEntry[6]))
                    } else {
                        print("getQuestions: Received unexpected number of fields: \(questionEntry.count) instead of \(self.nFields).")
                    }
                }
            }
        }.resume()
    }
    func postQuestion(_ question: Question, completion: @escaping () -> ()) {
        let jsonObj = ["username": question.username,
                       "interviewID": question.interviewID,
                       "questionText": question.questionText,
                       "textResponse": question.textResponse,
                       "audioResponse": question.audioResponse,
                       "videoResponse": question.videoResponse,
                       "timestamp": question.timestamp]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("postQuestion: jsonData serialization error")
            return
        }
                
        guard let apiUrl = URL(string: "\(serverUrl)postquestion/") else {
            print("postQuestion: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("postQuestion: NETWORKING ERROR")
                return
            }

            if let httpStatus = response as? HTTPURLResponse {
                if httpStatus.statusCode != 200 {
                    print("postQuestion: HTTP STATUS: \(httpStatus.statusCode)")
                    return
                } else {
                    completion()
                }
            }

        }.resume()
    }
}
