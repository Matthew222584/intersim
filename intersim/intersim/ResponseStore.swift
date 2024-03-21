//
//  QuestionStore.swift
//  swiftUIChatter
//
//  Created by Isley Sepulveda on 2/7/24.
//
import SwiftUI
import Observation

@Observable
final class ResponseStore {
    static let shared = ResponseStore() // create one instance of the class to be shared
    private init() {}                // and make the constructor private so no other
                                     // instances can be created
    private(set) var responses = [Response]()
    private let nFields = Mirror(reflecting: Response()).children.count

    private let serverUrl = "https://3.133.127.223/"
    
    func getResponses() {
        guard let apiUrl = URL(string: "\(serverUrl)getresponses/") else {
            print("getResponses: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept") // expect response in JSON
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("getResponses: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getResponses: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getResponses: failed JSON deserialization")
                return
            }
            let responsesReceived = jsonObj["responses"] as? [[String?]] ?? []
            
            DispatchQueue.main.async {
                self.responses = [Response]()
                for responseEntry in responsesReceived {
                    if responseEntry.count == self.nFields {
                        self.responses.append(Response(username: responseEntry[0],
                                                interviewID: responseEntry[1],
                                                questionText: responseEntry[2],
                                                textResponse: responseEntry[3],
                                                audioResponse: responseEntry[4],
                                                videoResponse: responseEntry[5],
                                                timestamp: responseEntry[6]))
                    } else {
                        print("getResponses: Received unexpected number of fields: \(responseEntry.count) instead of \(self.nFields).")
                    }
                }
            }
        }.resume()
    }
    func postResponse(_ response: Response, completion: @escaping () -> ()) {
        let jsonObj = ["username": response.username,
                       "interviewID": response.interviewID,
                       "questionText": response.questionText,
                       "textResponse": response.textResponse,
                       "audioResponse": response.audioResponse,
                       "videoResponse": response.videoResponse,
                       "timestamp": response.timestamp]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("postResponse: jsonData serialization error")
            return
        }
                
        guard let apiUrl = URL(string: "\(serverUrl)postresponse/") else {
            print("postResponse: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("postResponse: NETWORKING ERROR")
                return
            }

            if let httpStatus = response as? HTTPURLResponse {
                if httpStatus.statusCode != 200 {
                    print("postResponse: HTTP STATUS: \(httpStatus.statusCode)")
                    return
                } else {
                    completion()
                }
            }

        }.resume()
    }
}
