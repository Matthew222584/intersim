//
//  swiftUIChatterApp.swift
//  swiftUIChatter
//
//  Created by Isley Sepulveda on 2/7/24.
//

import SwiftUI

@main
struct swiftUIChatterApp: App {
    init() {
        ChattStore.shared.getChatts()
    }
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainView()
            }
        }
    }
}
