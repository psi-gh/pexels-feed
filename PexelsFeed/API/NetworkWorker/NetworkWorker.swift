// NetworkWorker.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 11.08.2021.

import Combine
import Foundation

enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum BodyType {
    case json
    case urlencoded
    case rawData
    case imageData
    case formData
}

enum InternalError: Error {
    case invalidUrl(String)
    case invalidQuery(String)
    case invalidResponseCode(Int, HTTPURLResponse)
    case responseDataIsNotJsonDecodable(String)
    case emptyContext
    case emptyResponseData
}

struct FormParameterFile: Codable {
    let fileName: String
    let mimeType: String
    let data: Data
}

class NetworkWorker: NetworkProtocol {
    var supportedErrorTypes: [CodableNetworkError.Type] = []

    let jsonEncoder: JSONEncoder
    var headers: [String: String]

    private let session: URLSession
    private var subscriptions = Set<AnyCancellable>()

    init() {
        session = URLSession(configuration: URLSessionConfiguration.default)
        jsonEncoder = JSONEncoder()
        headers = ["Accept": "application/json"]
        URLCache.shared.memoryCapacity = 100 * 1024 * 1024   // 100MB
        URLCache.shared.diskCapacity = 100 * 1024 * 1024     // 100MB
    }

    func performDataTaskWithMapping<T: Decodable>(with method: RequestMethod,
                                                  to body: String,
                                                  resource: String,
                                                  response _: T.Type,
                                                  queryParameters: [String: Any]?,
                                                  bodyParameters: [String: Any]?,
                                                  additionalHeaders: [String: String]?,
                                                  rawData: Data?,
                                                  bodyType: BodyType) -> AnyPublisher<T, Error>
    {
        return performDataTask(with: method, to: body, resource: resource, queryParameters: queryParameters, bodyParameters: bodyParameters, additionalHeaders: additionalHeaders, rawData: rawData, bodyType: bodyType)
    }

