// PexelsFeedApp.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 01.05.2024.

import SwiftUI

@main
struct PexelsFeedApp: App {
    // not safe; just for sake of simplicity
    private var backendController = DefaultBackendController(
        networkWorker: NetworkWorker(),
        credentialStorage: DefaultCredentialStorage(
            token: "M7mUNkqllkBcFtmJoXrkCQWkXB9oHHia9vKvhLXJZTIMXdgK7upH1OMK")
    )

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: .init(backendController: backendController))
        }
        .environmentObject(backendController)
    }
}
