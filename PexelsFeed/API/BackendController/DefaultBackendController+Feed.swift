import Foundation
import Combine

extension DefaultBackendController: BackendControllerFeed {
    func getFeed(page: Int, perPage: Int) -> AnyPublisher<FeedPage, Error> {
        let params = ["page": page, "perPage": perPage] as [String : Int]
        return self.performRequest(with: .get,
                                   to: "/v1/curated",
                                   response: FeedPage.self,
                                   queryParameters: params,
                                   bodyParameters: nil,
                                   rawData: nil,
                                   bodyType: .rawData)
    }
}
