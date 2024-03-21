//
//  QuestionsStore.swift
//  intersim
//
//  Created by Kyle on 3/21/24.
//

class QuestionStore {
    static let shared = QuestionStore()
    var questionindex = 0
    private var questions: [String] = []
    private var numQuestions = 0
    
    private init() {
        fetchQuestions()
    }
    
    private func fetchQuestions() {
        // TODO: get questions from server
        questions = ["Qustion 1", "Question 2"]
        numQuestions = questions.count
    }
    
    func getQuestion(index: Int) -> String {
        return questions[index]
    }
    
    func getQuestionsCount() -> Int {
        return numQuestions
    }
}
