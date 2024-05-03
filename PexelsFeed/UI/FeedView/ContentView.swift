// ContentView.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 03.05.2024.

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
                    photoCell(photo)
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.reloadAsync()
        }
    }

    @ViewBuilder
    fileprivate func photoCell(_ model: PhotoUIModel) -> NavigationLink<some View, DetailView> {
        NavigationLink(destination: DetailView(photo: model.photo)) {
            VStack {
                Color.clear.overlay(
                    CachedAsyncImage(url: URL(string: model.photo.source.large)!)
                )
                .frame(height: 150)
                .clipped()
                .cornerRadius(10)
                .shadow(radius: 5)
                Text(model.photo.photographer)
                    .font(.caption)
                    .lineLimit(1)
            }
            .onAppear {
                if model == viewModel.photosUIModels.last {
                    viewModel.loadPhotosAsync()
                }
            }
        }
    }
}
