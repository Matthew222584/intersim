//
//  User.swift
//  intersim
//
//  Created by Isley Sepulveda on 3/29/24.
//

import Foundation

class User {
    static let shared = User()
    private var username = ""
    
    private init() {}
    
    func setUsername(username: String) {
        self.username = username
    }
    
    func getUsername() -> String {
        return self.username
    }
}
