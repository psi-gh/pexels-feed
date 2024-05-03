// ContentView.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 02.05.2024.

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ContentViewModel
    var body: some View {
        NavigationStack {
            Group {
                grid
            }
            .navigationTitle("Pexels Feed")
            .onAppear {
                if viewModel.photos.isEmpty {
                    viewModel.loadPhotosAsync()
                }
            }
        }
    }
    
    @ViewBuilder
    var grid: some View {
        let columns = [
            GridItem(.adaptive(minimum: 120, maximum: 190), spacing: 20),
        ]

        ScrollView(.vertical) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.photos, id: \.id) { photo in
                    VStack {
                        Color.clear.overlay(
                            AsyncImage(url: URL(string: photo.source.large)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else if phase.error != nil {
                                    Color.red
                                    let _ = print("‼️" + (phase.error?.getDescription() ?? ""))
                                } else {
                                    ProgressView()
                                }
                            }
                        )
                        .aspectRatio(9 / 16, contentMode: .fill)
                        .clipped()
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        
                        Text(photo.photographer)
                            .font(.caption)
                    }
                    .onAppear {
                        if photo == viewModel.photos.last {
                            viewModel.loadPhotos()
                        }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            viewModel.reload()
        }
    }
}
