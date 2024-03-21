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
    @State private var initialized = false
    var body: some View {
        Button {
            initialized.toggle()
        } label: {
            Text("Start an interview!")
        }
        List(store.questions.indices, id: \.self) {
            questionListRow(question: store.questions[$0])
                .listRowSeparator(.hidden)
                .listRowBackground(Color(($0 % 2 == 0) ? .systemGray5 : .systemGray6))
        }
        .listStyle(.plain)
        .refreshable {
            store.getQuestions()
        }
        .navigationTitle("intersim")
        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement:.navigationBarLeading) {
//                Button {
//                    isPresenting.toggle() // TODO: Check isPresenting dupe for other toolbar
//                } label: {
//                    Image(systemName: "gearshape")
//                }
//            }
//            ToolbarItem(placement:.navigationBarTrailing) {
//                Button {
//                    isPresenting.toggle()
//                } label: {
//                    Image(systemName: "person.fill")
//                }
//            }
//        } TODO: Implement settings/profile (check if we're actually doing that)
        .navigationDestination(isPresented: $isPresenting) {
            PostView(isPresented: $isPresenting)
        }  
        .navigationDestination(isPresented: $initialized) {
            StartView(isPresented: $initialized)
        }
    }
}


/*#Preview {
    MainView()
}
*/
