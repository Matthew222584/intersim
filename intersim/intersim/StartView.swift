//
//  StartView.swift
//  intersim
//
//  Created by Isley Sepulveda on 3/20/24.
//

import SwiftUI

struct StartView: View {
    @Binding var isPresented: Bool
    @State private var isPresenting = false
    @State private var text = true
    
    @ViewBuilder
    func TextButton() -> some View {
        Button {
            text = true
            isPresented.toggle()
        } label: {
            Text("Text")
            Image(systemName: "doc.text")
        }
    }
    
    @ViewBuilder
    func AudioButton() -> some View {
        Button {
            text = true
            isPresented.toggle()
        } label: {
            Text("Audio")
            Image(systemName: "mic")
        }
    }
    
    var body: some View {
        VStack {
            Text("Choose an interview type.")
                .padding(.top, 30.0)
            Spacer()
            HStack {
                TextButton()
                AudioButton()
            }
        }
    }
}
