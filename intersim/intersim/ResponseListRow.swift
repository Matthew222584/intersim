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
            if let textResponse = response.textResponse {
                Text(textResponse).padding(EdgeInsets(top: 8, leading: 0, bottom: 6, trailing: 0))
            }
        }
    }
}

