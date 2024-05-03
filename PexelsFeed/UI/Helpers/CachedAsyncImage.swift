// CachedAsyncImage.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 03.05.2024.

import SwiftUI

struct CachedAsyncImage: View {
    let url: URL

    @State private var image: UIImage? = nil

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                ProgressView()
                    .onAppear(perform: loadImage)
            }
        }
    }

    private func loadImage() {
        if let cachedImage = ImageCache.shared.getImage(forKey: url.absoluteString) {
            print("extracted image \(url.absoluteString)")
            image = cachedImage
        } else {
            print("new load")
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let downloadedImage = UIImage(data: data) else {
                    return
                }
                DispatchQueue.main.async {
                    ImageCache.shared.setImage(downloadedImage, forKey: url.absoluteString)
                    image = downloadedImage
                }
            }.resume()
        }
    }
}
