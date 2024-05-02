// BackendController.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 11.09.2021.

import Combine
import Foundation
import UIKit

protocol BackendControllerFeed {
    func getFeed(page: Int, perPage: Int) -> AnyPublisher<FeedPage, Error>
}

typealias BackendController = BackendControllerFeed
