//
//  PaginationService.swift
//  PexelsFeed
//
//  Created by Pavel Ivanov on 03.05.2024.
//

import Foundation

class PaginationService<T: Decodable>: Observable {
    var getPage: (Int, Int) async throws ->  T
    private(set) var asyncBackendController: AsyncBackendController
    private var page: Int = 0
    private let pageSize = 10
    
    init(asyncBackendController: AsyncBackendController,
         getPage: @escaping (Int, Int) async throws -> T) where T: Decodable {
        self.asyncBackendController = asyncBackendController
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
