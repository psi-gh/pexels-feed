// DefaultBackendControllerBuilder.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 11.09.2021.

import Foundation

class DefaultBackendControllerBuilder: BackendControllerBuilderProtocol {
    func buildDefaultBackendController() -> BackendController {
        return DefaultBackendController(networkWorker: NetworkWorker(), credentialStorage: DefaultCredentialStorage.shared)
    }
}
