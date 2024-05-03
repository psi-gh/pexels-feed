// PaginationService.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 03.05.2024.

import Foundation

class PaginationService<T: Decodable>: Observable {
    var getPage: (Int, Int) async throws -> T
    private var page: Int = 0
    private let pageSize = 10

    init(getPage: @escaping (Int, Int) async throws -> T) where T: Decodable {
        self.getPage = getPage
    }

    func getNextPage() async throws -> T? {
        print(#function)
        page += 1
        do {
            let photos = try await getPage(page, pageSize)
            return photos
        } catch {
            print("Failed to fetch photos: \(error)")
            return nil
        }
    }

    func reload() async throws -> T? {
        print(#function)
        page = 1
        do {
            let photos = try await getPage(page, pageSize)
            return photos
        } catch {
            print("Failed to fetch photos: \(error)")
            return nil
        }
    }
}
