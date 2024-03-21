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
    @State private var textShown = false
    @State private var audioShown = false
    
    @ViewBuilder
    func TextButton() -> some View {
        Button {
            textShown.toggle()
        } label: {
            Text("Text")
            Image(systemName: "doc.text")
        }
    }
    
    @ViewBuilder
    func AudioButton() -> some View {
        Button {
            audioShown.toggle()
        } label: {
            Text("Audio")
            Image(systemName: "mic")
        }
    }
    
    var body: some View {
        VStack {
            Text("Choose an interview type.")
                .padding(.top, 30.0)
            HStack {
                TextButton()
                AudioButton()
            }
            .navigationTitle("Start")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $textShown) {
                TextView(isPresented: $textShown)
            }
//            .navigationDestination(isPresented: $audioShown) {
//                AudioView(isPresented: $audioShown)
//            }
        }
    }
}
