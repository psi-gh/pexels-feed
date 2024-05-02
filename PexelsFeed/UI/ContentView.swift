// ContentView.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 02.05.2024.

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ContentViewModel

    var body: some View {
        NavigationView {
            Group {
                grid
            }
            .navigationTitle("Pexels Feed")
            .onAppear {
                viewModel.loadPhotos()
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
                            AsyncImage(url: URL(string: photo.source.large)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                        )
                        .aspectRatio(9 / 16, contentMode: .fill)
                        .clipped()
                        .cornerRadius(10)
                        .shadow(radius: 5)

                        Text(photo.photographer)
                            .font(.caption)
                    }
                }
            }
        }
        .padding(8)
    }

    @ViewBuilder
    var loader: some View {
        ProgressView()
    }
}
