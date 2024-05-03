// ContentViewModel.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 02.05.2024.

import Combine
import Foundation

// @Observable
@MainActor
class ContentViewModel: ObservableObject {
    private(set) var backendController: BackendController
    private(set) var asyncBackendController: AsyncBackendController

    private var subscriptions = Set<AnyCancellable>()
    private var page: Int = 0
    var subscription: AnyCancellable?

    @Published var photos: [Photo] = []
    var feedPage: [Photo] = []

    var isLoading = false

    init(backendController: BackendController, asyncBackendController: AsyncBackendController) {
        self.backendController = backendController
        self.asyncBackendController = asyncBackendController
    }
    
    func loadPhotosAsync() {
        print(#function)
        Task {
            do {
                let photos = try await asyncBackendController.getCuratedPhotos(page: 1, perPage: 10)
                self.photos = photos.photos
            } catch {
                print("Failed to fetch photos: \(error)")
            }
        }
    }
    
    func reloadAsync() async {
        print(#function)
        do {
            let photos = try await asyncBackendController.getCuratedPhotos(page: 1, perPage: 10)
            self.photos = photos.photos
        } catch {
            print("Failed to fetch photos: \(error)")
        }
    }
    
    func reload()  {
        print(#function)
        isLoading = true
        page = 1
        makeCall(isReload: true)
    }

    func loadPhotos() {
        print(#function)
        isLoading = true
        page += 1
        makeCall(isReload: false)
    }

    func makeCall(isReload: Bool) {
        print(#function)
        backendController.getFeed(page: page, perPage: 10)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    print("request finished")
                case let .failure(error):
                    print("🚘 error: \(error)")
                }
            } receiveValue: { [weak self] item in
                if isReload {
                    self?.photos = item.photos
                } else {
                    self?.photos.append(contentsOf: item.photos)
                }
                self?.isLoading = false
            }.store(in: &subscriptions)
    }
}
