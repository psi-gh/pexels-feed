// ContentViewModel.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 01.05.2024.

import Combine
import Foundation

@Observable
class ContentViewModel {
    private(set) var backendController: BackendController
    private var subscriptions = Set<AnyCancellable>()

    var photos: [Photo] = []
    var isLoading = false

    init(backendController: BackendController) {
        self.backendController = backendController
    }

    func loadPhotos() {
        isLoading = true
        backendController.getFeed(page: 1, perPage: 10)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    print("request finished")
                case let .failure(error):
                    print("🚘 error: \(error)")
                }
            } receiveValue: { [weak self] item in
                self?.isLoading = false
                self?.photos = item.photos
                print(item)
            }.store(in: &subscriptions)
    }
}
