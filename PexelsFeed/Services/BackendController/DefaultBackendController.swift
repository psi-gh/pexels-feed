import Foundation
import Combine

struct EmptyResponse: Decodable {}

enum ResponseError: Error, LocalizedError {
    case InvalidHttpUrlFormat
    case InvalidErrorWithStatusCode(Int, String?)
    case WrongStatusCodeWithError(Int, Error)
    case CodableNetworkError(CodableNetworkError)
    case decodingError
    
    var errorDescription: String?  {
        switch self {
        case .InvalidHttpUrlFormat:
            return ""
        case .InvalidErrorWithStatusCode(_, let description):
            return description ?? ""
        case .WrongStatusCodeWithError(_, _):
            return ""
        case .CodableNetworkError(let networkError):
            return networkError.getDescription()
        case .decodingError :
            return "decoding error"
        }
    }
}

class DefaultBackendController: ObservableObject {
    static let shared = DefaultBackendController(networkWorker: NetworkWorker(), credentialStorage: DefaultCredentialStorage.shared)
    var networkWorker: NetworkProtocol
    var credentialStorage: CredentialStorage
    
    init(networkWorker: NetworkProtocol, credentialStorage: CredentialStorage) {
        self.networkWorker = networkWorker
        self.credentialStorage = credentialStorage
        
        self.networkWorker.supportedErrorTypes = []
    }
    
    public func performRequestWithModel<T: Decodable, R: Encodable>(with method: RequestMethod, to resource: String, response type: T.Type, queryParameters: [String: Any]? = nil, bodyParameters: [String: Any]? = nil, rawData: Data? = nil, model: R?, bodyType: BodyType) -> AnyPublisher<T, Error> {

        var encodedData: Data?
        if model != nil {
            let result = self.networkWorker.encode(model: model)
            if let data = result.0 {
                encodedData = data
            } else if let _ = result.1 {
                return Result<T, Error>.Publisher(HTTPError.encodeFailed).eraseToAnyPublisher()
            }
        } else if rawData != nil{
            encodedData = rawData
        }
        
        let additionalHeaders = self.generateHeader()
        
        return self.networkWorker.performDataTaskWithMapping(with: method, to: APIConstants.baseURL, resource: resource, response: type, queryParameters: queryParameters, bodyParameters: bodyParameters, additionalHeaders: additionalHeaders, rawData: encodedData, bodyType: bodyType)
        .eraseToAnyPublisher()
    }
    
    public func performRequest<T: Decodable>(with method: RequestMethod, to resource: String, response type: T.Type, queryParameters: [String: Any]? = nil, bodyParameters: [String: Any]? = nil, rawData: Data? = nil,  bodyType: BodyType) -> AnyPublisher<T, Error> {
        let additionalHeaders = self.generateHeader()
        return self.networkWorker.performDataTaskWithMapping(with: method, to: APIConstants.baseURL, resource: resource, response: type, queryParameters: queryParameters, bodyParameters: bodyParameters, additionalHeaders: additionalHeaders, rawData: rawData, bodyType: bodyType)
            
    }
    
    public func performUploadRequest<T: Decodable>(with method: RequestMethod, to resource: String, response type: T.Type, queryParameters: [String: Any]? = nil, bodyParameters: [String: Any]? = nil, rawData: Data? = nil,  bodyType: BodyType) -> AnyPublisher<T, Error> {
        let additionalHeaders = self.generateHeader()
        return self.networkWorker.performUploadTask(with: method, to: APIConstants.baseURL, resource: resource, response: type, queryParameters: queryParameters, bodyParameters: bodyParameters, additionalHeaders: additionalHeaders, rawData: rawData, bodyType: bodyType)
    }
    
    public func performRequestWithDictionaryResponse(with method: RequestMethod, to resource: String, queryParameters: [String: Any]? = nil, bodyParameters: [String: Any]? = nil, rawData: Data? = nil,  bodyType: BodyType) -> AnyPublisher<[String: Any], Error> {
        let additionalHeaders = self.generateHeader()
        return self.networkWorker.performDataTaskWithDictionaryResponse(with: method, to: APIConstants.baseURL, resource: resource, queryParameters: queryParameters, bodyParameters: bodyParameters, additionalHeaders: additionalHeaders, rawData: rawData, bodyType: bodyType)
    }
    
    private func handleError()  { }
    
    private func generateHeader() -> [String : String] {
        var header = [String : String]()
    
        if let token = self.credentialStorage.token {
            header["Authorization"] = "\(token)"
        }
        
        return header
    }
}


