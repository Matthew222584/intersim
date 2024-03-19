//
//  swiftUIIntersimApp.swift
//  swiftUIIntersim
//
//  Created by Isley Sepulveda on 2/7/24.
//

import SwiftUI

@main
struct swiftUIIntersimApp: App {
    init() {
        QuestionStore.shared.getQuestions()
    }
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainView()
            }
        }
    }
}
