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
    private(set) var asyncBackendController: AsyncBackendController
    private(set) var paginationService: PaginationService<FeedPage>

    @Published var photosUIModels: [PhotoUIModel] = []

    var feedPage: [Photo] = []

    init(asyncBackendController: AsyncBackendController) {
        self.asyncBackendController = asyncBackendController
        paginationService = .init(getPage: { page, perPage async throws -> FeedPage in
            try await asyncBackendController.getCuratedPhotos(page: page, perPage: perPage)
        })
    }

    func loadPhotosAsync() {
        Task {
            do {
                if let page = try await paginationService.getNextPage() {
                    photosUIModels.append(contentsOf: convertPageToUIModels(page))
                }
            } catch {
                print("Failed to fetch photos: \(error)")
            }
        }
    }

    func reloadAsync() async {
        do {
            if let page = try await paginationService.reload() {
                photosUIModels = convertPageToUIModels(page)
            }
        } catch {
            print("Failed to fetch photos: \(error)")
        }
    }

    private func convertPageToUIModels(_ page: FeedPage) -> [PhotoUIModel] {
        page.photos.map { PhotoUIModel(photo: $0, id: UUID().uuidString) }
    }
}
