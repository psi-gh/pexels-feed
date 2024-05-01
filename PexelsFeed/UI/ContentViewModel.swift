//
//  ContentViewModel.swift
//  PexelsFeed
//
//  Created by Pavel Ivanov on 01.05.2024.
//

import Foundation
import Combine

@Observable
class ContentViewModel {
    private(set) var backendController: BackendController
    private var subscriptions = Set<AnyCancellable>()

    init(backendController: BackendController) {
        self.backendController = backendController
    }
    
    func tap() {
        backendController.getFeed(page: 1, perPage: 10)
            .sink { completion in
                switch completion {
                case .finished:
                    print("request finished")
                case .failure(let error):
                    print("🚘 error: \(error)")
                }
            } receiveValue: { item in
                print(item)
            }.store(in: &self.subscriptions)
    }
}
