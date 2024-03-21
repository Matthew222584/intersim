//
//  Question.swift
//  swiftUIChatter
//
//  Created by Isley Sepulveda on 2/7/24.
//

struct Question {
    var username: String?
    var interviewID: String?
    var questionText: String?
    @OptionalizedEmpty var textResponse: String?
    @OptionalizedEmpty var audioResponse: String?
    @OptionalizedEmpty var videoResponse: String?
    var timestamp: String?
}

@propertyWrapper
struct OptionalizedEmpty {
    private var _value: String?
    var wrappedValue: String? {
        get { _value }
        set {
            guard let newValue else {
                _value = nil
                return
            }
            _value = (newValue == "null" || newValue.isEmpty) ? nil : newValue
        }
    }
    
    init(wrappedValue: String?) {
        self.wrappedValue = wrappedValue
    }
}
