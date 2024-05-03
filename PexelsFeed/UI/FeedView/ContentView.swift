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
                if viewModel.photosUIModels.isEmpty {
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
                ForEach(viewModel.photosUIModels, id: \.id) { photo in
                    NavigationLink(destination: DetailView(photo: photo.photo)) {
                        VStack {
                            Color.clear.overlay(
                                CachedAsyncImage(url: URL(string: photo.photo.source.large)!)
                            )
                            .frame(height: 150)
                            .clipped()
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            Text(photo.photo.photographer)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .onAppear {
                            if photo == viewModel.photosUIModels.last {
                                viewModel.loadPhotosAsync()
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.reloadAsync()
        }
    }
}
