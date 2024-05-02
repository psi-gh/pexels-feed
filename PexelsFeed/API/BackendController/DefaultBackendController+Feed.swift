// DefaultBackendController+Feed.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 11.09.2021.

import Combine
import Foundation

extension DefaultBackendController: BackendControllerFeed {
    func getFeed(page: Int, perPage: Int) -> AnyPublisher<FeedPage, Error> {
        let params = ["page": page, "perPage": perPage] as [String: Int]
        return performRequest(with: .get,
                              to: "/v1/curated",
                              response: FeedPage.self,
                              queryParameters: params,
                              bodyParameters: nil,
                              rawData: nil,
                              bodyType: .rawData)
    }
}
