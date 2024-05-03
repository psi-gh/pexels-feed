import Foundation

class AsyncBackendController: ObservableObject {
    var session = URLSession.shared
    let baseURL = "https://api.pexels.com"
    private let apiKey: String
    
    init(apiKey: String ) {
        self.apiKey = apiKey
    }
    
    func getCuratedPhotos(page: Int, perPage: Int) async throws -> FeedPage {
        let parameters = [
            "page": String(page),
            "per_page": String(perPage)
        ]
        
        return try await fetchData(.get, path: "/v1/curated", parameters: parameters, decodeTo: FeedPage.self)
    }
    
    func fetchData<T: Decodable>(_ method: RequestMethod, path: String, parameters: [String: Any]?, decodeTo model: T.Type) async throws -> T {
        guard var urlComponents = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        if let parameters = parameters {
            urlComponents.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: String(describing: value))
            }
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        request.addValue("\(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case noData
    }
    
    enum RequestMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
}
