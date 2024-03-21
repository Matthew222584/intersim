//
//  MainView.swift
//  swiftUIChatter
//
//  Created by Isley Sepulveda on 2/7/24.
//

import SwiftUI

struct MainView: View {
    private let store = ResponseStore.shared
    @State private var isPresenting = false
    @State private var initialized = false
    var body: some View {
        Button {
            initialized.toggle()
        } label: {
            Text("Start an interview!")
        }
        List(store.responses.indices, id: \.self) {
            responseListRow(response: store.responses[$0])
                .listRowSeparator(.hidden)
                .listRowBackground(Color(($0 % 2 == 0) ? .systemGray5 : .systemGray6))
        }
        .listStyle(.plain)
        .refreshable {
            store.getResponses()
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
