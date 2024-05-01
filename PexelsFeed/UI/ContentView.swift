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
        NavigationView {
            Group {
                if viewModel.isLoading {
                    loader
                } else {
                    grid
                }
            }
            .navigationTitle("Pexels Feed")
            .onAppear {
                viewModel.loadPhotos()
            }
        }
    }
    
    @ViewBuilder
    var grid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(viewModel.photos, id: \.id) { photo in
                    VStack {
                        AsyncImage(url: URL(string: photo.source.medium))
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 5)
                        Text(photo.photographer)
                            .font(.caption)
                    }
                    .padding(.horizontal)
                }
            }
        }

    }
    
    @ViewBuilder
    var loader: some View {
        ProgressView()
    }
}

//#Preview {
//    ContentView()
//}
