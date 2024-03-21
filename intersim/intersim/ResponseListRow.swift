//
//  questionListRow.swift
//  swiftUIChatter
//
//  Created by Isley Sepulveda on 2/7/24.
//

import SwiftUI

struct responseListRow: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    @State private var isPresenting = false
    let response: Response
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let username = response.username, let timestamp = response.timestamp {
                    Text(username).padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                    Spacer()
                    Text(timestamp).padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                }
            }
            if let textResponse = response.textResponse {
                Text(textResponse).padding(EdgeInsets(top: 8, leading: 0, bottom: 6, trailing: 0))
            }
        }
    }
}

