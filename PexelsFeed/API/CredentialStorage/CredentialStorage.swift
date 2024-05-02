// CredentialStorage.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 11.08.2021.

import Foundation

protocol CredentialStorageOutput: AnyObject {
    var token: String? { get }
}

protocol CredentialStorageInput {
    func setValues(token: String?)
}

typealias CredentialStorage = CredentialStorageInput & CredentialStorageOutput
