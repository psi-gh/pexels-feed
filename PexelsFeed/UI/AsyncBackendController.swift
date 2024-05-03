import Foundation

class AsyncBackendController: ObservableObject {
    private let apiKey = "M7mUNkqllkBcFtmJoXrkCQWkXB9oHHia9vKvhLXJZTIMXdgK7upH1OMK"
    private let baseURL = URL(string: "https://api.pexels.com/v1/curated")!

    // Function to fetch curated photos
    func getCuratedPhotos(page: Int, perPage: Int) async throws -> FeedPage {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.addValue("\(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(FeedPage.self, from: data)
    }
}
