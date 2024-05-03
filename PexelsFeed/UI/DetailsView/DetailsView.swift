// DetailsView.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 03.05.2024.

import SwiftUI

struct DetailView: View {
    let photo: Photo
    @GestureState private var zoom = 1.0

    var body: some View {
        ScrollView {
            // AsyncImage works well with simple photo load and it uses URLSession's caching
            AsyncImage(url: URL(string: photo.source.original)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(zoom)
                    .gesture(
                        MagnifyGesture()
                            .updating($zoom) { value, gestureState, _ in
                                gestureState = value.magnification
                            }
                    )
            } placeholder: {
                ProgressView()
            }
        }
        .navigationTitle(photo.photographer)
        .navigationBarTitleDisplayMode(.inline)
    }
}
