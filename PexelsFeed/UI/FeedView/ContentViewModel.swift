// ContentViewModel.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 02.05.2024.

import Combine
import Foundation

struct PhotoUIModel: Equatable {
    let photo: Photo
    let id: String
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

// @Observable
@MainActor
class ContentViewModel: ObservableObject {
    private(set) var backendController: BackendController
    private(set) var asyncBackendController: AsyncBackendController

    private var subscriptions = Set<AnyCancellable>()
    private var page: Int = 1
    var subscription: AnyCancellable?

//    @Published var photos: [Photo] = []
    @Published var photosUIModels: [PhotoUIModel] = []
    
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
                self.photosUIModels = photos.photos.map { PhotoUIModel(photo: $0, id: UUID().uuidString) }
            } catch {
                print("Failed to fetch photos: \(error)")
            }
        }
    }
    
    func reloadAsync() async {
        print(#function)
        self.photosUIModels = []
        do {
            let photos = try await asyncBackendController.getCuratedPhotos(page: 1, perPage: 10)
            self.photosUIModels = photos.photos.map { PhotoUIModel(photo: $0, id: UUID().uuidString) }
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
                let models = item.photos.map { PhotoUIModel(photo: $0, id: UUID().uuidString) }
                if isReload {
                    self?.photosUIModels = models
                } else {
                    self?.photosUIModels.append(contentsOf: models)
                }
                self?.isLoading = false
            }.store(in: &subscriptions)
    }
}
