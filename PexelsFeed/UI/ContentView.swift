//
//  ContentView.swift
//  PexelsFeed
//
//  Created by Pavel Ivanov on 01.05.2024.
//

import SwiftUI

struct ContentView: View {
    let viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .onTapGesture {
                    viewModel.tap()
                }
            Text("Hello, world!")
        }
        .padding()
    }
}

//#Preview {
//    ContentView()
//}
