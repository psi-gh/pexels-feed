// DefaultCredentialStorage.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 11.08.2021.

import Foundation

class DefaultCredentialStorage: CredentialStorage {
    static let shared = DefaultCredentialStorage()

    // MARK: - Properties

    var token: String?

    // MARK: - Init

    init(token: String? = nil) {
        self.token = token
    }

    // MARK: - Methods

    func setValues(token: String?) {
        self.token = token
    }
}
