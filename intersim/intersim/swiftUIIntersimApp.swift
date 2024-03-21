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
        ResponseStore.shared.getResponses()
    }
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainView()
            }
        }
    }
}
