//
//  MainView.swift
//  swiftUIChatter
//
//  Created by Isley Sepulveda on 2/7/24.
//

import SwiftUI

struct MainView: View {
    private let store = QuestionStore.shared
    @State private var isPresenting = false
    var body: some View {
        List(store.questions.indices, id: \.self) {
            QuestionListRow(question: store.questions[$0])
                .listRowSeparator(.hidden)
                .listRowBackground(Color(($0 % 2 == 0) ? .systemGray5 : .systemGray6))
        }
        .listStyle(.plain)
        .refreshable {
            store.getQuestions()
        }
        .navigationTitle("intersim")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement:.navigationBarLeading) {
                Button {
                    isPresenting.toggle() // TODO: Check isPresenting dupe for other toolbar
                } label: {
                    Image(systemName: "gearshape")
                }
            }
            ToolbarItem(placement:.navigationBarTrailing) {
                Button {
                    isPresenting.toggle()
                } label: {
                    Image(systemName: "person.fill")
                }
            }
        }
        .navigationDestination(isPresented: $isPresenting) {
            PostView(isPresented: $isPresenting)
        }  
    }
}


/*#Preview {
    MainView()
}
*/
