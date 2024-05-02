// Error+description.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 11.08.2021.

import Foundation

extension Error {
    func getDescription() -> String? {
        if let httpError = self as? HTTPError {
            return httpError.localizedDescription
        }

        return nil
    }
}