    func performDataTaskWithDictionaryResponse(with method: RequestMethod,
                                               to body: String,
                                               resource: String,
                                               queryParameters: [String: Any]?,
                                               bodyParameters: [String: Any]?,
                                               additionalHeaders: [String: String]?,
                                               rawData: Data?,
                                               bodyType: BodyType) -> AnyPublisher<[String: Any], Error>
    {
        var request: URLRequest
        do {
            request = try createRequest(with: method, body: body, resource: resource, queryParameters: queryParameters, bodyParameters: bodyParameters, additionalHeaders: additionalHeaders, rawData: rawData, bodyType: bodyType)
        } catch {
            return Result<[String: Any], Error>.Publisher(HTTPError.invalidRequest).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { $0 }
            .flatMap { data, response -> AnyPublisher<Data, Error> in
                self.convertResponseErrorToSupportedTypes(data: data, response: response)
            }
            .tryMap { data -> [String: Any] in
                guard data.count != 0 else {
                    throw InternalError.emptyResponseData
                }

                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    throw InternalError.responseDataIsNotJsonDecodable(data.base64EncodedString())
                }

                return json
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func performUploadTask<T: Decodable>(with method: RequestMethod,
                                         to body: String,
                                         resource: String,
                                         response _: T.Type,
                                         queryParameters: [String: Any]?,
                                         bodyParameters: [String: Any]?,
                                         additionalHeaders: [String: String]?,
                                         rawData: Data?,
                                         bodyType: BodyType) -> AnyPublisher<T, Error>
    {
        var request: URLRequest
        do {
            request = try createRequest(with: method, body: body, resource: resource, queryParameters: queryParameters, bodyParameters: bodyParameters, additionalHeaders: additionalHeaders, rawData: rawData, bodyType: bodyType)
        } catch {
            return Result<T, Error>.Publisher(HTTPError.invalidRequest).eraseToAnyPublisher()
        }

        guard let data = request.httpBody else {
            return Result<T, Error>.Publisher(HTTPError.invalidRequest).eraseToAnyPublisher()
        }

        return upload(request: request, data: data)
            .mapError { $0 }
            .flatMap { data, response -> AnyPublisher<Data, Error> in
                self.convertResponseErrorToSupportedTypes(data: data ?? Data(), response: response)
            }
            .tryMap { data -> T in
                if data.count != 0 {
                    return try APIConstants.jsonDecoder.decode(T.self, from: data)
                } else if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                } else {
                    throw InternalError.emptyResponseData
                }
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func encode<R: Encodable>(model: R) -> (Data?, Error?) {
        do {
            let data = try jsonEncoder.encode(model)
            return (data, nil)
        } catch {
            return (nil, error)
        }
    }

    private func performDataTask<T: Decodable>(with method: RequestMethod,
                                               to body: String,
                                               resource: String,
                                               queryParameters: [String: Any]?,
                                               bodyParameters: [String: Any]?,
                                               additionalHeaders: [String: String]?,
                                               rawData: Data?,
                                               bodyType: BodyType) -> AnyPublisher<T, Error>
    {
        var request: URLRequest
        do {
            request = try createRequest(with: method, body: body, resource: resource, queryParameters: queryParameters, bodyParameters: bodyParameters, additionalHeaders: additionalHeaders, rawData: rawData, bodyType: bodyType)
        } catch {
            return Result<T, Error>.Publisher(HTTPError.invalidRequest).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { $0 }
            .flatMap { data, response -> AnyPublisher<Data, Error> in
                self.convertResponseErrorToSupportedTypes(data: data, response: response)
            }
            .tryMap { data -> T in
                if data.count != 0 {
                    return try APIConstants.jsonDecoder.decode(T.self, from: data)
                } else if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                } else {
                    throw InternalError.emptyResponseData
                }
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    private func createRequest(with method: RequestMethod, body: String, resource: String, queryParameters: [String: Any]?, bodyParameters: [String: Any]?, additionalHeaders: [String: String]?, rawData: Data?, bodyType: BodyType) throws -> URLRequest {
        guard let resource = resource.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed), let url = URL(string: body + resource) else {
            throw InternalError.invalidUrl("Cant create URL from base: \(body) and resource: \(resource)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let queryParameters = queryParameters {
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw InternalError.invalidUrl("Cant create URL components from url: \(url)")
            }
            components.queryItems = queryParameters.map { key, value -> URLQueryItem in
                URLQueryItem(name: key, value: "\(value)")
            }
            guard let newUrl = components.url else {
                throw InternalError.invalidQuery("Cant create URL with given query items: \(queryParameters)")
            }
            request.url = newUrl
        }

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            request.setValue(version, forHTTPHeaderField: "X-APP-VERSION")
        }

        if let bodyParameters = bodyParameters {
            switch bodyType {
            case .json:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: .prettyPrinted)
            case .urlencoded:
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpBody = bodyParameters.map { key, value -> String in
                    "\(key)=\(value)"
                }.joined(separator: "&").data(using: String.Encoding.utf8)
            case .formData:
                let boundary = "----Boundary-\(UUID().uuidString)"
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = createFormDataBody(from: bodyParameters, boundary: boundary)
            default:
                break
            }
        } else if let rawData = rawData {
            switch bodyType {
            case .rawData:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = rawData
            default:
                break
            }
        } else if bodyType == .imageData {
            request.setValue("image/tiff", forHTTPHeaderField: "Content-Type")
        }

        for (key, header) in headers {
            request.setValue(header, forHTTPHeaderField: key)
        }

        if let additionalHeaders = additionalHeaders {
            for (key, header) in additionalHeaders {
                request.setValue(header, forHTTPHeaderField: key)
            }
        }

        return request
    }

    private func createFormDataBody(from bodyParameters: [String: Any], boundary: String) -> Data {
        let httpBody = NSMutableData()
        for (key, value) in bodyParameters {
            if let value = value as? String {
                var fieldString = "--\(boundary)\r\n"
                fieldString += "Content-Disposition: form-data; name=\"\(key)\"\r\n"
                fieldString += "\r\n"
                fieldString += "\(value)\r\n"
                httpBody.appendString(fieldString)
            } else if let value = value as? Data {
                httpBody.appendString("--\(boundary)\r\n")
                httpBody.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(key)\"\r\n")
                httpBody.appendString("Content-Type: image/*\r\n\r\n")
                httpBody.append(value)
                httpBody.appendString("\r\n")
            } else if let value = value as? FormParameterFile {
                httpBody.appendString("--\(boundary)\r\n")
                httpBody.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(value.fileName)\"\r\n")
                httpBody.appendString("Content-Type: \(value.mimeType)\r\n\r\n")
                httpBody.append(value.data)
                httpBody.appendString("\r\n")
            } else {
                print("🔴 Couldn't process multipart parameter \(value) with key \(key)")
            }
        }

        httpBody.appendString("--\(boundary)--\r\n")
        return httpBody as Data
    }

    private func convertResponseErrorToSupportedTypes(data: Data, response: URLResponse) -> AnyPublisher<Data, Error> {
        guard let httpResponse = response as? HTTPURLResponse else {
            return Fail(error: ResponseError.InvalidHttpUrlFormat).eraseToAnyPublisher()
        }

        guard 200 ... 299 ~= httpResponse.statusCode else {
            for type in supportedErrorTypes {
                if let error = try? type.decode(decoder: APIConstants.jsonDecoder, data: data) {
                    let resultError = ResponseError.CodableNetworkError(error)
                    return Fail(error: resultError).eraseToAnyPublisher()
                }
            }

            let description = String(data: data, encoding: .utf8)
            let resultError = ResponseError.InvalidErrorWithStatusCode(httpResponse.statusCode, description)
            return Fail(error: resultError).eraseToAnyPublisher()
        }

        return Just(data).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    private func upload(request: URLRequest, data: Data) -> AnyPublisher<(Data?, URLResponse), Error> {
        let subject: PassthroughSubject<(Data?, URLResponse), Error> = .init()
        let task: URLSessionUploadTask = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            if let error = error {
                subject.send(completion: .failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                subject.send(completion: .failure(InternalError.emptyResponseData))
                return
            }

            subject.send((data, response))
            subject.send(completion: .finished)
        }

        task.resume()
        return subject.eraseToAnyPublisher()
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
