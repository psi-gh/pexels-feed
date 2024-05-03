// NetworkProtocol.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 11.08.2021.

import Combine
import Foundation

protocol NetworkProtocol {
    func performDataTaskWithMapping<T: Decodable>(with method: RequestMethod, to body: String, resource: String, response type: T.Type, queryParameters: [String: Any]?, bodyParameters: [String: Any]?, additionalHeaders: [String: String]?, rawData: Data?, bodyType: BodyType) -> AnyPublisher<T, Error>
    func performDataTaskWithDictionaryResponse(with method: RequestMethod,
                                               to body: String,
                                               resource: String,
                                               queryParameters: [String: Any]?,
                                               bodyParameters: [String: Any]?,
                                               additionalHeaders: [String: String]?,
                                               rawData: Data?,
                                               bodyType: BodyType) -> AnyPublisher<[String: Any], Error>

    func performUploadTask<T: Decodable>(with method: RequestMethod,
                                         to body: String,
                                         resource: String,
                                         response type: T.Type,
                                         queryParameters: [String: Any]?,
                                         bodyParameters: [String: Any]?,
                                         additionalHeaders: [String: String]?,
                                         rawData: Data?,
                                         bodyType: BodyType) -> AnyPublisher<T, Error>

    func encode<R: Encodable>(model: R) -> (Data?, Error?)

    var supportedErrorTypes: [CodableNetworkError.Type] { get set }
}
