// ImageCache.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 03.05.2024.

import UIKit

class ImageCache {
    static let shared = ImageCache()
    private init() {}

    private var cache = NSCache<NSString, UIImage>()

    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
