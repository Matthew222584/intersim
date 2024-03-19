//
//  interviewListRow.swift
//  swiftUIChatter
//
//  Created by Isley Sepulveda on 2/7/24.
//

import SwiftUI

struct interviewListRow: View {
    let interview: Interview
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let username = interview.username, let timestamp = interview.timestamp {
                    Text(username).padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                    Spacer()
                    Text(timestamp).padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                }
            }
            if let message = interview.message {
                Text(message).padding(EdgeInsets(top: 8, leading: 0, bottom: 6, trailing: 0))
            }
        }
    }
}

