//
//  MainView.swift
//  swiftUIChatter
//
//  Created by Isley Sepulveda on 2/7/24.
//

import SwiftUI

struct MainView: View {
    private let store = ChattStore.shared
    @State private var isPresenting = false
    var body: some View {
        List(store.chatts.indices, id: \.self) {
            ChattListRow(chatt: store.chatts[$0])
                .listRowSeparator(.hidden)
                .listRowBackground(Color(($0 % 2 == 0) ? .systemGray5 : .systemGray6))
        }
        .listStyle(.plain)
        .refreshable {
            store.getChatts()
        }
        .navigationTitle("Chatter")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement:.navigationBarTrailing) {
                Button {
                    isPresenting.toggle()
                } label: {
                    Image(systemName: "square.and.pencil")
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
